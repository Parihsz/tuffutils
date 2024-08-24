local TweenService = game:GetService("TweenService")

export type TweenOptions = {
	duration: number?,
	easingStyle: Enum.EasingStyle?,
	easingDirection: Enum.EasingDirection?,
}

export type TweenProperties = { [string]: any }

local Util = {}

function Util.Tween(instance: Instance, properties: TweenProperties, options: TweenOptions?): Tween
	options = options or {}
	local tweenInfo = TweenInfo.new(
		options.duration or 0.3,
		options.easingStyle or Enum.EasingStyle.Quad,
		options.easingDirection or Enum.EasingDirection.Out
	)
	return TweenService:Create(instance, tweenInfo, properties)
end

function Util.Play(tweens: { Tween })
	for _, tween in tweens do
		tween:Play()
	end
end

Util.Presets = {
	Hover = function(
		instances: { GuiObject },
		hoverSizeGain: number,
		options: TweenOptions?
	): { hover: { Tween }, unhover: { Tween } }
		options = options or {}
		local hoverTweens = {}
		local unhoverTweens = {}
		for _, instance in instances do
			if not instance:IsA("GuiObject") then
				continue
			end

			local originalSize = instance.Size
			local hoverSize = originalSize + UDim2.new(hoverSizeGain, 0, hoverSizeGain, 0)

			local finalOptions = {
				duration = options.duration or 0.2,
				easingStyle = options.easingStyle or Enum.EasingStyle.Cubic,
				easingDirection = options.easingDirection or Enum.EasingDirection.Out,
			}

			table.insert(hoverTweens, Util.Tween(instance, { Size = hoverSize }, finalOptions))
			table.insert(unhoverTweens, Util.Tween(instance, { Size = originalSize }, finalOptions))
		end
		return { hover = hoverTweens, unhover = unhoverTweens }
	end,

	PopOut = function(instances: { GuiObject }, options: TweenOptions?): { Tween }
		options = options or {}
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
					duration = options.duration or 0.3,
					easingStyle = options.easingStyle or Enum.EasingStyle.Elastic,
					easingDirection = options.easingDirection or Enum.EasingDirection.Out,
				})
			)
		end
		return tweens
	end,

	Rotate = function(instance: GuiObject, targetAngle: number, options: TweenOptions?): Tween
		options = options or {}
		assert(instance:IsA("GuiObject"), "Instance must be a GuiObject")

		return Util.Tween(instance, { Rotation = targetAngle }, {
			duration = options.duration or 0.3,
			easingStyle = options.easingStyle or Enum.EasingStyle.Cubic,
			easingDirection = options.easingDirection or Enum.EasingDirection.Out,
		})
	end,

	Move = function(instance: GuiObject, targetPosition: UDim2, options: TweenOptions?): Tween
		options = options or {}
		assert(instance:IsA("GuiObject"), "Instance must be a GuiObject")

		return Util.Tween(instance, { Position = targetPosition }, {
			duration = options.duration or 0.3,
			easingStyle = options.easingStyle or Enum.EasingStyle.Cubic,
			easingDirection = options.easingDirection or Enum.EasingDirection.Out,
		})
	end,

	Show = function(instance: GuiObject, options: TweenOptions?): Tween
		options = options or {}
		assert(instance:IsA("GuiObject"), "Instance must be a GuiObject")

		instance.Visible = true

		return Util.Tween(instance, { BackgroundTransparency = 0 }, {
			duration = options.duration or 0.3,
			easingStyle = options.easingStyle or Enum.EasingStyle.Quad,
			easingDirection = options.easingDirection or Enum.EasingDirection.Out,
		})
	end,

	Hide = function(instance: GuiObject, options: TweenOptions?): Tween
		options = options or {}
		assert(instance:IsA("GuiObject"), "Instance must be a GuiObject")

		local finalOptions = {
			duration = options.duration or 0.3,
			easingStyle = options.easingStyle or Enum.EasingStyle.Quad,
			easingDirection = options.easingDirection or Enum.EasingDirection.Out,
		}

		return Util.Tween(instance, { BackgroundTransparency = 1 }, finalOptions)
	end,

	ScaleUp = function(instance: GuiObject, scaleGain: number, options: TweenOptions?): Tween
		options = options or {} - assert(instance:IsA("GuiObject"), "Instance must be a GuiObject")

		local originalSize = instance.Size
		local targetSize = originalSize + UDim2.new(scaleGain, 0, scaleGain, 0)

		return Util.Tween(instance, { Size = targetSize }, {
			duration = options.duration or 0.3,
			easingStyle = options.easingStyle or Enum.EasingStyle.Quad,
			easingDirection = options.easingDirection or Enum.EasingDirection.Out,
		})
	end,

	ScaleDown = function(instance: GuiObject, scaleLoss: number, options: TweenOptions?): Tween
		options = options or {}
		assert(instance:IsA("GuiObject"), "Instance must be a GuiObject")

		local originalSize = instance.Size
		local targetSize = originalSize - UDim2.new(scaleLoss, 0, scaleLoss, 0)

		return Util.Tween(instance, { Size = targetSize }, {
			duration = options.duration or 0.3,
			easingStyle = options.easingStyle or Enum.EasingStyle.Quad,
			easingDirection = options.easingDirection or Enum.EasingDirection.Out,
		})
	end,
}

return Util
