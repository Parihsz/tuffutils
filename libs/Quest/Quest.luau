type SignalNode<T...> = {
	Next: SignalNode<T...>?,
	Callback: (T...) -> (),
}

export type Signal<T...> = {
	Root: SignalNode<T...>?,

	Connect: (self: Signal<T...>, Callback: (T...) -> ()) -> () -> (),
	Wait: (self: Signal<T...>) -> T...,
	Once: (self: Signal<T...>, Callback: (T...) -> ()) -> () -> (),
	Fire: (self: Signal<T...>, T...) -> (),
	DisconnectAll: (self: Signal<T...>) -> (),
}

local Signal = {}
Signal.__index = Signal

local function Disconnect<T...>(self: Signal<T...>, Node: SignalNode<T...>)
	if self.Root == Node then
		self.Root = Node.Next
	else
		local Current = self.Root

		while Current do
			if Current.Next == Node then
				Current.Next = Node.Next
				break
			end

			Current = Current.Next
		end
	end
end

function Signal.Connect<T...>(self: Signal<T...>, Callback: (T...) -> ()): () -> ()
	local Node = {
		Next = self.Root,
		Callback = Callback,
	}

	self.Root = Node

	return function()
		Disconnect(self, Node)
	end
end

function Signal.Wait<T...>(self: Signal<T...>): T...
	local Thread = coroutine.running()
	local Disconnect

	Disconnect = self:Connect(function(...)
		Disconnect()
		coroutine.resume(Thread, ...)
	end)

	return coroutine.yield()
end

function Signal.Once<T...>(self: Signal<T...>, Callback: (T...) -> ()): () -> ()
	local Disconnect

	Disconnect = self:Connect(function(...)
		Disconnect()
		Callback(...)
	end)

	return Disconnect
end

function Signal.Fire<T...>(self: Signal<T...>, ...: T...)
	local Current = self.Root

	while Current do
		task.spawn(Current.Callback, ...)
		Current = Current.Next
	end
end

function Signal.DisconnectAll<T...>(self: Signal<T...>)
	self.Root = nil
end

function Signal.new<T...>(): Signal<T...>
	return setmetatable({
		Root = nil,
	}, Signal) :: any
end

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
	progressChanged: Signal<number>,
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
		local progressChanged = Signal.new()

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
			progressChanged = progressChanged,
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
