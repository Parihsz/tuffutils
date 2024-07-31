--!native
--!optimize 2

type Entity = Model
type Entities = { [Entity]: string }
type GridCell = { [string]: { Entity } }
type Grid = { [Vector3]: GridCell }

local Grid = {}

local GRID_SIZE = 50
local UPDATE_INTERVAL = 2

local lastPositions: { [Entity]: Vector3 } = {}
local lastUpdate: number = 0

local grid: Grid = {}
local entities: Entities = {}

function Grid.HashPosition(position: Vector3): Vector3
	return Vector3.new(position.X // GRID_SIZE + 0.5, 0, position.Z // GRID_SIZE + 0.5)
end

function Grid.UpdateGrid()
	local currentTime: number = time()
	if currentTime - lastUpdate < UPDATE_INTERVAL then
		return
	end

	for entity, entityType in entities do
		local position: Vector3 = entity:GetPivot().Position
		local hash: Vector3 = Grid.HashPosition(position)
		local lastHash: Vector3? = lastPositions[entity]

		if lastHash == hash then
			continue
		end

		if lastHash then
			local oldCell: GridCell? = grid[lastHash]

			if oldCell then
				local index: number? = table.find(oldCell[entityType], entity)
				if index then
					table.remove(oldCell[entityType], index)
					if #oldCell[entityType] == 0 then
						oldCell[entityType] = nil
					end
					if next(oldCell) == nil then
						grid[lastHash] = nil
					end
				end
			end
		end

		local cell: GridCell = grid[hash] or {}
		cell[entityType] = cell[entityType] or {}
		grid[hash] = cell

		table.insert(cell[entityType], entity)
		lastPositions[entity] = hash
	end

	lastUpdate = currentTime
end

local function ProcessEntities(entitiesTable: { Entity }, position: Vector3, range: number, nearbyEntities: { Entity })
	for _, entity in entitiesTable do
		if (entity:GetPivot().Position - position).Magnitude <= range then
			table.insert(nearbyEntities, entity)
		end
	end
end

local function ProcessCell(
	cell: GridCell,
	entityTypes: { string }?,
	position: Vector3,
	range: number,
	nearbyEntities: { Entity }
)
	if entityTypes then
		for _, entityType in entityTypes do
			local entitiesTable = cell[entityType]
			if entitiesTable then
				ProcessEntities(entitiesTable, position, range, nearbyEntities)
			end
		end
	else
		for _, entitiesTable in cell do
			ProcessEntities(entitiesTable, position, range, nearbyEntities)
		end
	end
end

function Grid.QueryGrid(position: Vector3, range: number, entityTypes: { string }?): { Entity }
	Grid.UpdateGrid()

	local rangeInCells = math.ceil(range / GRID_SIZE)
	local hash = Grid.HashPosition(position)
	local startX, startZ = hash.X - rangeInCells, hash.Z - rangeInCells
	local endX, endZ = hash.X + rangeInCells, hash.Z + rangeInCells

	local nearbyEntities: { Entity } = {}

	for xCell = startX, endX do
		for zCell = startZ, endZ do
			local cellKey = Vector3.new(xCell, 0, zCell)
			local cell = grid[cellKey]
			if cell then
				ProcessCell(cell, entityTypes, position, range, nearbyEntities)
			end
		end
	end

	return nearbyEntities
end

function Grid.AddEntity(entity: Model, entityType: string)
	entities[entity] = entityType
end

function Grid.RemoveEntity(entity: Model)
	entities[entity] = nil
	lastPositions[entity] = nil
end

function Grid.GetNearbyEntities(model: Model?, range: number, entityTypes: { string }?): { any }
	if not model then
		warn("Model is nil")
		return {}
	end
	return Grid.QueryGrid(model:GetPivot().Position, range, entityTypes)
end

return Grid
