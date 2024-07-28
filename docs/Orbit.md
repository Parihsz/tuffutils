## Orbit 
This module manages `Dot` objects, which are 3D points projected onto a 2D GUI. Each Dot orbits around a central GUI element, with parameters such as size, speed, and perspective affecting its behavior.

### Interfaces

#### `DotType`
Defines properties and behaviors of a Dot within its orbit.

##### Properties
- `uiElement: GuiObject` - GUI representation of the Dot.
- `originalSize: UDim2` - Initial size of the Dot.
- `radius: number` - Orbital radius from the central point.
- `theta: number` - Current angular position in orbit.
- `phi: number` - Orbital plane angle.
- `central: GuiObject` - Central GUI element that the Dot orbits around.
- `sizeMultiplier: number` - Factor to scale the Dot's size dynamically.
- `speed: number` - Orbital speed of the Dot.
- `perspective: number` - Influences the projection of the Dot onto the GUI based on depth.
- `hovering: boolean` - Indicates if the Dot is currently being hovered over by the cursor.

##### Methods
- `Project(self: DotType, deltaTime: number, hovering: boolean)` - Updates the position and size of the Dot based on elapsed time and hover state.

### Functions

#### `new`
Creates a new Dot with specified characteristics.

##### Parameters
- `uiElement: GuiObject` - GUI element for the Dot.
- `serial: number` - Unique identifier for position calculation.
- `centralUI: GuiObject` - The central element around which the Dot orbits.
- `sizeMultiplier: number?` - Optional. Adjusts the size of the Dot.
- `speed: number?` - Optional. Sets the rotation speed of the Dot.
- `perspective: number?` - Optional. Adjusts the Dot's depth effect.
- `radius: number?` - Optional. Sets the orbital radius.
- `n: number?` - Optional. Total number of Dots, used for positioning.

##### Returns
- `DotType` - A new instance of a Dot.

### Usage Example

#### Creating and Projecting a Dot

```lua
local Orbit = require(Orbit)

local dot = Orbit.new(uiElement, 1, centralUI, 1.5, 2, 1, 0.8, 5)

game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
    local hovering = IsHovering(uiElement)
    dot:Project(deltaTime, hovering)
end)
```