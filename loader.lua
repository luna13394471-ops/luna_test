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

-- 키 변수는 유지하되, 값이 없어도 상관없도록 처리
script_key=script_key or "";

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

local IsInterfaceEnabled = function()
    -- **[수정됨]: 항상 false를 반환하여 키 유효성 검사를 무시하고 로더를 실행합니다.**
	return false 
end

InterfaceEnabled = IsInterfaceEnabled() -- 이제 InterfaceEnabled는 항상 false입니다.

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
local APIToken = "Submarine" or "(__YourAPIToken__)"
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

-- UI 제거로 인해 데이터 저장이 불필요하지만, 로직 유지를 위해 남겨둠
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
		["Loader.Load: Key"] = "";
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

-- local Interfaces = {} -- UI 제거로 인해 불필요

local httprequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

local RunLoader = (function(write)
	local Projects = {
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

					(
						loadstring or load
					)(
						GETResponse
					)()

					if Data.Toggle["Loader.Load: Queue On Teleport"] then
						if not getgenv().NATIVEQUEUEONTELEPORT then
							local queueteleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport)

							if queueteleport then
								getgenv().NATIVEQUEUEONTELEPORT = GETResponse

								queueteleport(('script_key = "%s";\n%s'):format(script_key, getgenv().NATIVEQUEUEONTELEPORT))
							end
						end
					end
				else
					warn(("Could not fetch %s; Suggest switching to an executor that isn't any of the following: Solara and Xeno"):format(Loader or "loader"))
				end
			else
				local InterfaceEnabled = false

				if not script_key
				or #script_key < 16 then
					InterfaceEnabled = true
				end

				setclipboard(
					('-- Native: %s;\nscript_key = "%s";\n(loadstring or load)(game:HttpGet("%s"))();'):format(i, not InterfaceEnabled and script_key or "", v.Loader)
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

-- **[삭제됨]: 키 입력 GUI를 로드 후 파괴하는 LoadFunction 함수 제거**

-- **[남아있음]: UI를 생성하는 Init 호출(라이브러리를 초기화만 하고 UI는 만들지 않습니다)**
local Init = Library:Init({
	Name = "Native";
	Parent = service.CoreGui;
	Callback = function(self)

	end;
})

-- **[삭제됨]: 전체 UI 생성 및 처리 로직 제거 (Init:CreateWindow 부터 끝까지)**
-- do
-- 	local Window = Init:CreateWindow({
-- 		... (전체 UI 관련 코드) ...
-- 	end
-- end


-- **[수정됨]: InterfaceEnabled가 항상 false이므로, 로더가 즉시 실행됩니다.**
if not InterfaceEnabled then
	task.spawn(function()
		RunLoader()
	end)

	Init:Destroy(); getgenv().NATIVELOADERINSTANCES[Init] = nil
end
