--! Main Script: Death Ball Auto-Parry Executor (최종, FinisherRemote - 인수 제거)

-- (키 인증 제거 및 서비스 초기화 로직은 이전과 동일)

getgenv().NATIVELOADERINSTANCES = getgenv().NATIVELOADERINSTANCES or {}
script_key = "AAAAAAAAAAAAAAAA" 

local game = game
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

loadstring([[
	function LPH_NO_VIRTUALIZE(f) return f end;
	function LPH_JIT(f) return f end;
	function LPH_JIT_MAX(f) return f end;
	function LRM_SANITIZE(...) return tostring(...) end;
]])();

--! =============================================================
--! 2. 자동 패링 스크립트 (FinisherRemote 사용, 인수 제거)
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

    print("🚀 RemoteEvent 발견: " .. ParryEventName .. ". 최종 루프 시작 (인수 제거).")
    
    local function AutoParryLogic()
        -- 💡 수정된 부분: 인수를 완전히 제거하고 호출 (서버가 인수를 요구하지 않을 경우)
        ParryRemote:FireServer() 
    end

    local lastAttempt = 0
    local COOLDOWN = 0.05 

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
