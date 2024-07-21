--[[
Author(s)   : Parihsz
Date        : 07/21/2024
Version     : 1.0.0

Description : This module defines the DotType, which represents a 3D dot projected onto a 2D GUI.
              It provides functionality to create and project the dot based on various parameters
              such as size, speed, and perspective.

Details: https://github.com/Parihsz/Dot
]]

export type DotType = {
	uiElement: GuiObject,
	originalSize: UDim2,
	radius: number,
	theta: number,
	phi: number,
	central: GuiObject,
	sizeMultiplier: number,
	speed: number,
	perspective: number,
	hovering: boolean,
	Project: (self: DotType, deltaTime: number, hovering: boolean) -> (),
}

--[[
    @param uiElement GuiObject | The UI element representing the dot.
    @param serial number | The serial number of the dot, used for calculating its position.
    @param centralUI GuiObject | The central UI element around which the dot orbits.
    @param sizeMultiplier number? | Optional. Multiplier for the dot's size.
    @param speed number? | Optional. Speed of the dot's rotation.
    @param perspective number? | Optional. Perspective factor for the dot's projection.
    @param radius number? | Optional. Radius of the dot's orbit.
    @param n number? | Optional. Number of dots in the system, used for position calculation.
    @return DotType | The newly created dot instance.

    Creates a new dot instance with the specified parameters.
]]
local function new(
	uiElement: GuiObject,
	serial: number,
	centralUI: GuiObject,
	sizeMultiplier: number?,
	speed: number?,
	perspective: number?,
	radius: number?,
	n: number?
): DotType
	local theta = 0
	local phiStep = math.pi * 2 / (n or 5)
	local phi = phiStep * serial
	local hoveredSizeMultiplier = tonumber(sizeMultiplier) or 1
	hoveredSizeMultiplier = hoveredSizeMultiplier * 1.1

	--[[
        @param self DotType | The dot instance.
        @param deltaTime number | The time delta for the projection update.
        @param hovering boolean | Whether the dot is being hovered over.
        
        Projects the dot's position and size based on its current parameters and updates the UI element.
    ]]
	local function Project(self: DotType, deltaTime: number, hovering: boolean)
		local speedMultiplier = hovering and 0 or 0.2
		self.theta = (self.theta + self.speed * deltaTime * speedMultiplier) % (2 * math.pi)

		local z = self.radius * math.sin(self.phi) * math.sin(self.theta) + self.radius
		local scaleProjected = self.perspective / (self.perspective + z)
		local sizeMult = self.hovering and hoveredSizeMultiplier or self.sizeMultiplier

		local scaledSizeX = self.originalSize.X.Scale * scaleProjected * sizeMult
		local scaledSizeY = self.originalSize.Y.Scale * scaleProjected * sizeMult

		self.uiElement.Position = UDim2.new(
			self.central.Position.X.Scale + (self.radius * math.sin(self.phi) * math.cos(self.theta) * scaleProjected),
			0,
			self.central.Position.Y.Scale + (self.radius * math.cos(self.phi) * scaleProjected),
			0
		)
		self.uiElement.Size = UDim2.new(scaledSizeX, 0, scaledSizeY, 0)
	end

	local dot: DotType = {
		uiElement = uiElement,
		originalSize = uiElement.Size,
		radius = radius or 0.8,
		theta = theta,
		phi = phi,
		central = centralUI,
		sizeMultiplier = sizeMultiplier or 1,
		speed = speed or 1,
		perspective = perspective or 1,
		hovering = false,
		Project = Project,
	}

	return dot
end

return {
	new = new,
}
