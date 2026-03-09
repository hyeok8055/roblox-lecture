-- ========================================
-- 10주차 A - 달릴수록 빨라지는 발소리
-- ========================================
-- 이 LocalScript는 플레이어가 스폰할 때 캐릭터 안으로 복사됩니다.
-- 그래서 "내 캐릭터의 발소리"를 로컬에서 바로 제어하기 좋습니다.
--
-- 수업 포인트
-- 1. Humanoid.Running 이벤트는 현재 이동 속도를 알려 줍니다.
-- 2. 그 속도를 PlaybackSpeed에 연결하면 달릴수록 발소리가 빨라집니다.
-- 3. 점프/낙하 중에는 발소리를 멈춰서 더 자연스럽게 만듭니다.
-- ========================================

local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- 발소리 루프를 코드로 직접 만듭니다.
-- Explorer에 Sound를 미리 손으로 넣지 않아도 되도록 한 구조입니다.
local footstepSound = Instance.new("Sound")
footstepSound.Name = "Week10FootstepLoop"
footstepSound.SoundId = "rbxasset://sounds/action_footsteps_plastic.mp3"
footstepSound.Looped = true
footstepSound.Volume = 0.55
footstepSound.RollOffMinDistance = 5
footstepSound.RollOffMaxDistance = 20
footstepSound.Parent = rootPart

local function speedToPlaybackSpeed(speed)
	-- 기본 WalkSpeed 16을 1배속 기준처럼 보고 비율로 계산합니다.
	-- clamp를 걸어 너무 느리거나 너무 빠른 값은 제한합니다.
	return math.clamp(speed / 16, 0.8, 2.1)
end

local function updateFootstep(speed)
	-- 공중에 있을 때는 발소리가 나면 어색하므로
	-- "움직이고 있고, 바닥 위에 있을 때만" 재생합니다.
	local isMovingOnGround = speed > 1 and humanoid.FloorMaterial ~= Enum.Material.Air

	if isMovingOnGround then
		footstepSound.PlaybackSpeed = speedToPlaybackSpeed(speed)

		if not footstepSound.IsPlaying then
			footstepSound:Play()
		end
	elseif footstepSound.IsPlaying then
		footstepSound:Stop()
	end
end

-- Running 이벤트는 속도 값이 바뀔 때마다 계속 호출됩니다.
humanoid.Running:Connect(updateFootstep)

humanoid.StateChanged:Connect(function(_, newState)
	-- 점프/낙하 상태에서는 즉시 발소리를 멈춥니다.
	if newState == Enum.HumanoidStateType.Freefall
		or newState == Enum.HumanoidStateType.Jumping then
		if footstepSound.IsPlaying then
			footstepSound:Stop()
		end
	end
end)

character.AncestryChanged:Connect(function(_, parent)
	if parent then
		return
	end

	-- 캐릭터가 사라질 때 남아 있는 루프를 정리합니다.
	if footstepSound.IsPlaying then
		footstepSound:Stop()
	end
end)

print("[10주차] Week10FootstepLoop 생성:", character.Name)
