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
	rewards: { Rewards },
	npc: Instance?,
	connections: { RBXScriptConnection },
	ProgressChanged: Signal.Signal<number>,
	UpdateProgress: (number) -> (),
}

type Quest = {
	player: Player,
	data: QuestData,
	Start: () -> (),
	Complete: () -> (),
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

		local Add, Clear = CreateBin()

		local questData: QuestData

		local function UpdateProgress(newProgress: number)
			if questData.progress == newProgress then
				return
			end

			questData.progress = newProgress
			progressChanged:Fire(newProgress)

			if questData.progress >= questData.target then
				questData.status = "Completed"
			end
		end

		local function Start()
			Initialize(questData, Add)
		end

		local function Cleanup()
			Clear()
			progressChanged:DisconnectAll()
		end

		local function Complete()
			if questData.status == "Completed" then
				for _, reward in questData.rewards do
					reward.Apply(player)
				end
				Cleanup()
			end
		end

		questData = {
			name = name,
			progress = 0,
			target = target,
			status = "InProgress",
			rewards = rewards,
			npc = npc,
			connections = {},
			ProgressChanged = progressChanged,
			UpdateProgress = UpdateProgress,
		}

		return {
			player = player,
			data = questData,
			Start = Start,
			Complete = Complete,
		}
	end
end

return {
	NewQuest = NewQuest,
}
