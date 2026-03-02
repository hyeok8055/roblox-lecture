-- ╔══════════════════════════════════════════════════════════════╗
-- ║  🟢 독 검 - 5초간 매초 10 데미지!                          ║
-- ╠══════════════════════════════════════════════════════════════╣
-- ║  task.spawn() = 별도 쓰레드 실행 (메인 코드 안 멈춤)       ║
-- ╚══════════════════════════════════════════════════════════════╝

local tool = script.Parent
local UIS = game:GetService("UserInputService")
local Debris = game:GetService("Debris")

tool.Grip = CFrame.new(0, 0, -1.5, 0, 0, 1, 1, 0, 0, 0, 1, 0)

local canAttack = true
local ATTACK_RANGE = 8
local isEquipped = false
local poisoned = {}

local slashAnim = Instance.new("Animation")
slashAnim.AnimationId = "rbxassetid://522635514"
local slashTrack = nil
local effects = {}

local function setupEffects(handle)
	if not handle then return end

	-- Trail: 독 잔상 (산성 녹색, 가장 오래 남음)
	local attTip  = Instance.new("Attachment"); attTip.Position  = Vector3.new(0,  2.2, 0); attTip.Parent  = handle
	local attBase = Instance.new("Attachment"); attBase.Position = Vector3.new(0, -0.8, 0); attBase.Parent = handle
	local trail = Instance.new("Trail")
	trail.Attachment0    = attTip
	trail.Attachment1    = attBase
	trail.Lifetime       = 0.18    -- 독은 잔상이 오래 남음
	trail.MinLength      = 0
	trail.FaceCamera     = false
	trail.LightEmission  = 0.5
	trail.LightInfluence = 0.5
	trail.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0,   Color3.fromRGB(200, 255, 50)),   -- 선두: 산성 옐로우-그린
		ColorSequenceKeypoint.new(0.4, Color3.fromRGB(50,  200, 10)),   -- 독 초록
		ColorSequenceKeypoint.new(1,   Color3.fromRGB(15,  70,  5)),    -- 꼬리: 어두운 녹색
	})
	trail.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0,   0),
		NumberSequenceKeypoint.new(0.45, 0.1),
		NumberSequenceKeypoint.new(1,   1),
	})
	trail.Parent = handle

	-- 독방울: smoke 텍스처(둥근 방울), 강한 중력으로 뚝뚝 떨어짐
	-- SpreadAngle 좁음 = 직선으로 낙하 (방울처럼)
	-- Acceleration Y-15 = 빠른 중력 (독이 무거워 뚝 떨어짐)
	local drops = Instance.new("ParticleEmitter")
	drops.Texture     = "rbxasset://textures/particles/smoke_main.dds"
	drops.Color       = ColorSequence.new({
		ColorSequenceKeypoint.new(0,   Color3.fromRGB(160, 255, 40)),   -- 밝은 산성 연두
		ColorSequenceKeypoint.new(0.4, Color3.fromRGB(60,  200, 10)),   -- 독 초록
		ColorSequenceKeypoint.new(0.8, Color3.fromRGB(30,  120, 5)),    -- 짙은
		ColorSequenceKeypoint.new(1,   Color3.fromRGB(15,  50,  0)),    -- 소멸
	})
	drops.Size        = NumberSequence.new({
		NumberSequenceKeypoint.new(0,   0.08),   -- 방울 형성
		NumberSequenceKeypoint.new(0.3, 0.16),   -- 방울 완성
		NumberSequenceKeypoint.new(0.7, 0.12),
		NumberSequenceKeypoint.new(1,   0.03),   -- 땅에 튀어 사라짐
	})
	drops.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0,   0.15),
		NumberSequenceKeypoint.new(0.5, 0),      -- 완전 불투명
		NumberSequenceKeypoint.new(0.9, 0.4),
		NumberSequenceKeypoint.new(1,   1),
	})
	drops.Rate         = 15          -- 적당히 (너무 많으면 지저분)
	drops.Speed        = NumberRange.new(0.3, 1.5)
	drops.SpreadAngle  = Vector2.new(8, 8)      -- 좁게! 직선 낙하
	drops.Lifetime     = NumberRange.new(0.3, 0.7)
	drops.RotSpeed     = NumberRange.new(-20, 20)
	drops.Acceleration = Vector3.new(0, -15, 0)  -- 강한 중력! 뚝뚝 떨어짐
	drops.LightEmission  = 0.6
	drops.LightInfluence = 0.4
	drops.LockedToPart   = false
	drops.Name           = "Drops"
	drops.Parent         = handle

	-- 독가스: 위로 천천히 피어오르는 연무
	local gas = Instance.new("ParticleEmitter")
	gas.Texture      = "rbxasset://textures/particles/smoke_main.dds"
	gas.Color        = ColorSequence.new({
		ColorSequenceKeypoint.new(0,   Color3.fromRGB(80,  180, 20)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(50,  130, 10)),
		ColorSequenceKeypoint.new(1,   Color3.fromRGB(25,  60,  5)),
	})
	gas.Size         = NumberSequence.new({
		NumberSequenceKeypoint.new(0,   0.05),
		NumberSequenceKeypoint.new(0.45, 0.28),  -- 위로 올라가며 퍼짐
		NumberSequenceKeypoint.new(1,   0.45),
	})
	gas.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0,   0.55),
		NumberSequenceKeypoint.new(0.5, 0.75),
		NumberSequenceKeypoint.new(1,   1),
	})
	gas.Rate         = 5
	gas.Speed        = NumberRange.new(0.2, 0.8)
	gas.SpreadAngle  = Vector2.new(18, 18)
	gas.Lifetime     = NumberRange.new(0.7, 1.3)
	gas.RotSpeed     = NumberRange.new(-12, 12)
	gas.Acceleration = Vector3.new(0, 2, 0)     -- 가스는 위로 (공기보다 가벼움)
	gas.LightEmission  = 0.4
	gas.LightInfluence = 0.6
	gas.LockedToPart   = false
	gas.Name           = "Gas"
	gas.Parent         = handle

	effects = {attTip, attBase, trail, drops, gas}
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
	local d = h and h:FindFirstChild("Drops")
	local g = h and h:FindFirstChild("Gas")
	if d then d:Emit(22) end
	if g then g:Emit(7) end
