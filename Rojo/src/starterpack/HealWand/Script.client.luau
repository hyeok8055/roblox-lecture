-- ╔══════════════════════════════════════════════════════════════╗
-- ║  💚 힐 지팡이 - 클릭하면 체력 +50 회복!                    ║
-- ╠══════════════════════════════════════════════════════════════╣
-- ║  Humanoid.Health 직접 조작 / 5초 쿨다운                     ║
-- ╚══════════════════════════════════════════════════════════════╝

local tool = script.Parent
local UIS = game:GetService("UserInputService")
local Debris = game:GetService("Debris")

tool.Grip = CFrame.new(0, 0, -1.5, 0, 0, 1, 1, 0, 0, 0, 1, 0)

local canUse = true
local HEAL_AMOUNT = 50
local COOLDOWN = 5
local isEquipped = false
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
		ColorSequenceKeypoint.new(0,   Color3.fromRGB(200, 255, 200)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(50,  255, 120)),
		ColorSequenceKeypoint.new(1,   Color3.fromRGB(0,   180, 60)),
	})
	trail.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0,   0),
		NumberSequenceKeypoint.new(0.5, 0.1),
		NumberSequenceKeypoint.new(1,   1),
	})
	trail.Parent = handle

	-- 치유 빛: 위로 올라가는 십자 별 모양
	local heal = Instance.new("ParticleEmitter")
	heal.Texture     = "rbxasset://textures/particles/sparkles_main.dds"
	heal.Color       = ColorSequence.new({
		ColorSequenceKeypoint.new(0,   Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(0.4, Color3.fromRGB(150, 255, 150)),
		ColorSequenceKeypoint.new(1,   Color3.fromRGB(0,   200, 80)),
	})
	heal.Size        = NumberSequence.new({
		NumberSequenceKeypoint.new(0,   0.05),
		NumberSequenceKeypoint.new(0.3, 0.25),
		NumberSequenceKeypoint.new(1,   0),
	})
	heal.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0,   0.3),
		NumberSequenceKeypoint.new(0.3, 0),
		NumberSequenceKeypoint.new(1,   1),
	})
	heal.Rate         = 20
	heal.Speed        = NumberRange.new(2, 5)
	heal.SpreadAngle  = Vector2.new(60, 60)
	heal.Lifetime     = NumberRange.new(0.4, 0.8)
	heal.RotSpeed     = NumberRange.new(-150, 150)
	heal.Acceleration = Vector3.new(0, 8, 0)   -- 치유 에너지는 위로!
	heal.LightEmission  = 1
	heal.LightInfluence = 0
	heal.LockedToPart   = false
	heal.Name           = "Heal"
	heal.Parent         = handle

	-- 초록 안개: 부드러운 회복 글로우
	local mist = Instance.new("ParticleEmitter")
	mist.Texture     = "rbxasset://textures/particles/smoke_main.dds"
	mist.Color       = ColorSequence.new({
		ColorSequenceKeypoint.new(0,   Color3.fromRGB(150, 255, 150)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100, 220, 100)),
		ColorSequenceKeypoint.new(1,   Color3.fromRGB(50,  150, 50)),
	})
	mist.Size        = NumberSequence.new({
		NumberSequenceKeypoint.new(0,   0.05),
		NumberSequenceKeypoint.new(0.4, 0.4),
		NumberSequenceKeypoint.new(1,   0.6),
	})
	mist.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0,   0.6),
		NumberSequenceKeypoint.new(0.5, 0.8),
		NumberSequenceKeypoint.new(1,   1),
	})
	mist.Rate         = 6
	mist.Speed        = NumberRange.new(0.3, 1)
	mist.SpreadAngle  = Vector2.new(30, 30)
	mist.Lifetime     = NumberRange.new(0.5, 1.0)
	mist.RotSpeed     = NumberRange.new(-20, 20)
	mist.Acceleration = Vector3.new(0, 2, 0)
	mist.LightEmission  = 0.8
	mist.LightInfluence = 0.2
	mist.LockedToPart   = false
	mist.Name           = "Mist"
	mist.Parent         = handle

	effects = {attTip, attBase, trail, heal, mist}
end

local function cleanupEffects()
	for _, e in ipairs(effects) do if e.Parent then e:Destroy() end end
	effects = {}
end

local function playWave()
	local h = tool:FindFirstChild("Handle")
	local he = h and h:FindFirstChild("Heal")
	local mi = h and h:FindFirstChild("Mist")
	if he then he:Emit(40) end
	if mi then mi:Emit(12) end
end

tool.Equipped:Connect(function()
	isEquipped = true; canUse = true
	setupEffects(tool:FindFirstChild("Handle"))
	print("💚 [힐완드] 장착! (클릭 → +" .. HEAL_AMOUNT .. " 회복, " .. COOLDOWN .. "초 쿨)")
end)

tool.Unequipped:Connect(function()
	isEquipped = false
	cleanupEffects()
	print("💚 [힐완드] 해제!")
end)

UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or not isEquipped then return end
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
	if not canUse then print("💚 [힐완드] 쿨타임 중!"); return end
	canUse = false
	playWave()

	local character = tool.Parent
	local hum = character:FindFirstChildOfClass("Humanoid")
	if hum then
		local before = math.floor(hum.Health)
		hum.Health = math.min(hum.Health + HEAL_AMOUNT, hum.MaxHealth)
		local after = math.floor(hum.Health)
		print("💚 [힐완드] 회복! " .. before .. " → " .. after .. " ❤️")
	end

	task.wait(COOLDOWN); canUse = true
	print("💚 [힐완드] 쿨타임 종료!")
end)
