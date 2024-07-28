# Dot

This module defines the `DotType`, which represents a 3D dot projected onto a 2D GUI. It provides functionality to create and project the dot based on various parameters such as size, speed, and perspective.

## Interfaces

### `DotType`

Represents the parameters of a dot instance.

#### Properties

- `uiElement: GuiObject` - The UI element representing the dot.
- `originalSize: UDim2` - The original size of the dot.
- `radius: number` - The radius of the dot's orbit.
- `theta: number` - The current angle of rotation.
- `phi: number` - The angle of the dot's orbit.
- `central: GuiObject` - The central UI element around which the dot orbits.
- `sizeMultiplier: number` - The multiplier for the dot's size.
- `speed: number` - The speed of the dot's rotation.
- `perspective: number` - The perspective factor for the dot's projection.
- `hovering: boolean` - Whether the dot is being hovered over.

#### Methods

- `Project(self: DotType, deltaTime: number, hovering: boolean) -> ()` - Projects the dot's position and size.

## Functions

### `new`

Creates a new dot instance with the specified parameters.

#### Parameters

- `uiElement: GuiObject` - The UI element representing the dot.
- `serial: number` - The serial number of the dot, used for calculating its position.
- `centralUI: GuiObject` - The central UI element around which the dot orbits.
- `sizeMultiplier: number?` - Optional. Multiplier for the dot's size.
- `speed: number?` - Optional. Speed of the dot's rotation.
- `perspective: number?` - Optional. Perspective factor for the dot's projection.
- `radius: number?` - Optional. Radius of the dot's orbit.
- `n: number?` - Optional. Number of dots in the system, used for position calculation.

#### Returns

- `DotType` - The newly created dot instance.

## Usage

### Creating and Projection

```lua
local Dot = require(Dot)

local dot = Dot.new(uiElement, 1, centralUI, 1.5, 2, 1, 0.8, 5)

game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
    local hovering = IsHovering(uiElement)
    dot:Project(deltaTime, hovering)
end)
```