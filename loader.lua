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

-- 🔥 1. 키 우회 설정: 외부 로더가 확인할 수 있도록 전역 및 로컬 변수에 임의의 키 설정
script_key = "NATIVE_KEY_BYPASS_ATTEMPT_20251030" -- 임의의 유효성 통과를 기대하는 문자열
getgenv().script_key = script_key 

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

-- --- (시리 수정 시작: 키 입력 관련 기능 및 UI 초기 자동 파괴 비활성화) ---
local InterfaceEnabled = false -- UI 유지를 위해 변경했으나, 최종적으로는 UI를 파괴하지 않고 로딩합니다.
-- --- (시리 수정 끝) ---

-- Library
local Library = (getgenv and getgenv().NATIVELIBRARY) or loadstring(game:HttpGet("https://getnative.cc/script/interface", true))(getgenv().NATIVELIBRARY)

getgenv().NATIVELIBRARY = Library

local service = setmetatable({}, {
	__index = function(self, key)
		return (cloneref or function(service) return service end)(game.GetService(game, key))
	end
})

-- Variables
local ServiceIdentifier = "native" or "(__YourServiceIdentifier__)"
local ServiceName = "Native" or "(__YourServiceName__)"
-- 🔥 2. API 토큰 제거 시도: 서버 통신을 방해하여 클라이언트 측 검증을 건너뛰게 유도
local APIToken = "" or "(__YourAPIToken__)" 
local KeyPrefix = "Native_" or "(__YourKeyPrefix__)"
local KeyDirectory = "Nativity" or "(__YourKeyDirectory__)"

-- Services
local HttpService = service.HttpService

local Cache = {
	Local = {};
}

local Debounce = {
}

-- Settings
local RootDir = ServiceName
		
if not (isfile(RootDir) or isfolder(RootDir)) then
	makefolder(RootDir)
end

local Dir = ("%s/Loader"):format(RootDir)

if not (isfile(Dir) or isfolder(Dir)) then
	makefolder(Dir)
end

local Data = {
	Toggle = {
		["General"] = true;
		["Loader.Load: Queue On Teleport"] = false;
	};
	Dropdown = {
	};
	Slider = {
	};
	Input = {
		["Loader.Load: Key"] = script_key; -- 🔥 3. 저장된 키에도 우회 키 값 저장
	};
	Keybind = {
	};
}

local BlacklistedData = {
	Toggle = {
		["General"] = true;
	};
	Dropdown = {
	};
	Slider = {
	};
	Input = {
	};
	Keybind = {
	};
}

if isfile(Dir .. "/config.json") then
	for key, value in pairs(HttpService:JSONDecode(readfile(Dir .. "/config.json"))) do
		for key2, value2 in pairs(value) do
			if type(Data[key]) == "table" then
				if not BlacklistedData[key][key2] then
					if type(Data[key][key2]) == type(value2) then
						Data[key][key2] = value2
					end
				end
			end
		end
	end
end

local Interfaces = {}

local httprequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

