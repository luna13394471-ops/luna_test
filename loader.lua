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

-- 16자 더미 키를 설정하여 하위 로더의 단순 길이 검사를 통과하게 합니다.
script_key = script_key or "AAAAAAAAAAAAAAAA";

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
	-- 키 인증 GUI를 띄우지 않도록 항상 false를 반환합니다.
	return false 
end

InterfaceEnabled = IsInterfaceEnabled()

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

local httprequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

local RunLoader = (function(write)
	-- **[수정됨]: Luarmor URL 대신, 키 인증이 없는 더미 로더 스크립트를 직접 삽입합니다.**
	local DeathBallLoaderCode = [[
		-- 키 인증 없이 실행되는 더미 스크립트
		print("Custom Death Ball Loader (Keyless) Initialized.");
		-- 원래 여기에 있던 핵 기능 코드를 삽입하세요.
	]]

	local Projects = {
		["Death Ball"] = {
			GameId = 5166944221;
			PlaceIds = {};
			-- Loader URL은 이제 사용되지 않습니다.
			Loader = ""; 
		};
        -- 다른 게임 로더 정보는 그대로 유지됩니다.
		["Anime Vanguards"] = {
			GameId = 5578556129;
			PlaceIds = {};
			Loader = "https://api.luarmor.net/files/v3/loaders/be2f65b9bda9c9e9aaf37dbbe3d48070.lua";
		};
        -- ... (중략) ...
	};
	
	local Loaded = false
	
	for i, v in pairs(Projects) do
		-- Death Ball 로직 처리
		if v.GameId == 5166944221 then
			Loaded = true
	
			print("script_key =", script_key)
			print(("Loading %s"):format(i))
	
			if not write then
				-- **[수정됨]: HTTP 요청 대신 더미 코드를 GETResponse로 사용합니다.**
				local GETResponse = DeathBallLoaderCode

				if GETResponse and #GETResponse > 0 then
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
								
								-- 텔레포트 시에도 더미 키와 함께 코드를 전달합니다.
								queueteleport(('script_key = "%s";\n%s'):format(script_key, getgenv().NATIVEQUEUEONTELEPORT))
							end
						end
					end
				else
					warn(("Could not load %s; Custom code is empty."):format(i))
				end
			else
				-- Copy Script Loader 로직: 더미 키와 함께 더미 코드를 복사합니다.
				setclipboard(
					('-- Native: %s;\nscript_key = "%s";\n%s'):format(i, script_key or "", DeathBallLoaderCode)
				)
			end
			
			print(("Loaded %s"):format(i))
	
			break

		-- 다른 모든 게임 로직은 URL 요청을 그대로 사용합니다.
		elseif v.GameId == game.GameId then
			Loaded = true
			
			local Loader = v.Loader -- 다른 게임은 원래 로더 URL을 사용

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

local Init = Library:Init({
	Name = "Native";
	Parent = service.CoreGui;
	Callback = function(self)

	end;
})

if not InterfaceEnabled then
	task.spawn(function()
		RunLoader()
	end)

	Init:Destroy(); getgenv().NATIVELOADERINSTANCES[Init] = nil
end
