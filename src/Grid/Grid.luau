--!native
--!optimize 2

local Grid = {}

local GRID_SIZE = 50
local UPDATE_INTERVAL = 2

local lastPositions = {}
local lastUpdate = 0

Grid.grid = {}
Grid.entities = {}

function Grid.HashPosition(position: Vector3): Vector3
	return Vector3.new(position.X // GRID_SIZE + 0.5, 0, position.Z // GRID_SIZE + 0.5)
end

function Grid.UpdateGrid()
	local currentTime = time()
	if currentTime - lastUpdate < UPDATE_INTERVAL then
		return
	end

	for entity: any, entityType in Grid.entities do
		local position = entity:GetPivot().Position
		local hash = Grid.HashPosition(position)
		local lastHash = lastPositions[entity]

		if lastHash ~= hash then
			if lastHash then
				local oldCell = Grid.grid[lastHash]
				if oldCell then
					table.remove(oldCell[entityType], table.find(oldCell[entityType], entity))
					if next(oldCell[entityType]) == nil then
						oldCell[entityType] = nil
					end
					if next(oldCell) == nil then
						Grid.grid[lastHash] = nil
					end
				end
			end

			local cell = Grid.grid[hash] or {}
			cell[entityType] = cell[entityType] or {}
			Grid.grid[hash] = cell
			table.insert(cell[entityType], entity)
			lastPositions[entity] = hash
		end
	end

	lastUpdate = currentTime
end

local function QueryGrid(position: Vector3, range: number, entityTypes: { string }?): { any }
	Grid.UpdateGrid()
	local rangeInCells = math.ceil(range / GRID_SIZE)
	local hash = Grid.HashPosition(position)
	local startX, startZ = hash.X - rangeInCells, hash.Z - rangeInCells
	local endX, endZ = hash.X + rangeInCells, hash.Z + rangeInCells
	local nearbyEntities = {}

	local function ProcessEntities(entities)
		for _, entity in entities do
			if (entity:GetPivot().Position - position).Magnitude <= range then
				table.insert(nearbyEntities, entity)
			end
		end
	end

	for xCell = startX, endX do
		for zCell = startZ, endZ do
			local cellKey = Vector3.new(xCell, 0, zCell)
			local cell = Grid.grid[cellKey]
			if cell then
				if entityTypes then
					for _, entityType in entityTypes do
						if cell[entityType] then
							ProcessEntities(cell[entityType])
						end
					end
				else
					for _, entities in cell do
						ProcessEntities(entities)
					end
				end
			end
		end
	end

	return nearbyEntities
end

function Grid.AddEntity(entity: Model, entityType: string)
	Grid.entities[entity] = entityType
end

function Grid.RemoveEntity(entity: Model)
	Grid.entities[entity] = nil
	lastPositions[entity] = nil
end

function Grid.GetNearbyEntities(model: Model?, range: number, entityTypes: { string }?): { any }
	if not model then
		warn("Model is nil")
		return {}
	end
	return QueryGrid(model:GetPivot().Position, range, entityTypes)
end

return Grid
