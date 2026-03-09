-- ========================================
-- 10주차 A - 모든 코인 획득에 반응하는 콤보 피치업
-- ========================================
-- 핵심 변경점
-- - 특정 "콤보코인_피치업" 파트만 보는 게 아니라
-- - leaderstats.Coins 값이 증가하는 모든 순간을 감지합니다.
--
-- 즉:
-- - 기본 코인 +1
-- - 골드 코인 +5
-- - 다른 주차 코인 스크립트
-- 전부 "코인을 먹어서 Coins 값이 올라가면" 콤보 사운드가 납니다.
-- ========================================

local Players = game:GetService("Players")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer

local COMBO_WINDOW = 1.5
local MAX_PLAYBACK_SPEED = 2

local comboCount = 0
local lastPickupTime = 0

local soundTemplate = Instance.new("Sound")
soundTemplate.Name = "Week10CoinComboTemplate"
-- 외부 업로드 음원 ID 대신, 현재 Roblox 설치에 실제 존재하는 기본 사운드를 사용합니다.
-- "action_get_up"은 짧고 확실히 들려서 콤보 피치업 데모용으로 쓰기 좋습니다.
soundTemplate.SoundId = "rbxasset://sounds/action_get_up.mp3"
soundTemplate.Volume = 0.9
soundTemplate.Parent = SoundService

local function playComboSound()
	local now = os.clock()

	if now - lastPickupTime <= COMBO_WINDOW then
		comboCount += 1
	else
		comboCount = 1
	end

	lastPickupTime = now

	local sound = soundTemplate:Clone()
	sound.PlaybackSpeed = math.clamp(1 + ((comboCount - 1) * 0.12), 1, MAX_PLAYBACK_SPEED)
	sound.Parent = SoundService

	-- 클라이언트에서 확실히 재생되게 SoundService를 통해 로컬 재생합니다.
	-- 환경에 따라 일반 :Play()보다 확인이 쉬운 편입니다.
	SoundService:PlayLocalSound(sound)

	Debris:AddItem(sound, 2)

	print(string.format("[10주차] 코인 콤보 사운드: %d콤보", comboCount))
end

local function hookCoins(coinsValue)
	local lastValue = coinsValue.Value

	print("[10주차] 코인 콤보 훅 연결 완료. 시작 Coins =", lastValue)

	coinsValue:GetPropertyChangedSignal("Value"):Connect(function()
		local newValue = coinsValue.Value
		local delta = newValue - lastValue
		lastValue = newValue

		print(string.format("[10주차] Coins 변경 감지: delta=%d current=%d", delta, newValue))

		-- 코인이 증가했을 때만 콤보 사운드 재생
		if delta > 0 then
			playComboSound()
		end
	end)
end

local function start()
	print("[10주차] Week10CoinComboAudio 시작")

	local leaderstats = player:WaitForChild("leaderstats")
	local coinsValue = leaderstats:WaitForChild("Coins")

	hookCoins(coinsValue)
end

start()