end

tool.Equipped:Connect(function()
	isEquipped = true; canAttack = true
	setupEffects(tool:FindFirstChild("Handle"))
	local hum = tool.Parent:FindFirstChildOfClass("Humanoid")
	local anim = hum and hum:FindFirstChildOfClass("Animator")
	if anim then slashTrack = anim:LoadAnimation(slashAnim); slashTrack.Priority = Enum.AnimationPriority.Action end
	print("🟢 [독검] 장착! (클릭 → 5초 독, 매초 10 데미지)")
end)

tool.Unequipped:Connect(function()
	isEquipped = false
	if slashTrack then slashTrack:Stop() end
	cleanupEffects()
	print("🟢 [독검] 해제!")
end)

UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or not isEquipped then return end
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
	if not canAttack then return end
	canAttack = false
	playSwing()

	for _, hum in ipairs(findEnemies()) do
		if poisoned[hum] then
			print("🟢 " .. hum.Parent.Name .. " 이미 독에 걸림!")
		else
			poisoned[hum] = true
			print("🟢 " .. hum.Parent.Name .. " 독 시작! (5초간 매초 10)")
			task.spawn(function()
				for i = 1, 5 do
					if hum.Health <= 0 then break end
					hum:TakeDamage(10)
					print("   🟢 " .. i .. "초: " .. hum.Parent.Name .. " -10")
					task.wait(1)
				end
				poisoned[hum] = nil
				print("🟢 " .. hum.Parent.Name .. " 독 종료!")
			end)
		end
	end

	task.wait(0.5); canAttack = true
end)
