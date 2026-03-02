-- ╔══════════════════════════════════════════════════════════════╗
-- ║  🔴 3번: 데미지 검 - 쿨다운 + TakeDamage!                  ║
-- ╠══════════════════════════════════════════════════════════════╣
-- ║  💡 canAttack 패턴: 클릭 → false → 공격 → 1초 후 true       ║
-- ╚══════════════════════════════════════════════════════════════╝

local tool = script.Parent
local UIS = game:GetService("UserInputService")
local Debris = game:GetService("Debris")

tool.Grip = CFrame.new(0, 0, -1.5, 0, 0, 1, 1, 0, 0, 0, 1, 0)

local canAttack = true
local COOLDOWN = 1
local DAMAGE = 25
local ATTACK_RANGE = 8
local isEquipped = false

local slashAnim = Instance.new("Animation")
slashAnim.AnimationId = "rbxassetid://522635514"
local slashTrack = nil

local function findEnemies()
	local character = tool.Parent
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return {} end
	local result = {}
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Humanoid") and obj.Health > 0 and obj.Parent ~= character then
			local enemyRoot = obj.Parent:FindFirstChild("HumanoidRootPart")
			if enemyRoot and (enemyRoot.Position - root.Position).Magnitude <= ATTACK_RANGE then
				table.insert(result, obj)
			end
		end
	end
	return result
end

local function playSwing()
	if slashTrack then
		slashTrack:Stop()
		slashTrack:Play()
	else
		local str = Instance.new("StringValue")
		str.Name = "toolanim"
		str.Value = "Slash"
		str.Parent = tool
		Debris:AddItem(str, 0.001)
	end
end

tool.Equipped:Connect(function()
	isEquipped = true
	canAttack = true
	local humanoid = tool.Parent:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	if animator then
		slashTrack = animator:LoadAnimation(slashAnim)
		slashTrack.Priority = Enum.AnimationPriority.Action
	end
	print("🔴 [데미지검] 들었어요! (클릭 → " .. DAMAGE .. " 데미지, " .. COOLDOWN .. "초 쿨)")
end)

tool.Unequipped:Connect(function()
	isEquipped = false
	if slashTrack then slashTrack:Stop() end
	print("🔴 [데미지검] 내려놨어요!")
end)

UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if not isEquipped then return end
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end

	if not canAttack then
		print("🔴 [데미지검] 쿨타임 중!")
		return
	end

	canAttack = false
	playSwing()
	print("🔴 [데미지검] 공격!")

	local enemies = findEnemies()
	for _, humanoid in ipairs(enemies) do
		humanoid:TakeDamage(DAMAGE)
		print("   → " .. humanoid.Parent.Name .. "에게 " .. DAMAGE .. " 데미지!")
	end
	if #enemies == 0 then print("   → 범위 안에 적 없음") end

	task.wait(COOLDOWN)
	canAttack = true
	print("🔴 [데미지검] 쿨타임 종료!")
end)
