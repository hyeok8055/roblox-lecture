-- ╔══════════════════════════════════════════════════════════════╗
-- ║  ✨ 빛 검 - 50 데미지 + 팝업!                              ║
-- ╠══════════════════════════════════════════════════════════════╣
-- ║  BillboardGui = 3D 공간에 뜨는 UI / 3초 쿨다운             ║
-- ╚══════════════════════════════════════════════════════════════╝

local tool = script.Parent
local UIS = game:GetService("UserInputService")
local Debris = game:GetService("Debris")

tool.Grip = CFrame.new(0, 0, -1.5, 0, 0, 1, 1, 0, 0, 0, 1, 0)

local canAttack = true
local DAMAGE = 50
local COOLDOWN = 3
local ATTACK_RANGE = 8
local isEquipped = false

local slashAnim = Instance.new("Animation")
slashAnim.AnimationId = "rbxassetid://522635514"
local slashTrack = nil
local effects = {}

local function setupEffects(handle)
	if not handle then return end

	-- Trail: 순백 → 금빛, 선명하고 짧음 (신성한 빠른 베기)
	local attTip  = Instance.new("Attachment"); attTip.Position  = Vector3.new(0,  2.2, 0); attTip.Parent  = handle
	local attBase = Instance.new("Attachment"); attBase.Position = Vector3.new(0, -0.8, 0); attBase.Parent = handle
	local trail = Instance.new("Trail")
	trail.Attachment0    = attTip
	trail.Attachment1    = attBase
	trail.Lifetime       = 0.10
	trail.MinLength      = 0
	trail.FaceCamera     = false
	trail.LightEmission  = 1        -- 최대 발광
	trail.LightInfluence = 0
	trail.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0,   Color3.fromRGB(255, 255, 255)),  -- 선두: 순백
		ColorSequenceKeypoint.new(0.3, Color3.fromRGB(255, 250, 180)),  -- 따뜻한 흰빛
		ColorSequenceKeypoint.new(0.7, Color3.fromRGB(255, 200, 60)),   -- 금빛
		ColorSequenceKeypoint.new(1,   Color3.fromRGB(200, 130, 0)),    -- 꼬리: 호박빛
	})
	trail.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0,   0),
		NumberSequenceKeypoint.new(0.35, 0),    -- 앞 35%는 완전 불투명
		NumberSequenceKeypoint.new(1,   1),
	})
	trail.Parent = handle

	-- 성광(聖光): sparkles = 별 모양 → 신성한 빛의 입자
	-- SpreadAngle 크게 = 사방으로 폭발
	-- Acceleration 위로 = 신성한 빛은 하늘로 올라감
	local holy = Instance.new("ParticleEmitter")
	holy.Texture     = "rbxasset://textures/particles/sparkles_main.dds"
	holy.Color       = ColorSequence.new({
		ColorSequenceKeypoint.new(0,   Color3.fromRGB(255, 255, 255)),  -- 순백
		ColorSequenceKeypoint.new(0.3, Color3.fromRGB(255, 255, 180)),  -- 따뜻한 흰빛
		ColorSequenceKeypoint.new(0.7, Color3.fromRGB(255, 210, 80)),   -- 금빛
		ColorSequenceKeypoint.new(1,   Color3.fromRGB(255, 160, 20)),   -- 호박색
	})
	holy.Size        = NumberSequence.new({
		NumberSequenceKeypoint.new(0,   0.04),
		NumberSequenceKeypoint.new(0.2, 0.2),   -- 섬광처럼 나타남
		NumberSequenceKeypoint.new(0.6, 0.12),
		NumberSequenceKeypoint.new(1,   0),
	})
	holy.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0,   0.4),
		NumberSequenceKeypoint.new(0.25, 0),
		NumberSequenceKeypoint.new(0.7, 0.25),
		NumberSequenceKeypoint.new(1,   1),
	})
	holy.Rate         = 25
	holy.Speed        = NumberRange.new(2, 6)
	holy.SpreadAngle  = Vector2.new(70, 70)      -- 넓게 사방으로!
	holy.Lifetime     = NumberRange.new(0.3, 0.6)
	holy.RotSpeed     = NumberRange.new(-130, 130)  -- 빠른 회전 = 반짝임
	holy.Acceleration = Vector3.new(0, 6, 0)        -- 신성한 빛은 위로
	holy.LightEmission  = 1    -- 파티클끼리 겹치면 더 밝아짐 (Additive)
	holy.LightInfluence = 0
	holy.LockedToPart   = false
	holy.Name           = "Holy"
	holy.Parent         = handle

	-- 빛 오라: smoke = 부드러운 글로우 번짐
	local aura = Instance.new("ParticleEmitter")
	aura.Texture     = "rbxasset://textures/particles/smoke_main.dds"
	aura.Color       = ColorSequence.new({
		ColorSequenceKeypoint.new(0,   Color3.fromRGB(255, 255, 230)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 230, 150)),
		ColorSequenceKeypoint.new(1,   Color3.fromRGB(255, 190, 60)),
	})
	aura.Size        = NumberSequence.new({
		NumberSequenceKeypoint.new(0,   0),
		NumberSequenceKeypoint.new(0.25, 0.45),  -- 빠르게 팽창
		NumberSequenceKeypoint.new(0.7, 0.7),
		NumberSequenceKeypoint.new(1,   0.9),
	})
	aura.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0,   0.55),
		NumberSequenceKeypoint.new(0.4, 0.72),
		NumberSequenceKeypoint.new(1,   1),
	})
	aura.Rate         = 8
	aura.Speed        = NumberRange.new(0.5, 1.5)
	aura.SpreadAngle  = Vector2.new(40, 40)
	aura.Lifetime     = NumberRange.new(0.4, 0.9)
	aura.RotSpeed     = NumberRange.new(-25, 25)
	aura.Acceleration = Vector3.new(0, 3, 0)
	aura.LightEmission  = 1
	aura.LightInfluence = 0
	aura.LockedToPart   = false
	aura.Name           = "Aura"
	aura.Parent         = handle

	effects = {attTip, attBase, trail, holy, aura}
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
	lbl.Text = "-" .. DAMAGE .. "!"
	lbl.TextScaled = true
	lbl.TextColor3 = Color3.fromRGB(255, 240, 80)
	lbl.Font = Enum.Font.GothamBold
	lbl.BackgroundTransparency = 1
	lbl.Parent = bb
	Debris:AddItem(bb, 2)
