local TweenService = game:GetService("TweenService")

--[[
Author(s)   : Parihsz
Date        : 07/21/2024
Version     : 1.0.0

Description : Utility module for creating and managing tweens for UI elements. Includes preset animations such as 
              hover, pop-out, rotate, move, show, hide, scale-up, and scale-down.
]]

export type TweenOptions = {
	duration: number?,
	easingStyle: Enum.EasingStyle?,
	easingDirection: Enum.EasingDirection?,
}

export type TweenProperties = { [string]: any }

local Util = {}

--[[
    @param instance Instance | The instance to tween.
    @param properties TweenProperties | The properties to tween.
    @param options TweenOptions? | Optional. The tween options including duration, easing style, and direction.
    @return Tween | The created tween.

    Creates a tween for the given instance with specified properties and options.
]]
function Util.Tween(instance: Instance, properties: TweenProperties, options: TweenOptions?): Tween
	local tweenInfo = TweenInfo.new(
		options and options.duration or 0.3,
		options and options.easingStyle or Enum.EasingStyle.Quad,
		options and options.easingDirection or Enum.EasingDirection.Out
	)
	return TweenService:Create(instance, tweenInfo, properties)
end

--[[
    @param tweens { Tween } | The list of tweens to play.

    Plays all the tweens in the given list.
]]
function Util.Play(tweens: { Tween })
	for _, tween in tweens do
		tween:Play()
	end
end