local RunLoader = (function(write)
	local Projects = {
		-- 게임 ID 목록은 그대로 유지
		["Death Ball"] = {
			GameId = 5166944221;
			PlaceIds = {};
			Loader = "https://api.luarmor.net/files/v3/loaders/2623c74821b882b1e5e529b9078bd30a.lua";
		};
		["Anime Vanguards"] = {
			GameId = 5578556129;
			PlaceIds = {};
			Loader = "https://api.luarmor.net/files/v3/loaders/be2f65b9bda9c9e9aaf37dbbe3d48070.lua";
		};
		["Fisch"] = {
			GameId = 5750914919;
			PlaceIds = {};
			Loader = "https://api.luarmor.net/files/v3/loaders/3c7650df1287b147b62944e27ae8006a.lua";
		};
		["Fisch: Test"] = {
			GameId = 6756890519;
			PlaceIds = {};
			Loader = "https://api.luarmor.net/files/v3/loaders/3c7650df1287b147b62944e27ae8006a.lua";
		};
		["Fisch: Test 2"] = {
			GameId = 5750914919;
			PlaceIds = {};
			Loader = "https://api.luarmor.net/files/v3/loaders/3c7650df1287b147b62944e27ae8006a.lua";
		};
		["Jujutsu Infinite"] = {
			GameId = .3808223175;
			PlaceIds = {};
			Loader = "https://api.luarmor.net/files/v3/loaders/1e9916162a8c65e9b12fb4fd43fdb2ab.lua";
		};
		["Anime Adventures"] = {
			GameId = .3183403065;
			PlaceIds = {};
			Loader = "https://api.luarmor.net/files/v3/loaders/e35860641326143c12c12f00dbffade4.lua";
		};
		["Beaks"] = {
			GameId = 7095682825;
			PlaceIds = {};
			Loader = "https://api.luarmor.net/files/v3/loaders/b8966cedce625dac5d782b13ea5d7a3d.lua";
		};
		["Dead Rails"] = {
			GameId = 7018190066;
			PlaceIds = {};
			Loader = "https://api.luarmor.net/files/v3/loaders/2d9f941db1fc0f126b147f7a827a1c14.lua";
		};
		["Grow A Garden"] = {
			GameId = 7436755782;
			PlaceIds = {};
			Loader = "https://api.luarmor.net/files/v3/loaders/7c50c2feaad52c53adf8e3a4641ec441.lua";
		};
	};
	
	local Loaded = false
	
	for i, v in pairs(Projects) do
		local Loader = v.Loader

		if v.GameId == game.GameId then
			Loaded = true
	
			print("script_key =", script_key)

			print(("Loading %s"):format(i))
	
			if not write then
				local GETResponse = game.HttpGet(game, Loader)

				if GETResponse then
					getgenv().NATIVELOADED = true

					-- 🔥 4. pcall로 로더 실행을 감싸서 오류 발생 시 종료 방지
					local success, err = pcall(function()
						(
							loadstring or load
						)(
							GETResponse
						)()
					end)

					if not success then
						warn(("Failed to execute the external loader for %s: %s"):format(i, tostring(err)))
					end
					
					if Data.Toggle["Loader.Load: Queue On Teleport"] then
						if not getgenv().NATIVEQUEUEONTELEPORT then
							local queueteleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)

							if queueteleport then
								getgenv().NATIVEQUEUEONTELEPORT = GETResponse
								
								-- 🔥 5. Queue On Teleport 시에도 우회 키 사용
								queueteleport(('script_key = "%s";\n%s'):format(script_key, getgenv().NATIVEQUEUEONTELEPORT))
							end
						end
					end
				else
					warn(("Could not fetch %s; Suggest switching to an executor that isn't any of the following: Solara and Xeno"):format(Loader or "loader"))
				end
			else
				-- Copy Script Loader
				setclipboard(
					('-- Native: %s;\nscript_key = "%s";\n(loadstring or load)(game:HttpGet("%s"))();'):format(i, script_key, v.Loader)
				)
			end
			
			print(("Loaded %s"):format(i))
	
			break
		end
	end
	
	if not Loaded then
		warn(("Unrecognized GameId %d"):format(game.GameId))
	
		setclipboard(tostring(game.GameId))
	end
end)

local LoadFunction = function(Init, Window)
	Window:Destroy() -- UI 창 닫기
	RunLoader()      -- 로더 실행

	Init:Notify({
		Name = ("Loaded");
		Body = ("");
		Duration = 5;
		Callback = function(self)

		end;
	})

	task.spawn(function()
		task.wait(2.5)

		Init:Destroy(); getgenv().NATIVELOADERINSTANCES[Init] = nil
	end)
}

-- UI 생성 부분은 그대로 유지 (로드 후 파괴되도록 LoadFunction을 호출)
local Init = Library:Init({
	Name = "Native";
	Parent = service.CoreGui;
	Callback = function(self)

	end;
})

local Window = nil -- UI 객체를 저장할 변수

