# Quest

This module provides functionality to manage quests for players. It supports starting quests, updating progress, and completing quests, including applying rewards to the players.

## Classes

### `Quest`

#### Properties

- **`player: Player`**  
  The player associated with the quest.

- **`data: QuestData`**  
  The data structure representing the quest's state and progress.

#### Methods

- **`Start() -> ()`**  
  Initiates the quest and begins tracking its progress.

- **`Complete() -> ()`**  
  Completes the quest if the conditions are met and applies the associated rewards.

- **`Cancel() -> ()`**  
  Cancels the quest and cleans up any associated resources or connections.

## Types

### `Rewards`

Represents a reward that can be given to a player upon completing a quest.

#### Properties

- **`name: string`**  
  The name of the reward.

- **`Apply(player: Player) -> ()`**  
  The function to apply the reward to a player.

### `QuestData`

Represents the data for a quest.

#### Properties

- **`name: string`**  
  The name of the quest.

- **`progress: number`**  
  The current progress value of the quest.

- **`target: number`**  
  The target progress value needed to complete the quest.

- **`status: string`**  
  The status of the quest (e.g., "InProgress", "Completed", "Cancelled").

- **`state: string`**  
  The current state of the quest.

- **`rewards: { Rewards }`**  
  A list of rewards that will be given upon quest completion.

- **`npc: Instance?`**  
  The NPC associated with the quest, if any.

- **`connections: { RBXScriptConnection }`**  
  A list of connections that should be cleaned up when the quest ends.

- **`ProgressChanged: Signal<number>`**  
  A signal fired when the progress of the quest changes.

- **`StateChanged: Signal<string>`**  
  A signal fired when the state of the quest changes.

- **`UpdateProgress(newProgress: number) -> ()`**  
  Updates the quest's progress and checks if the quest should be completed.

- **`SetProgress(newProgress: number) -> ()`**  
  Sets the progress to a specific value.

- **`IncrementProgress(amount: number) -> ()`**  
  Increments the quest's progress by a specified amount.

- **`GetProgress() -> number`**  
  Returns the current progress of the quest.

- **`Complete() -> ()`**  
  Completes the quest and applies rewards to the player.

- **`Cancel() -> ()`**  
  Cancels the quest and cleans up associated resources.

## Functions

### `CreateBin() -> (Add, Clear)`

Creates a bin to manage quest items such as instances, connections, or functions that need to be cleaned up.

#### Returns

- **`Add: Add`**  
  A function that adds an item to the bin.

- **`Clear: Clear`**  
  A function that clears all items in the bin, destroying instances, disconnecting connections, and spawning functions.

### `NewQuest(name: string, target: number, rewards: { Rewards }, npc: Instance?, Initialize: (QuestData, Add) -> ()) -> (Player) -> Quest`

Creates a new quest with the specified parameters and initialization function.

#### Parameters

- **`name: string`**  
  The name of the quest.

- **`target: number`**  
  The target progress required to complete the quest.

- **`rewards: { Rewards }`**  
  A list of rewards to be given upon quest completion.

- **`npc: Instance?`**  
  The NPC associated with the quest, if any.

- **`Initialize: (QuestData, Add) -> ()`**  
  A function to initialize the quest, given the quest data and an Add function for managing bin items.

#### Returns

- **`(Player) -> Quest`**  
  A function that, when called with a player, returns a Quest object associated with that player.

## Example Usage

```lua
local NewQuest = require(Quest) -- remember, Quest module isn't anything fancy, its just a factory function for creating a quest.
local Bandit = require(Bandit)

QuestUtil.BanditKilled = Bandit.BanditKilled

function QuestUtil.NewBanditQuest(
	displayName: string,
	count: number,
	BanditFilter: (BanditTypes.AI) -> boolean,
	rewards: { Reward }
)
	return NewQuest(displayName, count, rewards, function(data, binAdd)
		binAdd(QuestUtil.BanditKilled:Connect(function(killedBandit, killer)
			if killer and killer == data.player.Character and BanditFilter(killedBandit) then
				data.IncrementProgress(1)
			end
		end))
	end)
end
```

```lua
--store ur rewards somewhere
local Rewards = {}

type Reward = QuestTypes.Reward -- probably have a quest types module that exports all ur quest types. this module exports a few already.

function Rewards.GiveCredits(amount: number): Reward
	return {
		name = `Get {amount} credits`,
		Apply = function(player)
			DataService.WriteData(player, function(data)
				data.credits += amount
			end)
		end,
	}
end

return Rewards
```

```lua
--create it!
local Rewards = require(Rewards)
local QuestUtil = require(QuestUtil)

return QuestUtil.NewBanditQuest("Kill the Bandits!", 1, function(ai)
	return ai.model.Name == "Bandit"
end, { Rewards.GiveCredits(100) })
```