--! Main Script: Death Ball Auto-Parry Executor (최종 후보, PlayerDevice)
-- 키 인증 제거 및 RemoteEvent 이름을 'PlayerDevice'로 고정했습니다.

--! =============================================================
--! 1. 전역 환경 및 필수 서비스 초기화
--! =============================================================

getgenv().NATIVELOADERINSTANCES = getgenv().NATIVELOADERINSTANCES or {}
script_key = "AAAAAAAAAAAAAAAA" -- 더미 키 유지

local game = game
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- 로더가 기대하는 더미 함수들을 정의합니다.
loadstring([[
	function LPH_NO_VIRTUALIZE(f) return f end;
	function LPH_JIT(f) return f end;
	function LPH_JIT_MAX(f) return f end;
	function LRM_SANITIZE(...) return tostring(...) end;
]])();

--! =============================================================
--! 2. 자동 패링 스크립트 (PlayerDevice 사용)
--! =============================================================

local AutoParryScriptCode = [[
    local LocalPlayer = game.Players.LocalPlayer
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")
    
    -- 🚨 RemoteEvent 이름을 'PlayerDevice'로 고정했습니다.
    local ParryEventName = "PlayerDevice" 
    local ParryRemote = ReplicatedStorage:FindFirstChild(ParryEventName)
    
    if not ParryRemote or not ParryRemote:IsA("RemoteEvent") then
        warn("❌ RemoteEvent ('" .. ParryEventName .. "')를 찾을 수 없습니다. (마지막 후보)")
        return 
    end

    print("🚀 RemoteEvent 발견: " .. ParryEventName .. ". 최종 루프 시작 (PlayerDevice).")
    
    -- RemoteEvent를 찾았을 경우, 패링 루프를 시작합니다.
    local function AutoParryLogic()
        -- 인수를 제거하고 호출. PlayerDevice는 입력 자체를 담당할 수 있습니다.
        ParryRemote:FireServer() 
    end

    local lastAttempt = 0
    local COOLDOWN = 0.05 -- 패링 시도 간격 (50ms)

    RunService.Heartbeat:Connect(function(dt)
        local now = tick()
        if now - lastAttempt > COOLDOWN then
            AutoParryLogic()
            lastAttempt = now
        end
    end)
    
    print("✅ 자동 패링 활성화. 이제 작동 여부를 확인하세요.")
]]

--! =============================================================
--! 3. 실행 로직 (이전과 동일)
--! =============================================================

local DEATH_BALL_GAME_ID = 5166944221
local CurrentGameId = game.GameId

local function ExecuteScript()
    print("🔑 현재 게임 ID: " .. CurrentGameId)

    if CurrentGameId == DEATH_BALL_GAME_ID then
        print("✅ Death Ball Game Detected. Executing Auto-Parry script...")

        local success, err = pcall(function()
            loadstring(AutoParryScriptCode)()
        end)

        if success then
            print("🚀 스크립트 실행이 성공했습니다.")
        else
            warn("❌ 스크립트 실행에 실패했습니다: " .. tostring(err))
        end
        
    else
        warn("🚫 현재 게임 ID는 Death Ball이 아닙니다. 스크립트가 실행되지 않았습니다.")
    end
end

task.spawn(ExecuteScript)
