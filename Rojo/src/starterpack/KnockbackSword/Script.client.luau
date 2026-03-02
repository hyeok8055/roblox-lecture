-- ╔══════════════════════════════════════════════════════════════╗
-- ║  🟤 8번: 넉백 검 - 맞으면 날아가요!                        ║
-- ╠══════════════════════════════════════════════════════════════╣
-- ║  💡 BodyVelocity = 물리 힘으로 날리기                       ║
-- ╚══════════════════════════════════════════════════════════════╝

local tool = script.Parent
local UIS = game:GetService("UserInputService")
local Debris = game:GetService("Debris")

tool.Grip = CFrame.new(0, 0, -1.5, 0, 0, 1, 1, 0, 0, 0, 1, 0)

local canAttack = true
local ATTACK_RANGE = 8
local KNOCKBACK = 80
local KNOCKBACK_UP = 20
local isEquipped = false

local lungeAnim = Instance.new("Animation")
lungeAnim.AnimationId = "rbxassetid://522638767"
local lungeTrack = nil

local function findEnemies()
	local character = tool.Parent
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return {} end
	local result = {}
	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("Humanoid") and obj.Health > 0 and obj.Parent ~= character then
			local enemyRoot = obj.Parent:FindFirstChild("HumanoidRootPart")
			if enemyRoot and (enemyRoot.Position - root.Position).Magnitude <= ATTACK_RANGE then
				table.insert(result, {humanoid = obj, root = enemyRoot})
			end
		end
	end
	return result
end

local function playSwing()
	if lungeTrack then
		lungeTrack:Stop()
		lungeTrack:Play()
	else
		local str = Instance.new("StringValue")
		str.Name = "toolanim"
		str.Value = "Lunge"
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
		lungeTrack = animator:LoadAnimation(lungeAnim)
		lungeTrack.Priority = Enum.AnimationPriority.Action
	end
	print("🟤 [넉백검] 들었어요! (클릭 → 20 데미지 + 날림)")
end)

tool.Unequipped:Connect(function()
	isEquipped = false
	if lungeTrack then lungeTrack:Stop() end
	print("🟤 [넉백검] 내려놨어요!")
end)

UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if not isEquipped then return end
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end

	if not canAttack then return end
	canAttack = false
	playSwing()

	local myRoot = tool.Parent:FindFirstChild("HumanoidRootPart")
	local enemies = findEnemies()

	for _, data in ipairs(enemies) do
		data.humanoid:TakeDamage(20)

		local direction = myRoot
			and (data.root.Position - myRoot.Position).Unit
			or Vector3.new(0, 0, 1)

		local bv = Instance.new("BodyVelocity")
		bv.Velocity = direction * KNOCKBACK + Vector3.new(0, KNOCKBACK_UP, 0)
		bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
		bv.P = 1e4
		bv.Parent = data.root
		Debris:AddItem(bv, 0.2)

		print("🟤 [넉백검] " .. data.humanoid.Parent.Name .. " 날아가요!")
	end
	if #enemies == 0 then print("🟤 [넉백검] 범위 안에 적 없음") end

	task.wait(0.8)
	canAttack = true
end)
