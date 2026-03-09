-- ========================================
-- 10주차 A - 콤보 코인 테스트 묶음
-- ========================================
-- 이 모델에는 코인을 5개 배치해 두었습니다.
-- 목적은 "여러 코인을 빠르게 연속해서 먹었을 때"
-- 피치업 효과가 얼마나 자연스럽게 들리는지 테스트하기 쉽게 만드는 것입니다.
--
-- 핵심 역할 분리
-- - 이 서버 스크립트가 코인 지급, 숨김/재등장, 회전, 콤보 사운드까지 모두 담당합니다.
-- - 따라서 StarterPlayerScripts가 없어도 이 예제만으로 테스트할 수 있습니다.
-- ========================================

local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local coinGroup = script.Parent

local RESPAWN_DELAY = 1
local ROTATE_DEGREES_PER_STEP = 5
local COMBO_WINDOW = 1.5
local MAX_PLAYBACK_SPEED = 2

local coinStates = {}
local touchDebounce = {}
local coins = {}
local playerComboStates = {}

local function getPlayerFromHit(hitPart)
	-- 닿은 파트가 플레이어 캐릭터인지 확인하는 공통 함수입니다.
	local character = hitPart and hitPart.Parent
	if not character then
		return nil, nil
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return nil, nil
	end

	local player = Players:GetPlayerFromCharacter(character)
	if not player then
		return nil, nil
	end

	return player, character
end

local function awardCoin(player)
	-- 기존 leaderstats 시스템이 있으면 Coins 값을 +1 올립니다.
	local leaderstats = player:FindFirstChild("leaderstats")
	local coinsValue = leaderstats and leaderstats:FindFirstChild("Coins")

	if coinsValue then
		coinsValue.Value += 1
	end
end

local function playComboSoundForPlayer(player)
	-- 사운드는 플레이어 몸 근처에서 들리는 편이 더 자연스러워서
	-- HumanoidRootPart를 부모로 사용합니다.
	local character = player.Character
	if not character then
		return
	end

	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then
		return
	end

	local now = os.clock()
	local state = playerComboStates[player]

	if not state then
		state = {
			lastPickupTime = 0,
			count = 0,
		}
		playerComboStates[player] = state
	end

	-- 직전 코인 획득 후 COMBO_WINDOW 안이면 콤보를 이어갑니다.
	if now - state.lastPickupTime <= COMBO_WINDOW then
		state.count += 1
	else
		state.count = 1
	end

	state.lastPickupTime = now

	local sound = Instance.new("Sound")
	sound.Name = "Week10ComboCoinSound"
	sound.SoundId = "rbxasset://sounds/action_get_up.mp3"
	sound.Volume = 0.85
	sound.RollOffMinDistance = 5
	sound.RollOffMaxDistance = 35
	-- 콤보가 올라갈수록 PlaybackSpeed를 조금씩 올립니다.
	sound.PlaybackSpeed = math.clamp(1 + ((state.count - 1) * 0.12), 1, MAX_PLAYBACK_SPEED)
	sound.Parent = rootPart
	sound:Play()

	-- 짧은 효과음이 끝나면 자동 정리합니다.
	Debris:AddItem(sound, 2)

	print(string.format("[10주차 서버 콤보사운드] %s - %d콤보", player.Name, state.count))
end

local function hideCoin(coin)
	-- 먹힌 코인은 잠깐 숨겨서 "수집됐다"는 느낌을 줍니다.
	coin.Transparency = 1
	coin.CanTouch = false
	coin.CanCollide = false
end

local function showCoin(coin)
	-- 테스트를 반복할 수 있게 일정 시간 후 다시 보이게 합니다.
	coin.Transparency = 0
	coin.CanTouch = true
	coin.CanCollide = false
end

local function hookCoin(coin)
	-- 코인마다 독립적인 수집 상태를 저장합니다.
	coinStates[coin] = {
		isCollected = false,
	}

	touchDebounce[coin] = {}
	table.insert(coins, coin)

	coin.Touched:Connect(function(hit)
		local player, character = getPlayerFromHit(hit)
		if not player or not character then
			return
		end

		-- 한 캐릭터의 발/몸 여러 파트가 동시에 닿아도
		-- 한 번만 처리되도록 캐릭터 기준 debounce를 둡니다.
		if touchDebounce[coin][character] then
			return
		end
		touchDebounce[coin][character] = true

		local state = coinStates[coin]
		if state.isCollected then
			task.delay(0.15, function()
				touchDebounce[coin][character] = nil
			end)
			return
		end

		state.isCollected = true

		awardCoin(player)
		playComboSoundForPlayer(player)
		hideCoin(coin)

		print(string.format("[콤보 코인 묶음] %s -> %s 획득", player.Name, coin.Name))

		task.delay(RESPAWN_DELAY, function()
			showCoin(coin)
			state.isCollected = false
		end)

		task.delay(0.15, function()
			touchDebounce[coin][character] = nil
		end)
	end)
end

-- Coin1, Coin2 ... 이름 규칙을 가진 파트만 자동으로 연결합니다.
for _, child in ipairs(coinGroup:GetChildren()) do
	if child:IsA("BasePart") and child.Name:match("^Coin%d+$") then
		hookCoin(child)
	end
end

Players.PlayerRemoving:Connect(function(player)
	playerComboStates[player] = nil
end)

task.spawn(function()
	-- 모든 코인이 "코인답게" 보이도록 계속 회전시킵니다.
	while coinGroup.Parent do
		for _, coin in ipairs(coins) do
			local state = coinStates[coin]
			if state and not state.isCollected then
				coin.CFrame = coin.CFrame * CFrame.Angles(0, 0, math.rad(ROTATE_DEGREES_PER_STEP))
			end
		end
		task.wait()
	end
end)
