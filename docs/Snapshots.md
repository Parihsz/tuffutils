# Snapshots

This module provides functionality to manage and interpolate snapshots for networking systems. It supports efficient insertion, retrieval, and interpolation of snapshots.

## Types

### `SnapshotData`

Represents a single snapshot containing a timestamp and a position.

#### Properties

- **`timeStamp: number`**  
  The time associated with the snapshot.

- **`position: CFrame`**  
  The position or transformation stored in the snapshot.

---

### `SnapshotInstance`

Represents an instance of a snapshot manager for a specific subject.

#### Properties

- **`cache: { SnapshotData }`**  
  A table containing the cached snapshot data. The cache is maintained in chronological order and automatically pruned.

- **`Subject: Player?`**  
  The player or subject associated with the snapshot instance.

#### Methods

- **`PushAt(timeStamp: number, position: CFrame) -> ()`**  
  Adds a snapshot at the specified time and position. Maintains the internal cache size.

- **`GetBefore(timeStamp: number) -> SnapshotData?`**  
  Retrieves the snapshot just before the specified timestamp, if one exists.

- **`GetAfter(timeStamp: number) -> SnapshotData?`**  
  Retrieves the snapshot just after the specified timestamp, if one exists.

- **`GetAt(timeStamp: number) -> CFrame?`**  
  Interpolates and returns the position at the specified timestamp. If no interpolation is possible, returns `nil`.

- **`RemoveOld(cutoffTime: number) -> ()`**  
  Removes all snapshots in the cache that are older than the specified `cutoffTime`. 

- **`Destroy() -> ()`**  
  Cleans up the snapshot instance, clearing all associated data.

---

## Module Functions

### `Snapshot.RegisterPlayer(player: Player) -> SnapshotInstance`

Registers a new snapshot instance for the given player. If an instance already exists for the player, it returns the existing one.

### `Snapshot.DeregisterPlayer(player: Player) -> ()`

Deregisters the snapshot instance for the given player and cleans up its resources.

### `Snapshot.GetSnapshotInstance(player: Player) -> SnapshotInstance`

Retrieves the snapshot instance for the given player. If one does not exist, it registers a new one.

---

## Example Usage

```lua
local Snapshot = require(script.Snapshot)
game.Players.PlayerAdded:Wait()

local player = game.Players:GetPlayers()[1]
local snapshot = Snapshot.RegisterPlayer(player)

snapshot:PushAt(1.0, CFrame.new(0, 0, 0))
snapshot:PushAt(2.0, CFrame.new(10, 0, 0))

local interpolatedCFrame = snapshot:GetAt(1.5)
print(interpolatedCFrame.Position)

Snapshot.DeregisterPlayer(player)
```