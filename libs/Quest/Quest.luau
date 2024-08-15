local Signal = require(script.Parent.Signal)

type BinItem = Instance | RBXScriptConnection | () -> ...any

export type Add = <T>(Item: T & BinItem) -> T
export type Clear = () -> ()

export type Rewards = {
	name: string,
	Apply: (Player) -> (),
}

type QuestData = {
	name: string,
	progress: number,
	target: number,
	status: string,
	state: string,
	rewards: { Rewards },
	npc: Instance?,
	connections: { RBXScriptConnection },
	ProgressChanged: Signal.Signal<number>,
	StateChanged: Signal.Signal<string>,
	UpdateProgress: (number) -> (),
	SetProgress: (number) -> (),
	IncrementProgress: (number) -> (),
	GetProgress: () -> number,
	Complete: () -> (),
	Cancel: () -> (),
}

type Quest = {
	player: Player,
	data: QuestData,
	Start: () -> (),
	Complete: () -> (),
	Cancel: () -> (),
}

local function CreateBin()
	local Bin: { BinItem } = {}

	return function<T>(Item: T & BinItem)
		table.insert(Bin, Item)
		return Item
	end, function()
		for _, Item in Bin do
			if typeof(Item) == "Instance" then
				Item:Destroy()
			elseif typeof(Item) == "RBXScriptConnection" then
				Item:Disconnect()
			elseif typeof(Item) == "function" then
				task.spawn(Item)
			end
		end

		table.clear(Bin)
	end
end

local function NewQuest(
	name: string,
	target: number,
	rewards: { Rewards },
	npc: Instance?,
	Initialize: (QuestData, (any) -> ()) -> ()
): (Player) -> Quest
	return function(player: Player): Quest
		local progressChanged = Signal()
		local stateChanged = Signal()

		local Add, Clear = CreateBin()

		local progress = 0

		local questData: QuestData

		local function Cleanup()
			Clear()
			progressChanged:DisconnectAll()
			stateChanged:DisconnectAll()
		end

		local function Cancel()
			questData.state = "Cancelled"
			stateChanged:Fire(questData.state)
			Cleanup()
		end

		local function Complete()
			if questData.state ~= "Active" then
				warn("Tried to complete a non-active quest")
				return
			end

			questData.state = "Completed"
			stateChanged:Fire(questData.state)

			for _, reward in questData.rewards do
				reward.Apply(player)
			end

			Cleanup()
		end

		local function UpdateProgress(newProgress: number)
			if questData.progress == newProgress then
				return
			end

			questData.progress = newProgress
			progressChanged:Fire(newProgress)

			if questData.progress >= questData.target then
				questData.status = "Completed"
				Complete()
			end
		end

		local function SetProgress(newProgress: number)
			if progress == newProgress then
				return
			end

			progress = math.min(target, newProgress)
			progressChanged:Fire(progress)
		end

		local function GetProgress()
			return progress
		end

		local function IncrementProgress(amount: number)
			SetProgress(progress + amount)
		end

		questData = {
			name = name,
			progress = 0,
			target = target,
			status = "InProgress",
			state = "Active",
			rewards = rewards,
			npc = npc,
			connections = {},
			ProgressChanged = progressChanged,
			StateChanged = stateChanged,
			UpdateProgress = UpdateProgress,
			SetProgress = SetProgress,
			IncrementProgress = IncrementProgress,
			GetProgress = GetProgress,
			Complete = Complete,
			Cancel = Cancel,
		}

		Initialize(questData, Add)

		return {
			player = player,
			data = questData,
			Start = function()
				Initialize(questData, Add)
			end,
			Complete = Complete,
			Cancel = Cancel,
		}
	end
end

return {
	NewQuest = NewQuest,
}
