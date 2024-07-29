# Tween

Utility module for creating and managing tweens for UI elements. Includes preset animations such as hover, pop-out, rotate, move, show, hide, scale-up, and scale-down.

## Interfaces

### `TweenOptions`

Represents options for configuring a tween.

#### Properties

- `duration: number?` - The duration of the tween.
- `easingStyle: Enum.EasingStyle?` - The easing style of the tween.
- `easingDirection: Enum.EasingDirection?` - The easing direction of the tween.

### `TweenProperties`

Represents the properties to tween for an instance.

#### Properties

- `[string]: any` - The properties to tween.

## Methods

### `Tween`

Creates a tween for the given instance with specified properties and options.

#### Parameters

- `instance: Instance` - The instance to tween.
- `properties: TweenProperties` - The properties to tween.
- `options: TweenOptions?` - Optional. The tween options including duration, easing style, and direction.

#### Returns

- `Tween` - The created tween.

```lua
local Tween = require(Tween)

local part = Instance.new("Part")
part.Parent = workspace

local tween = Tween.Tween(part, { Transparency = 0.5 }, { duration = 1 })
tween:Play()

local button = script.Parent

local hoverTweens = Tween.Presets.Hover({ button }, 0.1, { duration = 0.2 })

button.MouseEnter:Connect(function()
    Tween.Play(hoverTweens.hover)
end)

button.MouseLeave:Connect(function()
    Tween.Play(hoverTweens.unhover)
end)

## Presets

### `Hover`

Creates hover and unhover tweens for a set of UI objects.

#### Parameters

- `instances: { GuiObject }` - The UI objects to apply the hover effect to.
- `hoverSizeGain: number` - The amount by which the size of the UI objects should increase on hover.
- `options: TweenOptions?` - Optional. The tween options including duration, easing style, and direction.

#### Returns

- `{ hover: { Tween }, unhover: { Tween } }` - The hover and unhover tweens.

### `PopOut`

Creates a pop-out tween for a set of UI objects.

#### Parameters

- `instances: { GuiObject }` - The UI objects to pop out.
- `options: TweenOptions?` - Optional. The tween options including duration, easing style, and direction.

#### Returns

- `{ Tween }` - The pop-out tweens.

### `Rotate`

Creates a rotate tween for a UI object.

#### Parameters

- `instance: GuiObject` - The UI object to rotate.
- `targetAngle: number` - The target angle to rotate to.
- `options: TweenOptions?` - Optional. The tween options including duration, easing style, and direction.

#### Returns

- `Tween` - The rotate tween.

### `Move`

Creates a move tween for a UI object.

#### Parameters

- `instance: GuiObject` - The UI object to move.
- `targetPosition: UDim2` - The target position to move to.
- `options: TweenOptions?` - Optional. The tween options including duration, easing style, and direction.

#### Returns

- `Tween` - The move tween.

### `Show`

Creates a show tween for a UI object.

#### Parameters

- `instance: GuiObject` - The UI object to show.
- `options: TweenOptions?` - Optional. The tween options including duration, easing style, and direction.

#### Returns

- `Tween` - The show tween.

### `Hide`

Creates a hide tween for a UI object.

#### Parameters

- `instance: GuiObject` - The UI object to hide.
- `options: TweenOptions?` - Optional. The tween options including duration, easing style, and direction.

#### Returns

- `Tween` - The hide tween.

### `ScaleUp`

Creates a scale-up tween for a UI object.

#### Parameters

- `instance: GuiObject` - The UI object to scale up.
- `scaleGain: number` - The amount by which to scale up the size.
- `options: TweenOptions?` - Optional. The tween options including duration, easing style, and direction.

#### Returns

- `Tween` - The scale-up tween.

### `ScaleDown`

Creates a scale-down tween for a UI object.

#### Parameters

- `instance: GuiObject` - The UI object to scale down.
- `scaleLoss: number` - The amount by which to scale down the size.
- `options: TweenOptions?` - Optional. The tween options including duration, easing style, and direction.

#### Returns

- `Tween` - The scale-down tween.