Util.Presets = {
	--[[
        @param instances { GuiObject } | The list of UI elements to apply hover effect.
        @param hoverSizeGain number | The size gain when hovering.
        @param options TweenOptions? | Optional. The tween options including duration, easing style, and direction.
        @return { hover: { Tween }, unhover: { Tween } } | The hover and unhover tweens.

        Creates hover and unhover tweens for the given UI elements.
    ]]
	Hover = function(
		instances: { GuiObject },
		hoverSizeGain: number,
		options: TweenOptions?
	): { hover: { Tween }, unhover: { Tween } }
		local hoverTweens = {}
		local unhoverTweens = {}
		for _, instance in instances do
			if not instance:IsA("GuiObject") then
				continue
			end

			local originalSize = instance.Size
			local hoverSize = originalSize + UDim2.new(hoverSizeGain, 0, hoverSizeGain, 0)

			local finalOptions = {
				duration = options and options.duration or 0.2,
				easingStyle = options and options.easingStyle or Enum.EasingStyle.Cubic,
				easingDirection = options and options.easingDirection or Enum.EasingDirection.Out,
			}

			table.insert(hoverTweens, Util.Tween(instance, { Size = hoverSize }, finalOptions))
			table.insert(unhoverTweens, Util.Tween(instance, { Size = originalSize }, finalOptions))
		end
		return { hover = hoverTweens, unhover = unhoverTweens }
	end,

	--[[
        @param instances { GuiObject } | The list of UI elements to apply pop-out effect.
        @param options TweenOptions? | Optional. The tween options including duration, easing style, and direction.
        @return { Tween } | The pop-out tweens.

        Creates pop-out tweens for the given UI elements.
    ]]
	PopOut = function(instances: { GuiObject }, options: TweenOptions?): { Tween }
		local tweens = {}
		for _, instance in instances do
			if not instance:IsA("GuiObject") then
				continue
			end

			local originalSize = instance.Size
			instance.Size = UDim2.new(0, 0, 0, 0)
			instance.Visible = true

			table.insert(
				tweens,
				Util.Tween(instance, { Size = originalSize }, {
					duration = options and options.duration or 0.3,
					easingStyle = options and options.easingStyle or Enum.EasingStyle.Elastic,
					easingDirection = options and options.easingDirection or Enum.EasingDirection.Out,
				})
			)
		end
		return tweens
	end,

	--[[
        @param instance GuiObject | The UI element to rotate.
        @param targetAngle number | The target rotation angle.
        @param options TweenOptions? | Optional. The tween options including duration, easing style, and direction.
        @return Tween | The rotation tween.

        Creates a rotation tween for the given UI element.
    ]]
	Rotate = function(instance: GuiObject, targetAngle: number, options: TweenOptions?): Tween
		assert(instance:IsA("GuiObject"), "Instance must be a GuiObject")

		return Util.Tween(instance, { Rotation = targetAngle }, {
			duration = options and options.duration or 0.3,
			easingStyle = options and options.easingStyle or Enum.EasingStyle.Cubic,
			easingDirection = options and options.easingDirection or Enum.EasingDirection.Out,
		})
	end,

	--[[
        @param instance GuiObject | The UI element to move.
        @param targetPosition UDim2 | The target position.
        @param options TweenOptions? | Optional. The tween options including duration, easing style, and direction.
        @return Tween | The move tween.

        Creates a move tween for the given UI element.
    ]]
	Move = function(instance: GuiObject, targetPosition: UDim2, options: TweenOptions?): Tween
		assert(instance:IsA("GuiObject"), "Instance must be a GuiObject")

		return Util.Tween(instance, { Position = targetPosition }, {
			duration = options and options.duration or 0.3,
			easingStyle = options and options.easingStyle or Enum.EasingStyle.Cubic,
			easingDirection = options and options.easingDirection or Enum.EasingDirection.Out,
		})
	end,

	--[[
        @param instance GuiObject | The UI element to show.
        @param options TweenOptions? | Optional. The tween options including duration, easing style, and direction.
        @return Tween | The show tween.

        Creates a show tween for the given UI element.
    ]]
	Show = function(instance: GuiObject, options: TweenOptions?): Tween
		assert(instance:IsA("GuiObject"), "Instance must be a GuiObject")

		instance.Visible = true

		return Util.Tween(instance, { BackgroundTransparency = 0 }, {
			duration = options and options.duration or 0.3,
			easingStyle = options and options.easingStyle or Enum.EasingStyle.Quad,
			easingDirection = options and options.easingDirection or Enum.EasingDirection.Out,
		})
	end,

	--[[
        @param instance GuiObject | The UI element to hide.
        @param options TweenOptions? | Optional. The tween options including duration, easing style, and direction.
        @return Tween | The hide tween.

        Creates a hide tween for the given UI element.
    ]]
	Hide = function(instance: GuiObject, options: TweenOptions?): Tween
		assert(instance:IsA("GuiObject"), "Instance must be a GuiObject")

		local finalOptions = {
			duration = options and options.duration or 0.3,
			easingStyle = options and options.easingStyle or Enum.EasingStyle.Quad,
			easingDirection = options and options.easingDirection or Enum.EasingDirection.Out,
		}

		return Util.Tween(instance, { BackgroundTransparency = 1 }, finalOptions)
	end,

	--[[
        @param instance GuiObject | The UI element to scale up.
        @param scaleGain number | The amount to scale up.
        @param options TweenOptions? | Optional. The tween options including duration, easing style, and direction.
        @return Tween | The scale-up tween.

        Creates a scale-up tween for the given UI element.
    ]]
	ScaleUp = function(instance: GuiObject, scaleGain: number, options: TweenOptions?): Tween
		assert(instance:IsA("GuiObject"), "Instance must be a GuiObject")

		local originalSize = instance.Size
		local targetSize = originalSize + UDim2.new(scaleGain, 0, scaleGain, 0)

		return Util.Tween(instance, { Size = targetSize }, {
			duration = options and options.duration or 0.3,
			easingStyle = options and options.easingStyle or Enum.EasingStyle.Quad,
			easingDirection = options and options.easingDirection or Enum.EasingDirection.Out,
		})
	end,

	--[[
        @param instance GuiObject | The UI element to scale down.
        @param scaleLoss number | The amount to scale down.
        @param options TweenOptions? | Optional. The tween options including duration, easing style, and direction.
        @return Tween | The scale-down tween.

        Creates a scale-down tween for the given UI element.
    ]]
	ScaleDown = function(instance: GuiObject, scaleLoss: number, options: TweenOptions?): Tween
		assert(instance:IsA("GuiObject"), "Instance must be a GuiObject")

		local originalSize = instance.Size
		local targetSize = originalSize - UDim2.new(scaleLoss, 0, scaleLoss, 0)

		return Util.Tween(instance, { Size = targetSize }, {
			duration = options and options.duration or 0.3,
			easingStyle = options and options.easingStyle or Enum.EasingStyle.Quad,
			easingDirection = options and options.easingDirection or Enum.EasingDirection.Out,
		})
	end,
}

return Util
