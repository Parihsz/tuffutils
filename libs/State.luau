-- StateMachine.lua

--[[
Author(s)   : Parihsz
Date        : 07/21/2024
Version     : 1.1.1

Description : This module provides a lightweight state machine implementation for managing the states and transitions
              of entities.

              You can create a state, attach an OnEnter (the function that will be called when the state is entered), and
              optionally, an OnExit (the function that will be called when the state is exited) and an Update (the function
              that can be called every X interval (you determine this) while the entity is in the state).

              This version includes networking functionality to synchronize state transitions across server and clients.
              State machines are referenced by name and have properties to control replication.
]]
type StateConfig = {
	Name: string,
	OnEnter: (entity: any) -> (),
	OnExit: (entity: any) -> ()?,
	Update: (entity: any) -> ()?,
}

type StateMachine = {
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
	ForceState: (self: StateMachine, stateName: string, entity: any, networked: boolean?) -> (),
	SetReplication: (self: StateMachine, replicateToClients: boolean, replicateToServer: boolean) -> (),
}

local State = {}

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

State.activeStateMachines = {}

--[[
    @param name string | The name of the state machine.
    @param states table? | The states of the state machine (optional).

    @return StateMachine | A new state machine instance.

    Creates and returns a new state machine with methods to define states, transition between them,
    and update the current state.
]]
function State.CreateMachine(name: string, states: { [string]: StateConfig }?): StateMachine
	local fsm: StateMachine = {
		states = states or {},
		currentState = nil,
		currentStateConfig = nil,
		name = name,

		replicateToClients = false,
		replicateToServer = false,

		--[[
            @param self StateMachine | The state machine instance.
            @param stateConfig StateConfig | The configuration for the new state.

            Adds a new state to the state machine. Each state must have a unique name.
        ]]
		State = function(self, stateConfig: StateConfig)
			assert(self.states[stateConfig.Name] == nil, `State already exists: {stateConfig.Name}`)
			self.states[stateConfig.Name] = stateConfig
		end,

		--[[
            @param self StateMachine | The state machine instance.
            @param stateName string | The name of the state to transition to.
            @param entity any | The entity to pass to state callbacks.
            @param networked boolean? | Whether this transition was triggered by a network event.

            Transitions the state machine to a specified state, calling the OnExit callback
            of the current state and the OnEnter callback of the new state. If `networked` is false or nil,
            it sends the transition event to other clients/servers.
        ]]
		Transition = function(self, stateName, entity, networked)
			local state = self.states[stateName]
			assert(state ~= nil, `State {stateName} does not exist.`)

			if self.currentState and self.currentState ~= stateName then
				local OnExit = self.states[self.currentState].OnExit
				if OnExit then
					OnExit(entity)
				end
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
		end,

		--[[
            @param self StateMachine | The state machine instance.
            @param stateName string | The name of the state to transition to.
            @param entity any | The entity to pass to state callbacks.
			@param networked boolean? | Whether this transition was triggered by a network event.

            Forces the state machine to the specified state without any checks.
        ]]
		ForceState = function(self, stateName, entity, networked)
			local state = self.states[stateName]
			assert(state ~= nil, `State {stateName} does not exist.`)

			if self.currentState then
				local OnExit = self.states[self.currentState].OnExit
				if OnExit then
					OnExit(entity)
				end
			end

			self.currentState = stateName
			self.currentStateConfig = state
			state.OnEnter(entity)

			if not networked and isServer and self.replicateToClients then
				stateTransitionRemote:FireAllClients(self.name, stateName, entity)
			end
		end,

		--[[
            @param self StateMachine | The state machine instance.
            @return string? | The name of the current state.

            Returns the name of the current state.
        ]]
		GetState = function(self)
			return self.currentState
		end,

		--[[
            @param self StateMachine | The state machine instance.
            @param entity any | The entity to pass to the state update callback.

            Updates the current state by calling its Update callback, if defined.
        ]]
		Update = function(self, entity)
			if self.currentStateConfig and self.currentStateConfig.Update then
				self.currentStateConfig.Update(entity)
			end
		end,

		--[[
            @param self StateMachine | The state machine instance.
            @param replicateToClients boolean | Whether to replicate to clients.
            @param replicateToServer boolean | Whether to replicate to server.

            Sets the replication properties of the state machine.
        ]]
		SetReplication = function(self, replicateToClients, replicateToServer)
			assert(isServer, "Replication properties can only be set on the server")
			self.replicateToClients = replicateToClients
			self.replicateToServer = replicateToServer

			stateReplicationRemote:FireAllClients(self.name, replicateToClients, replicateToServer)
		end,
	}

	State.activeStateMachines[fsm.name] = fsm

	return fsm
end

if isServer then
	stateTransitionRemote.OnServerEvent:Connect(function(player, name, stateName, entity)
		local stateMachine = State.activeStateMachines[name]
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
		local stateMachine = State.activeStateMachines[name]
		if stateMachine then
			stateMachine:ForceState(stateName, entity, true)
		else
			warn(`Missing StateMachine on client: {name}`)
		end
	end)

	stateReplicationRemote.OnClientEvent:Connect(function(name, replicateToClients, replicateToServer)
		local stateMachine = State.activeStateMachines[name]
		if stateMachine then
			stateMachine.replicateToClients = replicateToClients
			stateMachine.replicateToServer = replicateToServer
		else
			warn(`Missing StateMachine on client: {name}`)
		end
	end)
end

return State
