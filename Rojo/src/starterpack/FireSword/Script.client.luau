-- ╔══════════════════════════════════════════════════════════════╗
-- ║  🔥 파이어 검 - 3연타 콤보!                                 ║
-- ╠══════════════════════════════════════════════════════════════╣
-- ║  클릭 3번: 10 → 20 → 40 데미지 / 1.5초 안에 안 누르면 리셋 ║
-- ╚══════════════════════════════════════════════════════════════╝

local tool = script.Parent
local UIS = game:GetService("UserInputService")
local Debris = game:GetService("Debris")

tool.Grip = CFrame.new(0, 0, -1.5, 0, 0, 1, 1, 0, 0, 0, 1, 0)

local hitCount = 0
local canAttack = true
local COMBO_DAMAGE = {10, 20, 40}
local ATTACK_RANGE = 8
local comboResetTimer = nil
local isEquipped = false

local slashAnim = Instance.new("Animation")
slashAnim.AnimationId = "rbxassetid://522635514"
local slashTrack = nil
local effects = {}

local function setupEffects(handle)
	if not handle then return end

	-- Trail: 불꽃 슬래시 잔상
	-- att 간격이 날 길이 → 넓을수록 두꺼운 trail
	local attTip  = Instance.new("Attachment"); attTip.Position  = Vector3.new(0,  2.2, 0); attTip.Parent  = handle
	local attBase = Instance.new("Attachment"); attBase.Position = Vector3.new(0, -0.8, 0); attBase.Parent = handle
	local trail = Instance.new("Trail")
	trail.Attachment0    = attTip
	trail.Attachment1    = attBase
	trail.Lifetime       = 0.10      -- 짧을수록 선명한 슬래시
	trail.MinLength      = 0
	trail.FaceCamera     = false     -- true는 버그 있음
	trail.LightEmission  = 1
	trail.LightInfluence = 0
	trail.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0,   Color3.fromRGB(255, 240, 120)),  -- 선두: 노랑-흰빛
		ColorSequenceKeypoint.new(0.4, Color3.fromRGB(255, 100, 0)),    -- 주황
		ColorSequenceKeypoint.new(1,   Color3.fromRGB(120, 10, 0)),     -- 꼬리: 어두운 빨강
	})
	trail.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0,   0),
		NumberSequenceKeypoint.new(0.5, 0.1),
		NumberSequenceKeypoint.new(1,   1),
	})
	trail.Parent = handle

	-- 불꽃 메인: fire_main 텍스처, 위로 상승, 좁은 SpreadAngle
	local flame = Instance.new("ParticleEmitter")
	flame.Texture        = "rbxasset://textures/particles/fire_main.dds"
	flame.Color          = ColorSequence.new({
		ColorSequenceKeypoint.new(0,   Color3.fromRGB(255, 230, 80)),   -- 노랑 (뜨거운 핵심)
		ColorSequenceKeypoint.new(0.35, Color3.fromRGB(236, 139, 70)),  -- 주황 (Roblox 공식 Fire 색)
		ColorSequenceKeypoint.new(0.7, Color3.fromRGB(200, 40, 0)),     -- 빨강
		ColorSequenceKeypoint.new(1,   Color3.fromRGB(40, 10, 0)),      -- 잔불 소멸
	})
	flame.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0,   0.1),
		NumberSequenceKeypoint.new(0.25, 0.4),   -- 불꽃이 피어남
		NumberSequenceKeypoint.new(0.7, 0.25),
		NumberSequenceKeypoint.new(1,   0),
	})
	flame.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0,   0.2),
		NumberSequenceKeypoint.new(0.4, 0),
		NumberSequenceKeypoint.new(1,   1),
	})
	flame.Rate           = 20           -- 적당한 밀도 (너무 많으면 지저분)
	flame.Speed          = NumberRange.new(1, 3)
	flame.SpreadAngle    = Vector2.new(12, 12)    -- 좁게 = 위로 솟구치는 느낌
	flame.Lifetime       = NumberRange.new(0.35, 0.65)
	flame.RotSpeed       = NumberRange.new(-40, 40)
	flame.Acceleration   = Vector3.new(0, 10, 0)  -- 불꽃은 위로!
	flame.LightEmission  = 1
	flame.LightInfluence = 0
	flame.LockedToPart   = false
	flame.Name           = "Flame"
	flame.Parent         = handle

	-- 불씨 스파크: 빠르게 튀어오름
	local sparks = Instance.new("ParticleEmitter")
	sparks.Texture       = "rbxasset://textures/particles/fire_sparks_main.dds"
	sparks.Color         = ColorSequence.new(Color3.fromRGB(255, 200, 60))
	sparks.Size          = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.06),
		NumberSequenceKeypoint.new(1, 0),
	})
	sparks.Transparency  = NumberSequence.new({
		NumberSequenceKeypoint.new(0,   0),
		NumberSequenceKeypoint.new(0.6, 0),
		NumberSequenceKeypoint.new(1,   1),
	})
	sparks.Rate          = 8
	sparks.Speed         = NumberRange.new(4, 10)  -- 스파크는 빠르게
	sparks.SpreadAngle   = Vector2.new(35, 35)
	sparks.Lifetime      = NumberRange.new(0.2, 0.5)
	sparks.RotSpeed      = NumberRange.new(-90, 90)
	sparks.Acceleration  = Vector3.new(0, 6, 0)
	sparks.LightEmission = 1
	sparks.LightInfluence = 0
	sparks.LockedToPart  = false
	sparks.Name          = "Sparks"
	sparks.Parent        = handle

	effects = {attTip, attBase, trail, flame, sparks}
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
	local f = h and h:FindFirstChild("Flame")
	local s = h and h:FindFirstChild("Sparks")
	local counts = {20, 35, 60}  -- 콤보마다 더 강한 폭발
	if f then f:Emit(counts[hitCount] or 20) end
	if s then s:Emit(math.ceil((counts[hitCount] or 20) / 3)) end
end

tool.Equipped:Connect(function()
	isEquipped = true; canAttack = true; hitCount = 0
	setupEffects(tool:FindFirstChild("Handle"))
	local hum = tool.Parent:FindFirstChildOfClass("Humanoid")
	local anim = hum and hum:FindFirstChildOfClass("Animator")
	if anim then slashTrack = anim:LoadAnimation(slashAnim); slashTrack.Priority = Enum.AnimationPriority.Action end
	print("🔥 [파이어검] 장착! (3타 콤보: 10→20→40)")
end)

tool.Unequipped:Connect(function()
	isEquipped = false; hitCount = 0
	if slashTrack then slashTrack:Stop() end
	cleanupEffects()
	print("🔥 [파이어검] 해제!")
end)

UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or not isEquipped then return end
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
	if not canAttack then return end
	canAttack = false

	hitCount = hitCount % 3 + 1
	playSwing()
	print("🔥 " .. ({"1타","2타","3타 🔥🔥🔥"})[hitCount] .. " (" .. COMBO_DAMAGE[hitCount] .. " 데미지)")

	for _, hum in ipairs(findEnemies()) do
		hum:TakeDamage(COMBO_DAMAGE[hitCount])
		print("   → " .. hum.Parent.Name)
	end

	if comboResetTimer then task.cancel(comboResetTimer) end
	comboResetTimer = task.delay(1.5, function()
		if hitCount > 0 then hitCount = 0; print("🔥 콤보 초기화") end
	end)
	task.wait(0.3)
	canAttack = true
end)
