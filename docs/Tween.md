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
```

