-- ╔══════════════════════════════════════════════════════════════╗
-- ║  🩵 얼음 검 - 3초간 적을 동결!                             ║
-- ╠══════════════════════════════════════════════════════════════╣
-- ║  WalkSpeed=0, JumpPower=0 → 3초 → 복구                     ║
-- ╚══════════════════════════════════════════════════════════════╝

local tool = script.Parent
local UIS = game:GetService("UserInputService")
local Debris = game:GetService("Debris")

tool.Grip = CFrame.new(0, 0, -1.5, 0, 0, 1, 1, 0, 0, 0, 1, 0)

local canAttack = true
local ATTACK_RANGE = 8
local isEquipped = false
local frozen = {}

local slashAnim = Instance.new("Animation")
slashAnim.AnimationId = "rbxassetid://522635514"
local slashTrack = nil
local effects = {}

local function setupEffects(handle)
	if not handle then return end

	-- Trail: 차가운 하늘색 잔상
	local attTip  = Instance.new("Attachment"); attTip.Position  = Vector3.new(0,  2.2, 0); attTip.Parent  = handle
	local attBase = Instance.new("Attachment"); attBase.Position = Vector3.new(0, -0.8, 0); attBase.Parent = handle
	local trail = Instance.new("Trail")
	trail.Attachment0    = attTip
	trail.Attachment1    = attBase
	trail.Lifetime       = 0.13     -- 불보다 살짝 더 오래 (얼음 잔상)
	trail.MinLength      = 0
	trail.FaceCamera     = false
	trail.LightEmission  = 0.7
	trail.LightInfluence = 0.3
	trail.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0,   Color3.fromRGB(240, 255, 255)),  -- 선두: 거의 흰색
		ColorSequenceKeypoint.new(0.35, Color3.fromRGB(100, 210, 255)), -- 하늘색
		ColorSequenceKeypoint.new(1,   Color3.fromRGB(30,  80, 200)),   -- 꼬리: 깊은 파랑
	})
	trail.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0,   0),
		NumberSequenceKeypoint.new(0.6, 0.2),
		NumberSequenceKeypoint.new(1,   1),
	})
	trail.Parent = handle

	-- 얼음 결정체: sparkles = 날카로운 별 모양 → 결정처럼 보임
	-- RotSpeed 크게 = 결정이 빙글빙글 → 빛나는 느낌
	-- Acceleration 살짝 아래 = 결정이 천천히 낙하
	local crystals = Instance.new("ParticleEmitter")
	crystals.Texture     = "rbxasset://textures/particles/sparkles_main.dds"
	crystals.Color       = ColorSequence.new({
		ColorSequenceKeypoint.new(0,   Color3.fromRGB(255, 255, 255)),  -- 흰색 코어
		ColorSequenceKeypoint.new(0.4, Color3.fromRGB(160, 230, 255)),  -- 차가운 하늘색
		ColorSequenceKeypoint.new(1,   Color3.fromRGB(50,  100, 220)),  -- 짙은 파랑
	})
	crystals.Size        = NumberSequence.new({
		NumberSequenceKeypoint.new(0,   0.04),
		NumberSequenceKeypoint.new(0.2, 0.22),  -- 결정이 순간 나타남
		NumberSequenceKeypoint.new(0.65, 0.14),
		NumberSequenceKeypoint.new(1,   0),
	})
	crystals.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0,   0.6),
		NumberSequenceKeypoint.new(0.25, 0),    -- 완전 불투명 (선명)
		NumberSequenceKeypoint.new(0.75, 0.3),
		NumberSequenceKeypoint.new(1,   1),
	})
	crystals.Rate         = 18
	crystals.Speed        = NumberRange.new(1.5, 4)
	crystals.SpreadAngle  = Vector2.new(50, 50)
	crystals.Lifetime     = NumberRange.new(0.5, 1.0)
	crystals.RotSpeed     = NumberRange.new(-200, 200)  -- 빠른 회전 = 반짝이는 결정
	crystals.Acceleration = Vector3.new(0, -2.5, 0)     -- 천천히 낙하
	crystals.LightEmission  = 0.9
	crystals.LightInfluence = 0.1
	crystals.LockedToPart   = false
	crystals.Name           = "Crystals"
	crystals.Parent         = handle

	-- 냉기 안개: 매우 투명하게, 살짝 퍼지는 찬 입김 느낌
	local mist = Instance.new("ParticleEmitter")
	mist.Texture     = "rbxasset://textures/particles/smoke_main.dds"
	mist.Color       = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(200, 230, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 240, 255)),
	})
	mist.Size        = NumberSequence.new({
		NumberSequenceKeypoint.new(0,   0.08),
		NumberSequenceKeypoint.new(0.5, 0.35),
		NumberSequenceKeypoint.new(1,   0.5),
	})
	mist.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0,   0.75),
		NumberSequenceKeypoint.new(0.5, 0.85),
		NumberSequenceKeypoint.new(1,   1),
	})
	mist.Rate         = 5
	mist.Speed        = NumberRange.new(0.3, 1)
	mist.SpreadAngle  = Vector2.new(20, 20)
	mist.Lifetime     = NumberRange.new(0.7, 1.2)
	mist.RotSpeed     = NumberRange.new(-15, 15)
	mist.Acceleration = Vector3.new(0, 0.8, 0)  -- 냉기는 살짝 위로
	mist.LightEmission  = 0.2
	mist.LightInfluence = 0.7
	mist.LockedToPart   = false
	mist.Name           = "Mist"
	mist.Parent         = handle

	effects = {attTip, attBase, trail, crystals, mist}
