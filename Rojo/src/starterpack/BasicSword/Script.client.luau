-- ╔══════════════════════════════════════════════════════════════╗
-- ║  ⚔️ 1번: 기본 검 - Tool의 첫걸음!                          ║
-- ╠══════════════════════════════════════════════════════════════╣
-- ║  💡 좌클릭 → 슬래시 애니메이션 + 8스터드 범위 데미지       ║
-- ╚══════════════════════════════════════════════════════════════╝

local tool = script.Parent
local UIS = game:GetService("UserInputService")
local Debris = game:GetService("Debris")

tool.Grip = CFrame.new(0, 0, -1.5, 0, 0, 1, 1, 0, 0, 0, 1, 0)

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

-- 💡 애니메이션 재생 (R15 / R6 자동 감지)
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
	local humanoid = tool.Parent:FindFirstChildOfClass("Humanoid")
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	if animator then
		slashTrack = animator:LoadAnimation(slashAnim)
		slashTrack.Priority = Enum.AnimationPriority.Action
	end
	print("⚔️ [기본검] 들었어요! (좌클릭 → 공격)")
end)

tool.Unequipped:Connect(function()
	isEquipped = false
	if slashTrack then slashTrack:Stop() end
	print("⚔️ [기본검] 내려놨어요!")
end)

UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if not isEquipped then return end
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end

	print("⚔️ [기본검] 휘둘렀어요!")
	playSwing()

	local enemies = findEnemies()
	if #enemies == 0 then
		print("   → 범위(" .. ATTACK_RANGE .. "스터드) 안에 적이 없어요")
	end
	for _, humanoid in ipairs(enemies) do
		humanoid:TakeDamage(25)
		print("   → " .. humanoid.Parent.Name .. "에게 25 데미지!")
	end
end)
