--!native
--!optimize 2

local StateModule = {}

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local isServer = RunService:IsServer()
local isClient = RunService:IsClient()

local stateTransitionRemote
local stateMachineDestroyRemote
local stateReplicationRemote

if isServer then
	stateTransitionRemote = Instance.new("RemoteEvent")
	stateTransitionRemote.Name = "StateTransitionRemote"
	stateTransitionRemote.Parent = ReplicatedStorage

	stateMachineDestroyRemote = Instance.new("RemoteEvent")
	stateMachineDestroyRemote.Name = "StateMachineDestroyRemote"
	stateMachineDestroyRemote.Parent = ReplicatedStorage

	stateReplicationRemote = Instance.new("RemoteEvent")
	stateReplicationRemote.Name = "StateReplicationRemote"
	stateReplicationRemote.Parent = ReplicatedStorage
else
	stateTransitionRemote = ReplicatedStorage:WaitForChild("StateTransitionRemote") :: RemoteEvent
	stateMachineDestroyRemote = ReplicatedStorage:WaitForChild("StateMachineDestroyRemote") :: RemoteEvent
	stateReplicationRemote = ReplicatedStorage:WaitForChild("StateReplicationRemote") :: RemoteEvent
end

StateModule.activeStateMachines = {}

type StateConfig = {
	Name: string,
	OnEnter: (entity: any) -> (),
	OnExit: (entity: any) -> ()?,
	Update: (entity: any) -> ()?,
}

export type StateMachine = {
	states: { [string]: StateConfig },
	currentState: string?,
	currentStateConfig: StateConfig?,
	name: string,
	replicateToClients: boolean,
	replicateToServer: boolean,
	State: (self: StateMachine, stateConfig: StateConfig) -> (),
	Transition: (self: StateMachine, stateName: string, entity: any, networked: boolean?) -> (),
	GetState: (self: StateMachine) -> string?,
	Update: (self: StateMachine, entity: any) -> (),
	SetReplication: (self: StateMachine, replicateToClients: boolean, replicateToServer: boolean) -> (),
}

local function State(self: StateMachine, stateConfig: StateConfig)
	assert(self.states[stateConfig.Name] == nil, `State already exists: {stateConfig.Name}`)
	self.states[stateConfig.Name] = stateConfig
end

local function Transition(self: StateMachine, stateName: string, entity: any, networked: boolean?)
	local state = self.states[stateName]
	assert(state ~= nil, `State {stateName} does not exist.`)

	if self.currentState and self.currentState ~= stateName then
		local OnExit = self.states[self.currentState].OnExit
		if OnExit then
			OnExit(entity)
		end
	else
		warn("Already in this state!")
	end

	self.currentState = stateName
	self.currentStateConfig = state
	state.OnEnter(entity)

	if not networked then
		if isServer and self.replicateToClients then
			stateTransitionRemote:FireAllClients(self.name, stateName, entity)
		elseif isClient and self.replicateToServer then
			stateTransitionRemote:FireServer(self.name, stateName, entity)
		end
	end
end

local function GetState(self: StateMachine): string?
	return self.currentState
end

local function Update(self: StateMachine, entity: any)
	if self.currentStateConfig and self.currentStateConfig.Update then
		self.currentStateConfig.Update(entity)
	end
end

local function SetReplication(self: StateMachine, replicateToClients: boolean, replicateToServer: boolean)
	assert(isServer, "Replication properties can only be set on the server")
	self.replicateToClients = replicateToClients
	self.replicateToServer = replicateToServer

	stateReplicationRemote:FireAllClients(self.name, replicateToClients, replicateToServer)
end

local function CreateMachine(name: string, states: { [string]: StateConfig }?): StateMachine
	local fsm: StateMachine = {
		states = states or {},
		currentState = nil,
		currentStateConfig = nil,
		name = name,
		replicateToClients = false,
		replicateToServer = false,
		State = State,
		Transition = Transition,
		GetState = GetState,
		Update = Update,
		SetReplication = SetReplication,
	}

	StateModule.activeStateMachines[fsm.name] = fsm
	return fsm
end

if isServer then
	stateTransitionRemote.OnServerEvent:Connect(function(player, name, stateName, entity)
		local stateMachine = StateModule.activeStateMachines[name]
		if stateMachine and stateMachine.replicateToServer then
			stateMachine:Transition(stateName, entity, true)
			if stateMachine.replicateToClients then
				stateTransitionRemote:FireAllClients(name, stateName, entity)
			end
		else
			warn(`Missing StateMachine for server: {name}, {player}`)
		end
	end)
else
	stateTransitionRemote.OnClientEvent:Connect(function(name, stateName, entity)
		local stateMachine = StateModule.activeStateMachines[name]
		if stateMachine then
			stateMachine:Transition(stateName, entity, true)
		else
			warn(`Missing StateMachine on client: {name}`)
		end
	end)

	stateReplicationRemote.OnClientEvent:Connect(function(name, replicateToClients, replicateToServer)
		local stateMachine = StateModule.activeStateMachines[name]
		if stateMachine then
			stateMachine.replicateToClients = replicateToClients
			stateMachine.replicateToServer = replicateToServer
		else
			warn(`Missing StateMachine on client: {name}`)
		end
	end)
end

StateModule.CreateMachine = CreateMachine

return StateModule
