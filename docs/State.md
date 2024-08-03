# State

A lightweight state machine implementation for managing the states and transitions of entities. State machines are referenced by name and have properties to control replication, meaning they are self-syncable. (Replication is easy to opt-in to and control dynamically, but entirely optional as states are not replicated by default.)

Little to no boilerplate, as many methods are optional (i.e OnExit, Update)

## Classes

### `State`

#### Properties

- `states: { [string]: StateConfig }` - The states of the state machine.
- `currentState: string?` - The name of the current state.
- `currentStateConfig: StateConfig?` - The configuration of the current state.
- `name: string` - The name of the state machine.
- `replicateToClients: boolean` - Whether to replicate state transitions to clients.
- `replicateToServer: boolean` - Whether to replicate state transitions to the server.

#### Methods

- `State(stateConfig: StateConfig) -> ()` - Adds a new state to the state machine.
- `Transition(stateName: string, entity: any, networked: boolean?) -> ()` - Transitions the state machine to the specified state.
- `GetState() -> string?` - Returns the name of the current state.
- `Update(entity: any) -> ()` - Updates the current state.
- `SetReplication(replicateToClients: boolean, replicateToServer: boolean) -> ()` - Sets the replication properties of the state machine.

## Interfaces

### `StateConfig`

Represents the configuration for a state in the state machine.

#### Properties

- `Name: string` - The name of the state.
- `OnEnter(entity: any) -> ()` - The function to call when entering the state.
- `OnExit(entity: any) -> ()?` - Optional. The function to call when exiting the state.
- `Update(entity: any) -> ()?` - Optional. The function to call when updating the state.

## Functions

### `CreateMachine`

Creates a new state machine with the specified parameters.

#### Parameters

- `name: string` - The name of the state machine.
- `states: { [string]: StateConfig }?` - Optional. The states of the state machine.

#### Returns

- `StateMachine` - The newly created state machine instance.

## Usage

### Creating a New State Machine

```lua
local function InitializeStateMachine(ID: string)
	local fsm = StateMachine.CreateMachine(ID)

	fsm:State({
		Name = "Passive",
		OnEnter = StateFunctions.PassiveOnEnter,
		Update = StateFunctions.PassiveUpdate, -- Update runs every heartbeat internally from the State library.
	})

	fsm:State({
		Name = "Attacking",
		OnEnter = StateFunctions.AttackingOnEnter,
		Update = StateFunctions.AttackingUpdate,
	})

	fsm:State({
		Name = "Fleeing",
		OnEnter = StateFunctions.FleeingOnEnter,
		OnExit = StateFunctions.FleeingOnExit,
		Update = StateFunctions.FleeingUpdate,
	})

	return fsm
end

local ai = {
	ID = "a-b-c",
	fsm = InitializeStateMachine(ID),
	model = workspace.AI
}

ai.fsm:SetReplication(true) -- This sets the replication from server -> client to true. Meaning when the state changes on the server, it will sync the state machine with the same ID on the client.

ai.fsm:SetReplication(false, true) -- This sets replication from client -> server to true. Same deal.

--Note that, replication can only be set from the server.

ai.fsm:Transition("Attacking", ai.model)
--Transition will call the mandatory OnEnter function you provide in the init.
```

### Managing transitions

```lua
--Ideally, you should have a module for each mob type's state function. 
local StateFunctions = {}

function StateFunctions.PassiveOnEnter(ai)
	ai.target = nil
	ai.humanoid:MoveTo(ai.HRP.Position) -- immediately stop their movement
	--stop necessary animations
end

local function ProcessCharacter(ai: AI, character: Model)
	--process your target
	ai.state.Target = character
	ai.fsm:Transition("Attacking")
end

function StateFunctions.PassiveUpdate(ai: AI)
	local closestCharacter =
		MobUtil.TargetScan(ai.model, DETECTION_DISTANCE)

	if closestCharacter then
		ProcessCharacter(ai, closestCharacter)
	end
end

function StateFunctions.AttackingOnEnter(ai: AI)
	if not ai.target then
		ai.fsm:Transition("Passive")
	else
		StateFunctions.AttackingUpdate(ai)
	end
end

function StateFunctions.AttackingUpdate(ai: AI)
	--something that should be ran every heartbeat, like attacking and movement. 
	CombatAI(ai)
end

--etc
return StateFunctions
```