end

local function playSwing()
	if slashTrack then slashTrack:Stop(); slashTrack:Play()
	else
		local s = Instance.new("StringValue"); s.Name="toolanim"; s.Value="Slash"; s.Parent=tool
		Debris:AddItem(s, 0.001)
	end
	-- 빛검 = 최대 폭발: sparkles 55개 + aura 22개
	local h = tool:FindFirstChild("Handle")
	local holy = h and h:FindFirstChild("Holy")
	local aura = h and h:FindFirstChild("Aura")
	if holy then holy:Emit(55) end
	if aura then aura:Emit(22) end
end

tool.Equipped:Connect(function()
	isEquipped = true; canAttack = true
	setupEffects(tool:FindFirstChild("Handle"))
	local hum = tool.Parent:FindFirstChildOfClass("Humanoid")
	local anim = hum and hum:FindFirstChildOfClass("Animator")
	if anim then slashTrack = anim:LoadAnimation(slashAnim); slashTrack.Priority = Enum.AnimationPriority.Action end
	print("✨ [빛검] 장착! (" .. DAMAGE .. " 데미지 + 팝업, " .. COOLDOWN .. "초 쿨)")
end)

tool.Unequipped:Connect(function()
	isEquipped = false
	if slashTrack then slashTrack:Stop() end
	cleanupEffects()
	print("✨ [빛검] 해제!")
end)

UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or not isEquipped then return end
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
	if not canAttack then
		print("✨ [빛검] 쿨타임 중!")
		return
	end
	canAttack = false
	playSwing()

	local enemies = findEnemies()
	for _, hum in ipairs(enemies) do
		hum:TakeDamage(DAMAGE)
		showPopup(hum.Parent)
		print("✨ [빛검] " .. hum.Parent.Name .. " -" .. DAMAGE .. "! 팝업!")
	end
	if #enemies == 0 then print("✨ [빛검] 범위 안에 적 없음") end

	task.wait(COOLDOWN); canAttack = true
	print("✨ [빛검] 쿨타임 종료!")
end)
