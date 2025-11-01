--! Main Script: Death Ball Auto-Parry Executor (최종, 키리스, 자동 디버깅)
-- 키 인증 제거 및 5가지 RemoteEvent 이름 자동 테스트 로직 통합.

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
--! 2. 자동 패링 스크립트 (자동 디버깅 로직 통합)
--! =============================================================

-- 🚨 이 변수 안에 자동 패링 로직과 자동 디버깅 로직이 포함됩니다.
local AutoParryScriptCode = [[
    local LocalPlayer = game.Players.LocalPlayer
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")
    
    -- 🔑 가장 흔하거나 이전에 시도했던 RemoteEvent 이름 목록입니다.
    local PotentialParryEvents = {
        "ParryRemote", 
        "ParryEvent",
        "RequestParry",
        "Parry", 
        "DefenseEvent" 
    }
    
    local ParryRemote = nil
    local ParryEventName = nil

    print("✅ 자동 패리 코어 초기화 중... RemoteEvent 이름 자동 탐색 시작.")

    -- 이름 목록을 순회하며 존재하는 RemoteEvent를 찾습니다.
    for i, name in ipairs(PotentialParryEvents) do
        print("🔍 " .. i .. "/" .. #PotentialParryEvents .. " 시도 중: " .. name)
        local remote = ReplicatedStorage:FindFirstChild(name)
        
        if remote and remote:IsA("RemoteEvent") then
            ParryRemote = remote
            ParryEventName = name
            print("🚀 RemoteEvent 발견! 이름: " .. ParryEventName .. " 에서 패링 시작.")
            break 
        end
    end

    if not ParryRemote then
        warn("❌ 시도된 모든 이름으로 RemoteEvent를 찾을 수 없습니다. F9 콘솔 확인 필수!")
        return 
    end
    
    -- RemoteEvent를 찾았을 경우, 패링 루프를 시작합니다.
    local function AutoParryLogic()
        -- ⚠️ 공격 감지 로직은 없지만, 찾은 RemoteEvent를 호출합니다.
        ParryRemote:FireServer()
    end

    local lastAttempt = 0
    local COOLDOWN = 0.1 

    RunService.Heartbeat:Connect(function(dt)
        local now = tick()
        if now - lastAttempt > COOLDOWN then
            AutoParryLogic()
            lastAttempt = now
        end
    end)
    
    print("✅ 자동 패리 활성화. 사용 중인 이벤트: " .. ParryEventName)
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
        
        -- Queue On Teleport 로직은 제거하여 최대한 간소화합니다. (필요 시 복구 가능)
    else
        warn("🚫 현재 게임 ID는 Death Ball이 아닙니다. 스크립트가 실행되지 않았습니다.")
    end
end

-- 스크립트 실행을 시작합니다.
task.spawn(ExecuteScript)