end

local function cleanupEffects()
	for _, e in ipairs(effects) do if e.Parent then e:Destroy() end end
	effects = {}
end

local function findEnemies()
	local character = tool.Parent
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return {} end
	local result = {}
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Humanoid") and obj.Health > 0 and obj.Parent ~= character then
			local er = obj.Parent:FindFirstChild("HumanoidRootPart")
			if er and (er.Position - root.Position).Magnitude <= ATTACK_RANGE then
				table.insert(result, obj)
			end
		end
	end
	return result
end

local function playSwing()
	if slashTrack then slashTrack:Stop(); slashTrack:Play()
	else
		local s = Instance.new("StringValue"); s.Name="toolanim"; s.Value="Slash"; s.Parent=tool
		Debris:AddItem(s, 0.001)
	end
	local h = tool:FindFirstChild("Handle")
	local c = h and h:FindFirstChild("Crystals")
	local m = h and h:FindFirstChild("Mist")
	if c then c:Emit(30) end
	if m then m:Emit(8) end
end

tool.Equipped:Connect(function()
	isEquipped = true; canAttack = true
	setupEffects(tool:FindFirstChild("Handle"))
	local hum = tool.Parent:FindFirstChildOfClass("Humanoid")
	local anim = hum and hum:FindFirstChildOfClass("Animator")
	if anim then slashTrack = anim:LoadAnimation(slashAnim); slashTrack.Priority = Enum.AnimationPriority.Action end
	print("🩵 [얼음검] 장착! (클릭 → 3초 동결 + 15 데미지)")
end)

tool.Unequipped:Connect(function()
	isEquipped = false
	if slashTrack then slashTrack:Stop() end
	cleanupEffects()
	print("🩵 [얼음검] 해제!")
end)

UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or not isEquipped then return end
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
	if not canAttack then return end
	canAttack = false
	playSwing()

	for _, hum in ipairs(findEnemies()) do
		if frozen[hum] then
			print("🩵 " .. hum.Parent.Name .. " 이미 동결 중")
		else
			frozen[hum] = true
			hum:TakeDamage(15)
			local origWalk, origJump = hum.WalkSpeed, hum.JumpPower
			hum.WalkSpeed = 0; hum.JumpPower = 0
			print("🩵 " .. hum.Parent.Name .. " 동결! (3초)")
			task.spawn(function()
				task.wait(3)
				if hum.Health > 0 then hum.WalkSpeed = origWalk; hum.JumpPower = origJump; print("🩵 " .. hum.Parent.Name .. " 해동!") end
				frozen[hum] = nil
			end)
		end
	end

	task.wait(0.8); canAttack = true
end)
