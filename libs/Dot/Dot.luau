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