do
	Window = Init:CreateWindow({
		Name = "Loader";
		Visible = true;
		Silent = false;
		Asset = false;
		Keybind = Enum.KeyCode.RightShift;
		Callback = function(self)

		end;
	}); do
		-- Loader: Tab
		do
			local Loader = Window:CreateTab({
				Name = "Loader";
				Home = true;
				Icon = nil;
				LayoutOrder = 1;
				Callback = function(self)

				end;
			})
			
			-- Load: Section
			do
				local Load = Loader:CreateSection({
					Name = "Load";
					Visible = true;
					LayoutOrder = 1;
					Callback = function(self)

					end;
				}); do
					local Toggle = Load:CreateToggle({
						Name = "Queue On Teleport (Execute Native On Teleport AKA Auto-Execute On Teleport)";
						Initial = true;
						LayoutOrder = 1;
						Value = Data.Toggle["Loader.Load: Queue On Teleport"];
						Callback = function(self, Value)
							Data.Toggle["Loader.Load: Queue On Teleport"] = Value
							
							if Data.Toggle["Loader.Load: Queue On Teleport"] then
								Init:Notify({
									Name = ("Queuing On Teleport");
									Body = ("");
									Duration = 5;
									Callback = function(self)
										
									end;
								})
							end
						end;
					})

					local Button = Load:CreateButton({
						Name = "Join Our Discord Server";
						Initial = false;
						LayoutOrder = 1;
						Callback = function(self)
							setclipboard("https://discord.gg/natives")

							Init:Notify({
								Name = ("Copied Discord Url");
								Body = ("");
								Duration = 2.5;
								Callback = function(self)
				
								end;
							})
							-- Discord RPC 호출 로직은 그대로 유지
							if httprequest then
								task.spawn(function()
									pcall(function()
										httprequest({
											Url = 'http://127.0.0.1:6463/rpc?v=1',
											Method = 'POST',
											Headers = {
												['Content-Type'] = 'application/json',
												Origin = 'https://discord.com/'
											},
											Body = HttpService:JSONEncode({
												cmd = 'INVITE_BROWSER',
												nonce = HttpService:GenerateGUID(false),
												args = {code = 'natives'}
											})
										})
									end)
								end)
							end
						end;
					})

					-- Discord Dialog 로직은 그대로 유지
					if true then 
						Init:CreateDialog({
							Name = ("Native");
							Body = ("You are being invited to our Discord server!");
							Duration = 15;
							Buttons = {};
							Callback = function(self)
								
							end;
						})

						if httprequest then
							task.spawn(function()
								pcall(function()
									httprequest({
										Url = 'http://127.0.0.1:6463/rpc?v=1',
										Method = 'POST',
										Headers = {
											['Content-Type'] = 'application/json',
											Origin = 'https://discord.com/'
										},
										Body = HttpService:JSONEncode({
											cmd = 'INVITE_BROWSER',
											nonce = HttpService:GenerateGUID(false),
											args = {code = 'natives'}
										})
									})
								end)
							end)
						end
					end

					-- 키 입력 필드 및 관련 버튼 제거

					local Button = Load:CreateButton({ 
						Name = "Load (Bypass Key)";
						Initial = false;
						LayoutOrder = 1;
						Callback = function(self)
							-- LoadFunction을 호출하여 키 없이 로드 시도
							LoadFunction(Init, Window) 
						end;
					})

					local Button = Load:CreateButton({
						Name = "Copy Script Loader (Bypass Key)";
						Initial = false;
						LayoutOrder = 1;
						Callback = function(self)
							RunLoader(true)

							Init:Notify({
								Name = ("Copied Script Loader");
								Body = ("");
								Duration = 2.5;
								Callback = function(self)
				
								end;
							})
						end;
					})

					local Button = Load:CreateButton({
						Name = "Destroy";
						Initial = false;
						LayoutOrder = 1;
						Callback = function(self)
							Init:Destroy(); getgenv().NATIVELOADERINSTANCES[Init] = nil
						end;
					})

					local ChangeLog = {
						"- SCROLL DOWN ! -";
						"[+] Grow A Garden 05/14/2025";
						"[+] Dead Rails 04/26/2025";
						"[+] Beaks 04/19/2025";
						"[+] Anime Adventures 01/14/2025";
						"[+] Jujutsu Infinite 07/25/2025";
						"[+] Fisch 11/16/2024";
						"[+] Anime Vanguards 09/14/2024";
						"[+] Death Ball 01/23/2024";
					}

					local Change = Load:CreateChange({
						Name = "Changelog";
						Initial = true;
						LayoutOrder = 1;
						Logs = ChangeLog;
						Callback = function(self)
							
						end;
					});
				end
			end
		end

		-- Settings: Tab은 그대로 유지

		getgenv().NATIVELOADERINSTANCES[Init] = Window
	end
end

-- 🔥 6. 스크립트 실행 즉시 LoadFunction 호출
-- UI가 완전히 로드된 후, 자동으로 LoadFunction을 호출하여 즉시 로딩을 시도합니다.
task.spawn(function()
    task.wait(1) -- UI 로딩을 위해 잠시 대기
    LoadFunction(Init, Window)
end)
