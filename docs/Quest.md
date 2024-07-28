# Quest

This module provides functionality to manage quests for players. It supports starting quests, updating progress, and completing quests.

## Classes

### `Quest`

#### Properties

- `player: Player` - The player associated with the quest.
- `data: QuestData` - The data of the quest.

#### Methods

- `Start() -> ()` - Starts the quest.
- `Complete() -> ()` - Completes the quest and applies rewards if completed.

## Types

### `Rewards`

Represents a reward that can be given to a player upon completing a quest.

#### Properties

- `name: string` - The name of the reward.
- `Apply(player: Player) -> ()` - The function to apply the reward to a player.

### `QuestData`

Represents the data for a quest.

#### Properties

- `name: string` - The name of the quest.
- `progress: number` - The current progress of the quest.
- `target: number` - The target progress to complete the quest.
- `status: string` - The status of the quest (e.g., "InProgress" or "Completed").
- `rewards: {Rewards}` - The rewards for completing the quest.
- `npc: Instance?` - Optional. The NPC associated with the quest.
- `connections: {RBXScriptConnection}` - The connections related to the quest.
- `progressChanged: Signal` - The signal that fires when the progress changes.
- `UpdateProgress(newProgress: number) -> ()` - The function to update the quest progress.

### `Signal`

Represents a signal that can be connected to, waited on, and fired.

#### Properties

- `Root: SignalNode?` - The root node of the signal.

#### Methods

- `Connect(callback: (T...) -> ()) -> () -> ()` - Connects a callback to the signal.
- `Wait() -> T...` - Waits for the signal to fire.
- `Once(callback: (T...) -> ()) -> ()` - Connects a callback to the signal that will only be called once.
- `Fire(T...) -> ()` - Fires the signal.
- `DisconnectAll() -> ()` - Disconnects all connections from the signal.

## Functions

### `NewQuest`

Creates a new quest instance with the specified parameters.

#### Parameters

- `name: string` - The name of the quest.
- `target: number` - The target progress value to complete the quest.
- `rewards: {Rewards}` - The rewards for completing the quest.
- `npc: Instance?` - Optional. The NPC associated with the quest.
- `Initialize(QuestData, (any) -> ()) -> ()` - The initialization function for the quest.

#### Returns

- `(Player) -> Quest` - The function to create a quest for a specific player.

## Usage

```lua
local Players = game:GetService("Players")
local NewQuest = require(Quest)
local QuestUtil = require(QuestUtil)

local function KillBanditsQuest(player)
	local rewards: { NewQuest.Rewards } = {
		QuestUtil.Rewards.GiveCredits("Get 100 Credits", 100),
	}

	local quest = NewQuest("Kill the Bandits!", 1, rewards, workspace.FrescoAI, function(QuestData, binAdd)
		binAdd(QuestUtil.MobKilled:Connect(function(_killedMob, _killer)
			QuestData.UpdateProgress(QuestData.progress + 1)
		end))
	end)

	return quest(player)
end

Players.PlayerAdded:Connect(function(player)
	local quest = KillBanditsQuest(player)
	quest.Start()
	quest.data.progressChanged:Connect(function(progress)
		if progress >= quest.data.target then
			quest.Complete()
		end
	end)
end)
```