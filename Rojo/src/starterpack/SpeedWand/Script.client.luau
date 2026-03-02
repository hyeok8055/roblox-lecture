-- ╔══════════════════════════════════════════════════════════════╗
-- ║  💛 스피드 완드 - 황금 구체 발사! 닿으면 3초 슬로우        ║
-- ╠══════════════════════════════════════════════════════════════╣
-- ║  꾹 누르면 연속 발사 / 적 WalkSpeed 0 → 3초 후 복구        ║
-- ╚══════════════════════════════════════════════════════════════╝

local tool = script.Parent
local UIS = game:GetService("UserInputService")
local Debris = game:GetService("Debris")

tool.Grip = CFrame.new(0, 0, -1.5, 0, 0, 1, 1, 0, 0, 0, 1, 0)

local PROJ_SPEED = 50
local FIRE_RATE  = 0.3
local SLOW_TIME  = 3
local isEquipped = false
local isHolding  = false
local slowed     = {}  -- 이미 슬로우 걸린 캐릭터 추적

local function shootProjectile()
	local character = tool.Parent
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local proj = Instance.new("Part")
	proj.Name        = "SlowOrb"
	proj.Size        = Vector3.new(0.55, 0.55, 0.55)
	proj.Shape       = Enum.PartType.Ball
	proj.Color       = Color3.fromRGB(255, 215, 0)
	proj.Material    = Enum.Material.Neon
	proj.CanCollide  = false
	proj.CastShadow  = false
	proj.CFrame      = hrp.CFrame * CFrame.new(0, 0.5, -3)
	proj.Parent      = workspace

	-- 💡 황금빛 별 잔상
	local emitter = Instance.new("ParticleEmitter")
	emitter.Texture        = "rbxasset://textures/particles/sparkles_main.dds"
	emitter.Color          = ColorSequence.new({
		ColorSequenceKeypoint.new(0,   Color3.fromRGB(255, 255, 200)),
		ColorSequenceKeypoint.new(0.4, Color3.fromRGB(255, 210, 50)),
		ColorSequenceKeypoint.new(1,   Color3.fromRGB(180, 120, 0)),
	})
	emitter.Size           = NumberSequence.new({
		NumberSequenceKeypoint.new(0,   0.12),
		NumberSequenceKeypoint.new(0.4, 0.28),
		NumberSequenceKeypoint.new(1,   0),
	})
	emitter.Transparency   = NumberSequence.new({
		NumberSequenceKeypoint.new(0,   0),
		NumberSequenceKeypoint.new(0.5, 0.2),
		NumberSequenceKeypoint.new(1,   1),
	})
	emitter.Rate           = 35
	emitter.Speed          = NumberRange.new(0.5, 2)
	emitter.SpreadAngle    = Vector2.new(25, 25)
	emitter.Lifetime       = NumberRange.new(0.15, 0.3)
	emitter.RotSpeed       = NumberRange.new(-200, 200)
	emitter.LightEmission  = 1
	emitter.LightInfluence = 0
	emitter.LockedToPart   = true
	emitter.Parent         = proj

	local bv = Instance.new("BodyVelocity")
	bv.Velocity  = hrp.CFrame.LookVector * PROJ_SPEED
	bv.MaxForce  = Vector3.new(1e5, 1e5, 1e5)
	bv.Parent    = proj

	-- 💡 닿으면 슬로우!
	local didHit = false
	proj.Touched:Connect(function(other)
		if didHit then return end
		if other.Parent == character then return end
		local hum = other.Parent:FindFirstChildOfClass("Humanoid")
		if hum and hum.Health > 0 and not slowed[hum] then
			didHit = true
			slowed[hum] = true
			local origSpeed = hum.WalkSpeed
			local origJump  = hum.JumpPower
			hum.WalkSpeed = 0
			hum.JumpPower = 0
			print("💛 [스피드완드] " .. other.Parent.Name .. " 슬로우! (" .. SLOW_TIME .. "초)")
			proj:Destroy()

			-- 💡 3초 후 복구
			task.spawn(function()
				task.wait(SLOW_TIME)
				if hum.Parent then
					hum.WalkSpeed = origSpeed
					hum.JumpPower = origJump
					print("💛 [스피드완드] " .. other.Parent.Name .. " 슬로우 해제!")
				end
				slowed[hum] = nil
			end)
		end
	end)

	Debris:AddItem(proj, 4)
end

tool.Equipped:Connect(function()
	isEquipped = true
	print("💛 [스피드완드] 장착! (클릭/꾹누르면 슬로우 구체 발사)")
end)

tool.Unequipped:Connect(function()
	isEquipped = false
	isHolding  = false
	print("💛 [스피드완드] 해제!")
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
