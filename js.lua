--! Main Script: Death Ball Auto-Parry Executor (최종, 키리스, FinisherRemote + 인수 추가)
-- 키 인증 제거 및 RemoteEvent 이름을 'FinisherRemote'로 고정하고 인수를 추가했습니다.

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
--! 2. 자동 패링 스크립트 (FinisherRemote 사용, 인수 포함)
--! =============================================================

local AutoParryScriptCode = [[
    local LocalPlayer = game.Players.LocalPlayer
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")
    
    -- 🚨 RemoteEvent 이름을 'FinisherRemote'로 고정했습니다.
    local ParryEventName = "FinisherRemote" 
    local ParryRemote = ReplicatedStorage:FindFirstChild(ParryEventName)
    
    if not ParryRemote or not ParryRemote:IsA("RemoteEvent") then
        warn("❌ RemoteEvent ('" .. ParryEventName .. "')를 찾을 수 없습니다. (발견되었으나 재확인)")
        return 
    end

    print("🚀 RemoteEvent 발견: " .. ParryEventName .. ". 최종 루프 시작 (인수 추가).")
    
    -- RemoteEvent를 찾았을 경우, 패링 루프를 시작합니다.
    local function AutoParryLogic()
        -- 💡 인수를 포함하여 FireServer를 호출합니다.
        -- MouseButton1 (좌클릭)은 패링/공격 입력으로 흔히 사용되는 Enum 값입니다.
        ParryRemote:FireServer(Enum.UserInputType.MouseButton1)
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
