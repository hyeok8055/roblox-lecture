-- ========================================
-- 10주차 A - 발소리 체험용 스피드 패드
-- ========================================
-- 이 예제는 발소리 로직 그 자체보다
-- "속도가 올라가면 발소리도 함께 빨라진다"는 체험을 쉽게 하려고 만든 보조 장치입니다.
--
-- 역할 분리
-- - 이 서버 스크립트: WalkSpeed를 잠깐 올림
-- - StarterCharacterScripts LocalScript: 바뀐 속도를 보고 발소리 PlaybackSpeed 조절
-- ========================================

local pad = script.Parent

local BOOST_SPEED = 28
local BOOST_DURATION = 4

local activeBoosts = {}

local function getHumanoidFromHit(hitPart)
	local character = hitPart and hitPart.Parent
	if not character then
		return nil
	end

	return character:FindFirstChildOfClass("Humanoid")
end

pad.Touched:Connect(function(hit)
	local humanoid = getHumanoidFromHit(hit)
	if not humanoid then
		return
	end

	-- 캐릭터의 여러 파트가 동시에 닿을 수 있으므로
	-- humanoid 기준으로 중복 부스트를 막습니다.
	if activeBoosts[humanoid] then
		return
	end
	activeBoosts[humanoid] = true

	local originalSpeed = humanoid.WalkSpeed
	local appliedSpeed = math.max(originalSpeed, BOOST_SPEED)

	-- 원래 속도가 이미 더 빠른 경우에는 그 값을 유지합니다.
	humanoid.WalkSpeed = appliedSpeed
	print("[발소리 패드] 속도 증가:", humanoid.Parent.Name, appliedSpeed)

	task.delay(BOOST_DURATION, function()
		-- 다른 시스템이 나중에 또 속도를 바꿨을 수도 있으니
		-- 우리가 넣었던 값이 그대로일 때만 복구합니다.
		if humanoid.Parent and humanoid.WalkSpeed == appliedSpeed then
			humanoid.WalkSpeed = originalSpeed
		end

		activeBoosts[humanoid] = nil
	end)
end)
