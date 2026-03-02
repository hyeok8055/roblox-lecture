-- ╔══════════════════════════════════════════════════════════════╗
-- ║  ⚡ 폭풍 완드 - 번개 발사체! 닿으면 30 데미지              ║
-- ╠══════════════════════════════════════════════════════════════╣
-- ║  꾹 누르면 연속 발사 / 빠른 속도                            ║
-- ╚══════════════════════════════════════════════════════════════╝

local tool = script.Parent
local UIS = game:GetService("UserInputService")
local Debris = game:GetService("Debris")

tool.Grip = CFrame.new(0, 0, -1.5, 0, 0, 1, 1, 0, 0, 0, 1, 0)

local DAMAGE     = 30
local PROJ_SPEED = 65   -- 번개는 빠름!
local FIRE_RATE  = 0.18
local isEquipped = false
local isHolding  = false

local function shootProjectile()
	local character = tool.Parent
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local proj = Instance.new("Part")
	proj.Name        = "LightningBolt"
	proj.Size        = Vector3.new(0.4, 0.4, 0.4)
	proj.Shape       = Enum.PartType.Ball
	proj.Color       = Color3.fromRGB(180, 100, 255)
	proj.Material    = Enum.Material.Neon
	proj.CanCollide  = false
	proj.CastShadow  = false
	proj.CFrame      = hrp.CFrame * CFrame.new(0, 0.5, -3)
	proj.Parent      = workspace

	-- 💡 번개 파티클: 빠르게 사방으로 튀는 보라 스파크
	local emitter = Instance.new("ParticleEmitter")
	emitter.Texture        = "rbxasset://textures/particles/sparkles_main.dds"
	emitter.Color          = ColorSequence.new({
		ColorSequenceKeypoint.new(0,   Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(0.4, Color3.fromRGB(200, 150, 255)),
		ColorSequenceKeypoint.new(1,   Color3.fromRGB(100, 30,  220)),
	})
	emitter.Size           = NumberSequence.new({
		NumberSequenceKeypoint.new(0,   0.12),
		NumberSequenceKeypoint.new(0.4, 0.25),
		NumberSequenceKeypoint.new(1,   0),
	})
	emitter.Transparency   = NumberSequence.new({
		NumberSequenceKeypoint.new(0,   0),
		NumberSequenceKeypoint.new(0.5, 0.2),
		NumberSequenceKeypoint.new(1,   1),
	})
	emitter.Rate           = 40
	emitter.Speed          = NumberRange.new(1, 3)
	emitter.SpreadAngle    = Vector2.new(35, 35)
	emitter.Lifetime       = NumberRange.new(0.1, 0.25)
	emitter.RotSpeed       = NumberRange.new(-250, 250)
	emitter.LightEmission  = 1
	emitter.LightInfluence = 0
	emitter.LockedToPart   = true
	emitter.Parent         = proj

	local bv = Instance.new("BodyVelocity")
	bv.Velocity  = hrp.CFrame.LookVector * PROJ_SPEED
	bv.MaxForce  = Vector3.new(1e5, 1e5, 1e5)
	bv.Parent    = proj

	-- 💡 닿으면 데미지!
	local didHit = false
	proj.Touched:Connect(function(other)
		if didHit then return end
		if other.Parent == character then return end
		local hum = other.Parent:FindFirstChildOfClass("Humanoid")
		if hum and hum.Health > 0 then
			didHit = true
			hum:TakeDamage(DAMAGE)
			print("⚡ [폭풍완드] " .. other.Parent.Name .. " -" .. DAMAGE .. "!")
			proj:Destroy()
		end
	end)

	Debris:AddItem(proj, 3)
end

tool.Equipped:Connect(function()
	isEquipped = true
	print("⚡ [폭풍완드] 장착! (클릭/꾹누르면 번개 발사)")
end)

tool.Unequipped:Connect(function()
	isEquipped = false
	isHolding  = false
	print("⚡ [폭풍완드] 해제!")
end)

UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or not isEquipped then return end
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
	isHolding = true
	task.spawn(function()
		while isHolding and isEquipped do
			shootProjectile()
			task.wait(FIRE_RATE)
		end
	end)
end)

UIS.InputEnded:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
	isHolding = false
end)
