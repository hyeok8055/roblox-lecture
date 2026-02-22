-- ╔══════════════════════════════════════════════════════════════╗
-- ║  🥈 은 코인! (+3점) — Gold와 같은 스크립트!                  ║
-- ╠══════════════════════════════════════════════════════════════╣
-- ║  📦 이 스크립트는 Gold/CoinScript와 100% 동일해요!          ║
-- ║  💡 part.Name이 "Silver"이므로 getScore()가 3을 반환!       ║
-- ║  💡 같은 코드로 다른 동작 = 코드 재사용의 힘!               ║
-- ╚══════════════════════════════════════════════════════════════╝

local part = script.Parent
local collected = false

-- 💡 이름으로 점수 결정! (Gold=5, Silver=3, Bronze=1)
local function getScore()
	if part.Name == "Gold" then
		return 5
	elseif part.Name == "Silver" then
		return 3        -- 💡 ← 이 Part는 여기에 해당!
	else
		return 1
	end
end

part.Touched:Connect(function(hit)
	if not collected then
		local player = game.Players:GetPlayerFromCharacter(hit.Parent)
		if player then
			collected = true
			local score = getScore()
			player.leaderstats.Coins.Value += score
			print("🪙 " .. player.Name .. " → " .. part.Name .. " 코인! +" .. score .. "점")
			part:Destroy()
		end
	end
end)
