--!strict
--[[
	CREDITS
		https://devforum.roblox.com/t/betterreplication-vastly-improve-your-combat-experience-by-fighting-lag/3260027
]]
local Snapshot = {}

export type SnapshotData = {
	timeStamp: number,
	position: CFrame,
}

export type SnapshotInstance = {
	PushAt: (self: SnapshotInstance, timeStamp: number, position: CFrame) -> (),
	GetBefore: (self: SnapshotInstance, timeStamp: number) -> SnapshotData?,
	GetAfter: (self: SnapshotInstance, timeStamp: number) -> SnapshotData?,
	GetAt: (self: SnapshotInstance, timeStamp: number) -> CFrame?,
	Destroy: (self: SnapshotInstance) -> (),
	Subject: Player?,
}

local MAX_LENGTH = 10
local SnapshotInstances: { [Player]: SnapshotInstance } = {}

local function BinarySearch(cache: { SnapshotData }, timeStamp: number): number
	local low, high = 1, #cache
	while low <= high do
		local mid = (low + high) // 2
		if cache[mid].timeStamp < timeStamp then
			low = mid + 1
		else
			high = mid - 1
		end
	end
	return low
end

function Snapshot.new(subject: Player): SnapshotInstance
	local cache: { SnapshotData } = {}

	local function PushAt(self: SnapshotInstance, timeStamp: number, position: CFrame): ()
		local index = BinarySearch(cache, timeStamp)
		table.insert(cache, index, { timeStamp = timeStamp, position = position })

		if #cache > MAX_LENGTH then
			table.remove(cache, 1)
		end
	end

	local function GetBefore(self: SnapshotInstance, timeStamp: number): SnapshotData?
		local index = BinarySearch(cache, timeStamp) - 1
		if index >= 1 then
			return cache[index]
		end
		return nil
	end

	local function GetAfter(self: SnapshotInstance, timeStamp: number): SnapshotData?
		local index = BinarySearch(cache, timeStamp)
		if index <= #cache then
			return cache[index]
		end
		return nil
	end

	local function GetAt(self: SnapshotInstance, timeStamp: number): CFrame?
		if #cache == 0 then
			return nil
		end
		if #cache == 1 then
			return cache[1].position
		end

		local before = self:GetBefore(timeStamp)
		local after = self:GetAfter(timeStamp)

		if before and after then
			local alpha = (timeStamp - before.timeStamp) / (after.timeStamp - before.timeStamp)
			return before.position:Lerp(after.position, alpha)
		elseif before then
			return before.position
		elseif after then
			return after.position
		end

		return nil
	end

	local function Destroy(): ()
		table.clear(cache)
	end

	return {
		PushAt = PushAt,
		GetBefore = GetBefore,
		GetAfter = GetAfter,
		GetAt = GetAt,
		Destroy = Destroy,
		Subject = subject,
	}
end

function Snapshot.RegisterPlayer(player: Player): SnapshotInstance
	if not SnapshotInstances[player] then
		SnapshotInstances[player] = Snapshot.new(player)
	end
	return SnapshotInstances[player]
end

function Snapshot.DeregisterPlayer(player: Player): ()
	local snapshot = SnapshotInstances[player]
	if snapshot then
		snapshot:Destroy()
		SnapshotInstances[player] = nil
	end
end

function Snapshot.GetSnapshotInstance(player: Player): SnapshotInstance
	return SnapshotInstances[player] or Snapshot.RegisterPlayer(player)
end

return Snapshot
