-- ╔══════════════════════════════════════════════════════════════╗
-- ║  🟡 4번: 스피드 검 - 들면 2.5배 빨라짐!                    ║
-- ╠══════════════════════════════════════════════════════════════╣
-- ║  💡 Equipped 시 WalkSpeed 40, Unequipped 시 16 복구         ║
-- ╚══════════════════════════════════════════════════════════════╝

local tool = script.Parent
local UIS = game:GetService("UserInputService")
local Debris = game:GetService("Debris")

tool.Grip = CFrame.new(0, 0, -1.5, 0, 0, 1, 1, 0, 0, 0, 1, 0)

local isEquipped = false

local slashAnim = Instance.new("Animation")
slashAnim.AnimationId = "rbxassetid://522635514"
local slashTrack = nil

local function getHumanoid()
	return tool.Parent:FindFirstChild("Humanoid")
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
	local humanoid = getHumanoid()
	local animator = humanoid and humanoid:FindFirstChildOfClass("Animator")
	if animator then
		slashTrack = animator:LoadAnimation(slashAnim)
		slashTrack.Priority = Enum.AnimationPriority.Action
	end
	if humanoid then
		humanoid.WalkSpeed = 40
		print("🟡 [스피드검] 장착! 속도 → 40 (2.5배)")
	end
end)

tool.Unequipped:Connect(function()
	isEquipped = false
	if slashTrack then slashTrack:Stop() end
	local humanoid = getHumanoid()
	if humanoid then
		humanoid.WalkSpeed = 16
		print("🟡 [스피드검] 해제! 속도 → 16 (기본)")
	end
end)

UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if not isEquipped then return end
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end

	playSwing()
	local humanoid = getHumanoid()
	if humanoid then
		print("🟡 [스피드검] 현재 속도: " .. humanoid.WalkSpeed)
	end
end)
