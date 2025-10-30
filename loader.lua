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

-- script_key 변수 무의미하게 남겨둠 (필요 없음)
script_key = ""

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

-- 인터페이스 무조건 비활성화, 키 인증 완전 무시
local InterfaceEnabled = false

local Library = (getgenv and getgenv().NATIVELIBRARY) or loadstring(game:HttpGet("https://getnative.cc/script/interface", true))(getgenv().NATIVELIBRARY)
getgenv().NATIVELIBRARY = Library

local service = setmetatable({}, {
	__index = function(self, key)
		return (cloneref or function(service) return service end)(game.GetService(game, key))
	end
})

local HttpService = service.HttpService

local Data = {
	Toggle = {
		["General"] = true;
		["Loader.Load: Queue On Teleport"] = false;
	};
	Input = {};
}

-- 디폴트 저장 경로 및 파일 설정
local RootDir = "Native"
if not (isfolder(RootDir) or isfile(RootDir)) then
	makefolder(RootDir)
end
local Dir = RootDir .. "/Loader"
if not (isfolder(Dir) or isfile(Dir)) then
	makefolder(Dir)
end

local Interfaces = {}

local httprequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request

local RunLoader = (function(write)
	local Projects = {
		["Death Ball"] = {
			GameId = 5166944221;
			Loader = "https://api.luarmor.net/files/v3/loaders/2623c74821b882b1e5e529b9078bd30a.lua";
		};
		["Anime Vanguards"] = {
			GameId = 5578556129;
			Loader = "https://api.luarmor.net/files/v3/loaders/be2f65b9bda9c9e9aaf37dbbe3d48070.lua";
		};
		-- 필요한 다른 프로젝트도 동일하게 여기에 작성 가능
	};
	
	local Loaded = false
	
	for i, v in pairs(Projects) do
		if v.GameId == game.GameId then
			Loaded = true
			print("Loading " .. i)
			if not write then
				local GETResponse = game.HttpGet(game, v.Loader)
				if GETResponse then
					getgenv().NATIVELOADED = true
					(loadstring or load)(GETResponse)()
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
					warn("Could not fetch loader script.")
				end
			end
			break
		end
	end
	
	if not Loaded then
		warn("Unrecognized GameId " .. tostring(game.GameId))
	end
end)

local LoadFunction = function(Init, Window)
	Window:Destroy()
	RunLoader()
	Init:Notify({
		Name = "Loaded",
		Body = "",
		Duration = 5,
		Callback = function(self) end,
	})
	task.spawn(function()
		task.wait(2.5)
		Init:Destroy()
		getgenv().NATIVELOADERINSTANCES[Init] = nil
	end)
end

local Init = Library:Init({
	Name = "Native",
	Parent = service.CoreGui,
	Callback = function(self) end,
})

do
	local Window = Init:CreateWindow({
		Name = "Loader",
		Visible = true,
		Silent = false,
		Asset = false,
		Keybind = Enum.KeyCode.RightShift,
		Callback = function(self) end,
	}); do
		local Loader = Window:CreateTab({
			Name = "Loader",
			Home = true,
			LayoutOrder = 1,
			Callback = function(self) end,
		})
		local Load = Loader:CreateSection({Name = "Load", Visible = true, LayoutOrder = 1})
		-- 키 입력 UI, 버튼, 복사 기능 모두 완전 제거되어 여기에 관여하는 코드는 없음

		Load:CreateToggle({
			Name = "Queue On Teleport (Execute Native On Teleport AKA Auto-Execute On Teleport)",
			Initial = true,
			LayoutOrder = 1,
			Value = Data.Toggle["Loader.Load: Queue On Teleport"],
			Callback = function(self, Value)
				Data.Toggle["Loader.Load: Queue On Teleport"] = Value
				if Value then
					Init:Notify({
						Name = "Queuing On Teleport",
						Body = "",
						Duration = 5,
						Callback = function(self) end,
					})
				end
			end,
		})

		Load:CreateButton({
			Name = "Join Our Discord Server",
			Initial = false,
			LayoutOrder = 2,
			Callback = function(self)
				setclipboard("https://discord.gg/natives")
				Init:Notify({
					Name = "Copied Discord Url",
					Body = "",
					Duration = 2.5,
					Callback = function(self) end,
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
			end,
		})

		Load:CreateButton({
			Name = "Copy Script Loader",
			Initial = false,
			LayoutOrder = 3,
			Callback = function(self)
				RunLoader(true)
				Init:Notify({
					Name = "Copied Script Loader",
					Body = "",
					Duration = 2.5,
					Callback = function(self) end,
				})
			end,
		})

		Load:CreateButton({
			Name = "Destroy",
			Initial = false,
			LayoutOrder = 4,
			Callback = function(self)
				Init:Destroy()
				getgenv().NATIVELOADERINSTANCES[Init] = nil
			end,
		})
		-- 변경 로그 표시 UI 등 생략
	end
end

if not InterfaceEnabled then
	task.spawn(function()
		RunLoader()
	end)

	Init:Destroy()
	getgenv().NATIVELOADERINSTANCES[Init] = nil
end