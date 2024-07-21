--[[
Author(s)   : Parihsz
Date        : 07/21/2024
Version     : 1.0.0

Description : This module provides a lightweight state machine implementation for managing the states and transitions
              of entities.

              You can create a state, attach an OnEnter (the function that will be called when the state is entered), and
                optionally, an OnExit (the function that will be called when the state is exited) and an Update (the function
                that can be called every X interval (you determine this) while the entity is in the state).

]]

local State = {}

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
	State: (self: StateMachine, stateConfig: StateConfig) -> (),
	Transition: (self: StateMachine, stateName: string, entity: any) -> (),
	GetState: (self: StateMachine) -> string?,
	Update: (self: StateMachine, entity: any) -> (),
}

--[[
    @return StateMachine | A new state machine instance.

    Creates and returns a new state machine with methods to define states, transition between them,
    and update the current state.
]]
function State.CreateMachine(): StateMachine
	local fsm: StateMachine = {
		states = {},
		currentState = nil,
		currentStateConfig = nil,
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

            Transitions the state machine to the specified state, calling the OnExit callback
            of the current state and the OnEnter callback of the new state.
        ]]
		Transition = function(self, stateName, entity)
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
	}
	return fsm
end

return State
