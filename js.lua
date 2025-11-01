--! Main Script: Death Ball Auto-Parry Executor (최종, 키리스, FinisherRemote 고정)
-- 키 인증 제거 및 RemoteEvent 이름을 'FinisherRemote'로 고정하여 통합했습니다.

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
--! 2. 자동 패링 스크립트 (FinisherRemote 사용)
--! =============================================================

local AutoParryScriptCode = [[
    local LocalPlayer = game.Players.LocalPlayer
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")
    
    -- 🚨 RemoteEvent 이름을 'FinisherRemote'로 고정했습니다.
    local ParryEventName = "FinisherRemote" 
    
    local ParryRemote = ReplicatedStorage:FindFirstChild(ParryEventName)
    
    if not ParryRemote or not ParryRemote:IsA("RemoteEvent") then
        warn("❌ RemoteEvent ('" .. ParryEventName .. "')를 찾을 수 없습니다. 이름 확인이 필요합니다.")
        return 
    end

    print("🚀 RemoteEvent 발견: " .. ParryEventName .. ". 자동 패링 루프 시작.")
    
    -- RemoteEvent를 찾았을 경우, 패링 루프를 시작합니다.
    local function AutoParryLogic()
        -- ⚠️ 공격 감지 로직은 없지만, 찾은 RemoteEvent를 호출하여 패링을 시도합니다.
        -- FinisherRemote가 패링/방어와 관련된 이벤트를 처리하기를 기대합니다.
        ParryRemote:FireServer()
    end

    local lastAttempt = 0
    local COOLDOWN = 0.05 -- 패링 시도 간격을 50ms로 더 줄여서 응답성을 높입니다.

    RunService.Heartbeat:Connect(function(dt)
        local now = tick()
        if now - lastAttempt > COOLDOWN then
            AutoParryLogic()
            lastAttempt = now
        end
    end)
    
    print("✅ 자동 패링 활성화. 이제 Death Ball에 입장하여 작동을 확인하세요.")
]]

--! =============================================================
--! 3. 실행 로직 (키 인증 및 GUI 제거)
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
