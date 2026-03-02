-- ╔══════════════════════════════════════════════════════════════╗
-- ║  💚 힐 완드 - 앞으로 치유 구체 발사! 닿으면 체력 +30       ║
-- ╠══════════════════════════════════════════════════════════════╣
-- ║  꾹 누르면 연속 발사 / BodyVelocity로 전방 날아감           ║
-- ╚══════════════════════════════════════════════════════════════╝

local tool = script.Parent
local UIS = game:GetService("UserInputService")
local Debris = game:GetService("Debris")

tool.Grip = CFrame.new(0, 0, -1.5, 0, 0, 1, 1, 0, 0, 0, 1, 0)

local HEAL_AMOUNT  = 30
local PROJ_SPEED   = 45
local FIRE_RATE    = 0.35  -- 꾹 누를 때 발사 간격
local isEquipped   = false
local isHolding    = false

-- 발사체 1개 생성
local function shootProjectile()
	local character = tool.Parent
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	-- 💡 발사체 파트 생성 (공 모양)
	local proj = Instance.new("Part")
	proj.Name        = "HealOrb"
	proj.Size        = Vector3.new(0.6, 0.6, 0.6)
	proj.Shape       = Enum.PartType.Ball
	proj.Color       = Color3.fromRGB(100, 255, 150)
	proj.Material    = Enum.Material.Neon
	proj.CanCollide  = false
	proj.CastShadow  = false
	-- 💡 캐릭터 앞쪽에서 출발!
	proj.CFrame      = hrp.CFrame * CFrame.new(0, 0.5, -3)
	proj.Parent      = workspace

	-- 💡 발사체에 붙는 파티클 (잔상 효과)
	local emitter = Instance.new("ParticleEmitter")
	emitter.Texture        = "rbxasset://textures/particles/sparkles_main.dds"
	emitter.Color          = ColorSequence.new({
		ColorSequenceKeypoint.new(0,   Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(150, 255, 150)),
		ColorSequenceKeypoint.new(1,   Color3.fromRGB(0,   200, 80)),
	})
	emitter.Size           = NumberSequence.new({
		NumberSequenceKeypoint.new(0,   0.15),
		NumberSequenceKeypoint.new(0.5, 0.3),
		NumberSequenceKeypoint.new(1,   0),
	})
	emitter.Transparency   = NumberSequence.new({
		NumberSequenceKeypoint.new(0,   0),
		NumberSequenceKeypoint.new(0.6, 0.3),
		NumberSequenceKeypoint.new(1,   1),
	})
	emitter.Rate           = 30
	emitter.Speed          = NumberRange.new(0.5, 1.5)
	emitter.SpreadAngle    = Vector2.new(20, 20)
	emitter.Lifetime       = NumberRange.new(0.15, 0.35)
	emitter.LightEmission  = 1
	emitter.LightInfluence = 0
	emitter.LockedToPart   = true  -- 💡 발사체에 달라붙어서 같이 날아감!
	emitter.Parent         = proj

	-- 💡 전방으로 날아가는 속도!
	local bv = Instance.new("BodyVelocity")
	bv.Velocity  = hrp.CFrame.LookVector * PROJ_SPEED
	bv.MaxForce  = Vector3.new(1e5, 1e5, 1e5)
	bv.Parent    = proj

	-- 💡 닿으면 체력 회복!
	local didHit = false
	proj.Touched:Connect(function(other)
		if didHit then return end
		if other.Parent == character then return end  -- 자기 자신 제외
		local hum = other.Parent:FindFirstChildOfClass("Humanoid")
		if hum and hum.Health > 0 then
			didHit = true
			hum.Health = math.min(hum.Health + HEAL_AMOUNT, hum.MaxHealth)
			print("💚 [힐완드] " .. other.Parent.Name .. " +" .. HEAL_AMOUNT .. " 회복!")
			proj:Destroy()
		end
	end)

	-- 💡 4초 후 자동 제거 (안 맞으면)
	Debris:AddItem(proj, 4)
end

tool.Equipped:Connect(function()
	isEquipped = true
	print("💚 [힐완드] 장착! (클릭/꾹누르면 치유 구체 발사)")
end)

tool.Unequipped:Connect(function()
	isEquipped = false
	isHolding  = false
	print("💚 [힐완드] 해제!")
end)

-- 💡 꾹 누르면 계속 발사!
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

-- 💡 떼면 발사 중단
UIS.InputEnded:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
	isHolding = false
end)
