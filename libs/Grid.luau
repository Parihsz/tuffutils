--!native
--!optimize 2

--[[
Author(s)   : Parihsz
Date        : 07/21/2024
Version     : 1.0.0

Description : This script manages various entity positions on a grid using spatial hashing. Provides functions 
              to efficiently update, query, and manage the grid. Entities such as players, NPCs, and other 
              models can be tracked and queried selectively by type.
]]
local Workspace = game:GetService("Workspace")

local GRID_SIZE = 50
local UPDATE_INTERVAL = 2
local SHOULD_VISUALIZE = true

local lastPositions = {}
local lastUpdate = 0

local Grid = {}
Grid.grid = {}
Grid.entities = {}
local entityColors = {}

--[[
	@param position Vector3 | The position to hash.
	@return Vector3 | The hashed position.
	
	Hashes the given position to a grid cell.
]]
local function HashPosition(position: Vector3): Vector3
	return Vector3.new(position.X // GRID_SIZE + 0.5, 0, position.Z // GRID_SIZE + 0.5)
end

--[[
    Visualizes the grid in the Workspace by creating parts for each grid cell.
    Different colors indicate different types of entities.
]]
local function VisualizeGrid()
	for _, child in Workspace:GetChildren() do
		if child.Name == "GridVisualizer" then
			child:Destroy()
		end
	end

	for cellKey: any, cell: any in Grid.grid do
		local position = Vector3.new(cellKey.X * GRID_SIZE, 0, cellKey.Z * GRID_SIZE)

		local part = Instance.new("Part")
		part.Name = "GridVisualizer"
		part.Size = Vector3.new(GRID_SIZE, 1, GRID_SIZE)
		part.Position = position
		part.Anchored = true
		part.CanCollide = false
		part.Parent = Workspace

		local colorSet = false
		for entityType, entities in cell do
			if #entities > 0 then
				if not entityColors[entityType] then
					entityColors[entityType] = BrickColor.random()
				end
				part.BrickColor = entityColors[entityType]
				colorSet = true
				break
			end
		end

		if not colorSet then
			part.BrickColor = BrickColor.Gray()
		end
	end
end

--[[
    Updates the grid with the current positions of all tracked entities. This function
    is called at a fixed interval defined by UPDATE_INTERVAL.
]]
function Grid.UpdateGrid()
	local currentTime = time()
	if currentTime - lastUpdate < UPDATE_INTERVAL then
		return
	end

	for entity: any, entityType in Grid.entities do
		local position = entity:GetPivot().Position
		local hash = HashPosition(position)
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

	if SHOULD_VISUALIZE then
		VisualizeGrid()
	end

	lastUpdate = currentTime
end

--[[
    @param position Vector3 | The center position to query around.
    @param range number | The range to query within.
    @param entityTypes {string}? | Optional. The types of entities to query.
    @return {any} | The entities found within the range.

    Efficiently queries the grid for specified types of entities within a specified range from the given position.
]]
local function QueryGrid(position: Vector3, range: number, entityTypes: { string }?): { any }
	Grid.UpdateGrid()

	local rangeInCells = math.ceil(range / GRID_SIZE)
	local hash = HashPosition(position)
	local startX, startZ = hash.X - rangeInCells, hash.Z - rangeInCells
	local endX, endZ = hash.X + rangeInCells, hash.Z + rangeInCells

	local nearbyEntities = {}

	for xCell = startX, endX do
		for zCell = startZ, endZ do
			local cellKey = Vector3.new(xCell, 0, zCell)
			local cell = Grid.grid[cellKey]
			if cell then
				if entityTypes then
					for _, entityType in entityTypes do
						if cell[entityType] then
							table.move(cell[entityType], 1, #cell[entityType], #nearbyEntities + 1, nearbyEntities)
						end
					end
				else
					for _, entities in cell do
						table.move(entities, 1, #entities, #nearbyEntities + 1, nearbyEntities)
					end
				end
			end
		end
	end

	VisualizeGrid()

	return nearbyEntities
end

--[[
    @param entity Instance | The entity to add to the grid.
    @param entityType string | The type of the entity (e.g., "players", "ais").
    
    Adds the given entity to the grid under the specified type.
]]
function Grid.AddEntity(entity: Model, entityType: string)
	Grid.entities[entity] = entityType
end

--[[
    @param entity Instance | The entity to remove from the grid.
    
    Removes the given entity from the grid.
]]
function Grid.RemoveEntity(entity: Model)
	Grid.entities[entity] = nil
	lastPositions[entity] = nil
end

--[[
    @param model Model? | The model to get nearby entities for.
    @param range number | The range to query within.
    @param entityTypes {string}? | Optional. The types of entities to query.
    @return {any} | The entities found within the range.

    Retrieves entities within a specified range of the given model.
]]
function Grid.GetNearbyEntities(model: Model?, range: number, entityTypes: { string }?): { any }
	if not model then
		warn("Model is nil")
		return {}
	end
	return QueryGrid(model:GetPivot().Position, range, entityTypes)
end

return Grid
