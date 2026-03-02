-- ╔══════════════════════════════════════════════════════════════╗
-- ║  ⚡ 폭풍 지팡이 - 범위 내 모든 적 30 데미지!               ║
-- ╠══════════════════════════════════════════════════════════════╣
-- ║  AoE 공격 / BillboardGui 팝업 / 4초 쿨다운                  ║
-- ╚══════════════════════════════════════════════════════════════╝

local tool = script.Parent
local UIS = game:GetService("UserInputService")
local Debris = game:GetService("Debris")

tool.Grip = CFrame.new(0, 0, -1.5, 0, 0, 1, 1, 0, 0, 0, 1, 0)

local canUse = true
local DAMAGE = 30
local COOLDOWN = 4
local ATTACK_RANGE = 12   -- 검보다 넓은 범위!
local isEquipped = false
local effects = {}

local function setupEffects(handle)
	if not handle then return end

	local attTip  = Instance.new("Attachment"); attTip.Position  = Vector3.new(0,  1.8, 0); attTip.Parent  = handle
	local attBase = Instance.new("Attachment"); attBase.Position = Vector3.new(0, -0.5, 0); attBase.Parent = handle
	local trail = Instance.new("Trail")
	trail.Attachment0    = attTip
	trail.Attachment1    = attBase
	trail.Lifetime       = 0.14
	trail.MinLength      = 0
	trail.FaceCamera     = false
	trail.LightEmission  = 1
	trail.LightInfluence = 0
	trail.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0,   Color3.fromRGB(220, 200, 255)),
		ColorSequenceKeypoint.new(0.4, Color3.fromRGB(140, 80,  255)),
		ColorSequenceKeypoint.new(1,   Color3.fromRGB(60,  0,   180)),
	})
	trail.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0,   0),
		NumberSequenceKeypoint.new(0.5, 0.1),
		NumberSequenceKeypoint.new(1,   1),
	})
	trail.Parent = handle

	-- 번개 입자: 빠르게 사방으로 튀는 스파크
	local spark = Instance.new("ParticleEmitter")
	spark.Texture     = "rbxasset://textures/particles/sparkles_main.dds"
	spark.Color       = ColorSequence.new({
		ColorSequenceKeypoint.new(0,   Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(0.3, Color3.fromRGB(200, 150, 255)),
		ColorSequenceKeypoint.new(0.7, Color3.fromRGB(120, 50,  255)),
		ColorSequenceKeypoint.new(1,   Color3.fromRGB(60,  0,   200)),
	})
	spark.Size        = NumberSequence.new({
		NumberSequenceKeypoint.new(0,   0.03),
		NumberSequenceKeypoint.new(0.2, 0.18),
		NumberSequenceKeypoint.new(0.6, 0.10),
		NumberSequenceKeypoint.new(1,   0),
	})
	spark.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0,   0.2),
		NumberSequenceKeypoint.new(0.3, 0),
		NumberSequenceKeypoint.new(1,   1),
	})
	spark.Rate         = 22
	spark.Speed        = NumberRange.new(3, 8)
	spark.SpreadAngle  = Vector2.new(80, 80)   -- 사방으로 튀는 번개
	spark.Lifetime     = NumberRange.new(0.2, 0.5)
	spark.RotSpeed     = NumberRange.new(-250, 250)
	spark.Acceleration = Vector3.new(0, -4, 0)  -- 번개는 살짝 아래로 (중력)
	spark.LightEmission  = 1
	spark.LightInfluence = 0
	spark.LockedToPart   = false
	spark.Name           = "Spark"
	spark.Parent         = handle

	-- 보라 안개: 마법 연기
	local smoke = Instance.new("ParticleEmitter")
	smoke.Texture     = "rbxasset://textures/particles/smoke_main.dds"
	smoke.Color       = ColorSequence.new({
		ColorSequenceKeypoint.new(0,   Color3.fromRGB(180, 100, 255)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(120, 60,  200)),
		ColorSequenceKeypoint.new(1,   Color3.fromRGB(60,  20,  120)),
	})
	smoke.Size        = NumberSequence.new({
		NumberSequenceKeypoint.new(0,   0.05),
		NumberSequenceKeypoint.new(0.4, 0.35),
		NumberSequenceKeypoint.new(1,   0.5),
	})
	smoke.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0,   0.5),
		NumberSequenceKeypoint.new(0.5, 0.75),
		NumberSequenceKeypoint.new(1,   1),
	})
	smoke.Rate         = 7
	smoke.Speed        = NumberRange.new(0.5, 1.5)
	smoke.SpreadAngle  = Vector2.new(25, 25)
	smoke.Lifetime     = NumberRange.new(0.5, 1.0)
	smoke.RotSpeed     = NumberRange.new(-30, 30)
	smoke.Acceleration = Vector3.new(0, 3, 0)
	smoke.LightEmission  = 0.9
	smoke.LightInfluence = 0.1
	smoke.LockedToPart   = false
	smoke.Name           = "Smoke"
	smoke.Parent         = handle

	effects = {attTip, attBase, trail, spark, smoke}
end

local function cleanupEffects()
	for _, e in ipairs(effects) do if e.Parent then e:Destroy() end end
	effects = {}
end

local function showPopup(target)
	local head = target:FindFirstChild("Head")
	if not head then return end
	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.new(0, 80, 0, 40)
	bb.StudsOffset = Vector3.new(0, 3, 0)
	bb.AlwaysOnTop = true
	bb.Parent = head
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1,0,1,0)
	lbl.Text = "-" .. DAMAGE .. "⚡"
	lbl.TextScaled = true
	lbl.TextColor3 = Color3.fromRGB(180, 100, 255)
	lbl.Font = Enum.Font.GothamBold
	lbl.BackgroundTransparency = 1
	lbl.Parent = bb
	Debris:AddItem(bb, 2)
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

local function playWave()
	local h = tool:FindFirstChild("Handle")
	local sp = h and h:FindFirstChild("Spark")
	local sm = h and h:FindFirstChild("Smoke")
	if sp then sp:Emit(50) end
	if sm then sm:Emit(15) end
end

tool.Equipped:Connect(function()
	isEquipped = true; canUse = true
	setupEffects(tool:FindFirstChild("Handle"))
	print("⚡ [폭풍완드] 장착! (범위 " .. ATTACK_RANGE .. " 스터드, " .. DAMAGE .. " 데미지)")
end)

tool.Unequipped:Connect(function()
	isEquipped = false
	cleanupEffects()
	print("⚡ [폭풍완드] 해제!")
end)

UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or not isEquipped then return end
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
	if not canUse then print("⚡ [폭풍완드] 쿨타임 중!"); return end
	canUse = false
	playWave()

	local enemies = findEnemies()
	for _, hum in ipairs(enemies) do
		hum:TakeDamage(DAMAGE)
		showPopup(hum.Parent)
		print("⚡ [폭풍완드] " .. hum.Parent.Name .. " -" .. DAMAGE)
	end
	if #enemies == 0 then print("⚡ [폭풍완드] 범위 내 적 없음 (범위: " .. ATTACK_RANGE .. ")") end

	task.wait(COOLDOWN); canUse = true
	print("⚡ [폭풍완드] 쿨타임 종료!")
end)
