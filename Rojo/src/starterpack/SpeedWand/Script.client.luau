-- ╔══════════════════════════════════════════════════════════════╗
-- ║  💛 스피드 지팡이 - 5초간 WalkSpeed 3배!                   ║
-- ╠══════════════════════════════════════════════════════════════╣
-- ║  Humanoid.WalkSpeed 조작 / 8초 쿨다운                       ║
-- ╚══════════════════════════════════════════════════════════════╝

local tool = script.Parent
local UIS = game:GetService("UserInputService")

tool.Grip = CFrame.new(0, 0, -1.5, 0, 0, 1, 1, 0, 0, 0, 1, 0)

local canUse = true
local SPEED_MULT = 3
local BOOST_TIME = 5
local COOLDOWN = 8
local isEquipped = false
local isBoosted = false
local effects = {}

local function setupEffects(handle)
	if not handle then return end

	local attTip  = Instance.new("Attachment"); attTip.Position  = Vector3.new(0,  1.8, 0); attTip.Parent  = handle
	local attBase = Instance.new("Attachment"); attBase.Position = Vector3.new(0, -0.5, 0); attBase.Parent = handle
	local trail = Instance.new("Trail")
	trail.Attachment0    = attTip
	trail.Attachment1    = attBase
	trail.Lifetime       = 0.12
	trail.MinLength      = 0
	trail.FaceCamera     = false
	trail.LightEmission  = 1
	trail.LightInfluence = 0
	trail.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0,   Color3.fromRGB(255, 255, 200)),
		ColorSequenceKeypoint.new(0.4, Color3.fromRGB(255, 220, 50)),
		ColorSequenceKeypoint.new(1,   Color3.fromRGB(200, 140, 0)),
	})
	trail.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0,   0),
		NumberSequenceKeypoint.new(0.5, 0.1),
		NumberSequenceKeypoint.new(1,   1),
	})
	trail.Parent = handle

	-- 스피드 별똥: 뒤로 흘러가는 빠른 별 파티클
	local star = Instance.new("ParticleEmitter")
	star.Texture     = "rbxasset://textures/particles/sparkles_main.dds"
	star.Color       = ColorSequence.new({
		ColorSequenceKeypoint.new(0,   Color3.fromRGB(255, 255, 200)),
		ColorSequenceKeypoint.new(0.4, Color3.fromRGB(255, 220, 60)),
		ColorSequenceKeypoint.new(1,   Color3.fromRGB(200, 130, 0)),
	})
	star.Size        = NumberSequence.new({
		NumberSequenceKeypoint.new(0,   0.05),
		NumberSequenceKeypoint.new(0.25, 0.22),
		NumberSequenceKeypoint.new(1,   0),
	})
	star.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0,   0.3),
		NumberSequenceKeypoint.new(0.3, 0),
		NumberSequenceKeypoint.new(1,   1),
	})
	star.Rate         = 18
	star.Speed        = NumberRange.new(2, 6)
	star.SpreadAngle  = Vector2.new(55, 55)
	star.Lifetime     = NumberRange.new(0.3, 0.7)
	star.RotSpeed     = NumberRange.new(-180, 180)
	star.Acceleration = Vector3.new(0, 5, 0)   -- 빠른 에너지는 위로!
	star.LightEmission  = 1
	star.LightInfluence = 0
	star.LockedToPart   = false
	star.Name           = "Star"
	star.Parent         = handle

	-- 노란 글로우 연기
	local glow = Instance.new("ParticleEmitter")
	glow.Texture     = "rbxasset://textures/particles/smoke_main.dds"
	glow.Color       = ColorSequence.new({
		ColorSequenceKeypoint.new(0,   Color3.fromRGB(255, 240, 150)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 200, 60)),
		ColorSequenceKeypoint.new(1,   Color3.fromRGB(200, 140, 0)),
	})
	glow.Size        = NumberSequence.new({
		NumberSequenceKeypoint.new(0,   0.05),
		NumberSequenceKeypoint.new(0.4, 0.38),
		NumberSequenceKeypoint.new(1,   0.55),
	})
	glow.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0,   0.55),
		NumberSequenceKeypoint.new(0.5, 0.75),
		NumberSequenceKeypoint.new(1,   1),
	})
	glow.Rate         = 6
	glow.Speed        = NumberRange.new(0.3, 1.2)
	glow.SpreadAngle  = Vector2.new(22, 22)
	glow.Lifetime     = NumberRange.new(0.5, 1.0)
	glow.RotSpeed     = NumberRange.new(-20, 20)
	glow.Acceleration = Vector3.new(0, 2.5, 0)
	glow.LightEmission  = 0.9
	glow.LightInfluence = 0.1
	glow.LockedToPart   = false
	glow.Name           = "Glow"
	glow.Parent         = handle

	effects = {attTip, attBase, trail, star, glow}
end

local function cleanupEffects()
	for _, e in ipairs(effects) do if e.Parent then e:Destroy() end end
	effects = {}
end

local function playWave()
	local h = tool:FindFirstChild("Handle")
	local st = h and h:FindFirstChild("Star")
	local gl = h and h:FindFirstChild("Glow")
	if st then st:Emit(45) end
	if gl then gl:Emit(14) end
end

tool.Equipped:Connect(function()
	isEquipped = true; canUse = true
	setupEffects(tool:FindFirstChild("Handle"))
	print("💛 [스피드완드] 장착! (클릭 → " .. BOOST_TIME .. "초간 " .. SPEED_MULT .. "배 속도)")
end)

tool.Unequipped:Connect(function()
	isEquipped = false
	cleanupEffects()
	print("💛 [스피드완드] 해제!")
end)

UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or not isEquipped then return end
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
	if not canUse then print("💛 [스피드완드] 쿨타임 중!"); return end
	if isBoosted then print("💛 [스피드완드] 이미 부스트 중!"); return end
	canUse = false
	playWave()

	local character = tool.Parent
	local hum = character:FindFirstChildOfClass("Humanoid")
	if hum then
		local origSpeed = hum.WalkSpeed
		isBoosted = true
		hum.WalkSpeed = origSpeed * SPEED_MULT
		print("💛 [스피드완드] 속도 " .. origSpeed .. " → " .. hum.WalkSpeed .. "! (" .. BOOST_TIME .. "초)")

		task.spawn(function()
			task.wait(BOOST_TIME)
			if hum.Parent then hum.WalkSpeed = origSpeed end
			isBoosted = false
			print("💛 [스피드완드] 속도 원상복구!")
		end)
	end

	task.wait(COOLDOWN); canUse = true
	print("💛 [스피드완드] 쿨타임 종료!")
end)
