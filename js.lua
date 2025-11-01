--! Main Script: Death Ball Auto-Parry Executor (Keyless & Full Integration)
-- 원본 Native Loader 구조에서 키 인증 및 GUI 로직을 제거하고, Death Ball (5166944221)에서
-- 내부 자동 패링 스크립트를 즉시 실행하도록 수정되었습니다.

--! =============================================================
--! 1. 전역 환경 및 설정 우회 (원본 로직 유지)
--! =============================================================

getgenv().NATIVELOADERINSTANCES = getgenv().NATIVELOADERINSTANCES or {}

if getgenv().NATIVELOADERINSTANCES and not getmetatable(getgenv().NATIVELOADERINSTANCES) then
	setmetatable(getgenv().NATIVELOADERINSTANCES, {
		__index = function(self, key)
			if key == "Len" then
				local Len = 0
				for i, v in pairs(self) do
					Len = Len + 1
				end
				return Len
			end
			return rawget(self, key)
		end;
	})
elseif getgenv().NATIVELOADERINSTANCES and getmetatable(getgenv().NATIVELOADERINSTANCES) then
	if getgenv().NATIVELOADED then
		warn("An instance is already running.")
	end
end

script_key = script_key or "AAAAAAAAAAAAAAAA"; -- 더미 키로 길이 검사를 통과

getgenv().NATIVESETTINGS = getgenv().NATIVESETTINGS or {
	OverwriteConfiguration = false;
	QueueOnTeleport = false;
}

loadstring([[
	function LPH_NO_VIRTUALIZE(f) return f end;
	function LPH_JIT(f) return f end;
	function LPH_JIT_MAX(f) return f end;
	function LRM_SANITIZE(...) return tostring(...) end;
]])();

local InterfaceEnabled = false 
-- IsInterfaceEnabled 함수는 키 체크를 하지만, 아래 로직에서 GUI를 실행하지 않도록 처리할 것입니다.

-- Library 로드는 제거하여 GUI 의존성을 없앱니다.
local service = setmetatable({}, {
	__index = function(self, key)
		return (cloneref or function(service) return service end)(game:GetService(key))
	end
})

-- Services 및 변수 초기화 (필요한 최소한만 유지)
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = service.HttpService -- 설정 저장/로드를 위해 남겨둡니다.

local Dir = "Native/Loader" -- 설정 저장 경로

-- 설정 로드는 그대로 유지 (Queue On Teleport 설정을 불러오기 위함)
local Data = {
	Toggle = {
		["General"] = true;
		["Loader.Load: Queue On Teleport"] = false; -- 이 설정 값을 사용합니다.
	};
	-- ... (나머지 설정 생략) ...
}

--! =============================================================
--! 2. 자동 패링 스크립트 (통합된 기능)
--! =============================================================

-- 🚨🚨🚨 [여기에 자동 패링 로직을 직접 삽입] 🚨🚨🚨
local AutoParryScriptCode = [[
    print("✅ Death Ball Auto-Parry Core Initializing...")
    
    local LocalPlayer = game.Players.LocalPlayer
    
    -- 🚨🚨🚨 [필수 수정] 🚨🚨🚨
    -- 당신의 서버 스크립트가 사용하는 실제 RemoteEvent 이름으로 'Parry'를 변경하세요.
    local ParryEventName = "Parry" 
    
    local Parry = game.ReplicatedStorage:FindFirstChild(ParryEventName) 
    
    if not Parry or not Parry:IsA("RemoteEvent") then
        warn("❌ Parry RemoteEvent ('" .. ParryEventName .. "')를 찾을 수 없습니다. 이름 및 경로 확인 필수!")
        return 
    end

    print("🚀 Auto-Parry Remote Found. Starting detection loop...")
    
    local function AutoParryLogic()
        -- ⚠️ 여기에 공격을 감지하는 실제 로직을 삽입해야 합니다.
        -- 현재는 디버깅 목적으로 RemoteEvent를 호출하는 가장 단순한 패턴을 사용합니다.
        Parry:FireServer()
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
    
    print("✅ Auto-Parry Active.")
]]

--! =============================================================
--! 3. 실행 로직 (RunLoader 간소화 및 대체)
--! =============================================================

local RunLoader = (function(write)
	local DEATH_BALL_GAME_ID = 5166944221
	local Loaded = false
	
    -- Death Ball 로직 처리
	if game.GameId == DEATH_BALL_GAME_ID then
		Loaded = true
		
		print("script_key =", script_key)
		print("Loading Death Ball (Custom Auto-Parry)")
		
		if not write then
			local GETResponse = AutoParryScriptCode -- Luarmor 대신 내장된 코드를 사용
			
			if GETResponse and #GETResponse > 0 then
				getgenv().NATIVELOADED = true

				(
					loadstring or load
				)(
					GETResponse
				)()

                -- Queue On Teleport 로직은 그대로 유지합니다.
				if Data.Toggle["Loader.Load: Queue On Teleport"] then
					if not getgenv().NATIVEQUEUEONTELEPORT then
						local queueteleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)

						if queueteleport then
							getgenv().NATIVEQUEUEONTELEPORT = GETResponse
							
                            -- 텔레포트 시에도 내장된 코드를 재실행하도록 대기열에 추가합니다.
							queueteleport(('script_key = "%s";\n%s'):format(script_key, getgenv().NATIVEQUEUEONTELEPORT))
						end
					end
				end
			else
				warn("Could not load Death Ball; Custom Auto-Parry code is empty.")
			end
		else
            -- Copy Script Loader 로직: 클립보드에 내장 코드를 복사합니다.
			setclipboard(
				('-- Native: Death Ball;\nscript_key = "%s";\n%s'):format(script_key or "", AutoParryScriptCode)
			)
		end
		
		print("Loaded Death Ball")
	end
	
	if not Loaded then
		warn(("Unrecognized GameId %d"):format(game.GameId))
		setclipboard(tostring(game.GameId))
	end
end)

-- 원본 코드는 키 인증이 실패하면 GUI를 띄우지만, 우리는 GUI 없이 바로 로더를 실행합니다.
task.spawn(function()
	RunLoader()
end)

-- GUI 관련 코드(Library:Init, Window:CreateTab 등)는 모두 제거됩니다.
