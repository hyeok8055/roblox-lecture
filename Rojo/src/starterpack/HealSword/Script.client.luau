-- ╔══════════════════════════════════════════════════════════════╗
-- ║  🩷 6번: 힐 검 - 클릭하면 자기 체력 회복!                  ║
-- ╠══════════════════════════════════════════════════════════════╣
-- ║  💡 math.min(현재+30, 최대) → 100 초과 방지!               ║
-- ║  ✨ 특수효과: 핑크 빛 + 회복 스파클 파티클!                 ║
-- ╚══════════════════════════════════════════════════════════════╝

local tool = script.Parent
local UIS = game:GetService("UserInputService")
local Debris = game:GetService("Debris")

tool.Grip = CFrame.new(0, 0, -1.5, 0, 0, 1, 1, 0, 0, 0, 1, 0)

local canHeal = true
local HEAL = 30
local COOLDOWN = 3
local isEquipped = false
local SWORD_COLOR = Color3.fromRGB(255, 100, 200)  -- 핑크색

local healAnim = Instance.new("Animation")
healAnim.AnimationId = "rbxassetid://522638767"  -- 런지 애니메이션
local healTrack = nil

local swordEffects = nil

local function setupEffects(handle)
	if not handle then return end
	swordEffects = {}

	local light = Instance.new("PointLight")
	light.Color = SWORD_COLOR
	light.Brightness = 4
	light.Range = 15
	light.Name = "SwordLight"
	light.Parent = handle
	table.insert(swordEffects, light)

	local att0 = Instance.new("Attachment")
	att0.Position = Vector3.new(0, 2.5, 0)
	att0.Parent = handle
	table.insert(swordEffects, att0)

	local att1 = Instance.new("Attachment")
	att1.Position = Vector3.new(0, -0.5, 0)
	att1.Parent = handle
	table.insert(swordEffects, att1)

	local trail = Instance.new("Trail")
	trail.Attachment0 = att0
	trail.Attachment1 = att1
	trail.Color = ColorSequence.new(SWORD_COLOR)
	trail.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(1, 1)
	})
	trail.Lifetime = 0.3
	trail.MinLength = 0
	trail.Parent = handle
	table.insert(swordEffects, trail)

	-- 💡 핑크 스파클 파티클 (회복 느낌)
	local particles = Instance.new("ParticleEmitter")
	particles.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 150, 220)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
	})
	particles.LightEmission = 1
	particles.Rate = 0
	particles.SpreadAngle = Vector2.new(180, 180)
	particles.Speed = NumberRange.new(2, 6)
	particles.Lifetime = NumberRange.new(0.5, 1.0)
	particles.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.15),
		NumberSequenceKeypoint.new(0.5, 0.25),
		NumberSequenceKeypoint.new(1, 0)
	})
	particles.RotSpeed = NumberRange.new(-45, 45)
	particles.Name = "SwordParticles"
	particles.Parent = handle
	table.insert(swordEffects, particles)
end

local function cleanupEffects()
	if swordEffects then
		for _, effect in ipairs(swordEffects) do
			if effect.Parent then effect:Destroy() end
		end
		swordEffects = nil
	end
end

local function playSwing()
	if healTrack then
		healTrack:Stop()
		healTrack:Play()
	else
		local str = Instance.new("StringValue")
		str.Name = "toolanim"
		str.Value = "Lunge"
		str.Parent = tool
		Debris:AddItem(str, 0.001)
	end
	-- ✨ 회복 시 핑크 스파클 25개 burst!
	local handle = tool:FindFirstChild("Handle")
	local particles = handle and handle:FindFirstChild("SwordParticles")
	if particles then particles:Emit(25) end
end

tool.Equipped:Connect(function()
	isEquipped = true
	setupEffects(tool:FindFirstChild("Handle"))
	local humanoid = tool.Parent:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	if animator then
		healTrack = animator:LoadAnimation(healAnim)
		healTrack.Priority = Enum.AnimationPriority.Action
	end
	print("🩷 [힐검] 들었어요! (클릭 → +" .. HEAL .. " 회복, " .. COOLDOWN .. "초 쿨)")
end)

tool.Unequipped:Connect(function()
	isEquipped = false
	if healTrack then healTrack:Stop() end
	cleanupEffects()
	print("🩷 [힐검] 내려놨어요!")
end)

UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if not isEquipped then return end
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end

	if not canHeal then
		print("🩷 [힐검] 쿨타임 중!")
		return
	end

	local humanoid = tool.Parent:FindFirstChild("Humanoid")
	if not humanoid then return end

	playSwing()

	local before = humanoid.Health
	humanoid.Health = math.min(before + HEAL, humanoid.MaxHealth)
	local healed = humanoid.Health - before

	print("🩷 [힐검] +" .. math.floor(healed) .. " 회복! (" .. math.floor(before) .. " → " .. math.floor(humanoid.Health) .. ")")

	canHeal = false
	task.wait(COOLDOWN)
	canHeal = true
	print("🩷 [힐검] 쿨타임 종료!")
end)
