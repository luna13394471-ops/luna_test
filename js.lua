--! Main Script File: Deathball.lua

-- 'game' 객체는 현재 Roblox 게임 인스턴스를 나타냅니다.
local game = game
-- 'workspace'는 게임 세계의 모든 물리적 객체(파트, 모델 등)를 포함하는 컨테이너입니다.
local workspace = game.Workspace
-- 'Players' 서비스는 게임에 접속한 모든 플레이어의 정보를 관리합니다.
local players = game:GetService("Players")
-- 'ReplicatedStorage'는 클라이언트와 서버가 공유하는 저장 공간입니다.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--! =============================================================
--! 1. 변수 설정 및 초기화
--! =============================================================

-- 플레이어의 캐릭터나 스크립트가 영향을 줄 특정 객체를 찾습니다.
local character = players.LocalPlayer.Character or players.LocalPlayer.CharacterAdded:Wait()
-- 데스볼 객체 자체(또는 데스볼을 생성/제어하는 객체)를 'ReplicatedStorage'에서 가져옵니다.
local deathBallRemote = ReplicatedStorage:FindFirstChild("DeathBallHandler")

-- 스크립트의 활성화 상태를 나타내는 부울 변수입니다.
local isScriptEnabled = true
-- 자동 파밍/공격 기능의 목표 대상을 저장할 변수입니다.
local target = nil

--! =============================================================
--! 2. 핵심 기능: 데스볼 생성 또는 조작
--! =============================================================

-- 상대방을 추적하고 공격하는 자동 공격 함수입니다.
local function AutoAttack()
    -- 스크립트가 활성화되지 않았거나 목표가 없으면 함수를 종료합니다.
    if not isScriptEnabled or not target then
        return
    end

    -- 목표의 위치를 가져옵니다.
    local targetPosition = target.Position

    -- 원격 이벤트(RemoteEvent)를 사용하여 서버에 데스볼 발사를 요청합니다.
    if deathBallRemote and deathBallRemote:IsA("RemoteEvent") then
        -- 서버로 목표 위치와 파워 레벨 등의 인수를 전송합니다.
        deathBallRemote:FireServer(targetPosition, 100) -- 예시 인자: 목표 위치, 파워 100
    end
end

--! =============================================================
--! 3. 이벤트 루프 및 메인 로직
--! =============================================================

-- 무한 루프를 사용하여 주기적으로 스크립트 로직을 실행합니다.
while isScriptEnabled do
    -- 플레이어 목록을 순회하며 가장 가까운 목표를 찾거나 미리 설정된 목표를 유지합니다.
    target = FindNearestEnemy() -- 'FindNearestEnemy'는 별도로 정의된 함수라고 가정

    -- 자동 공격 기능을 실행합니다.
    AutoAttack()

    -- 성능을 위해 잠시 대기합니다 (초당 프레임 수 조절).
    task.wait(0.1) -- 0.1초마다 루프 실행
end

--! =============================================================
--! 4. 보조 함수 (가정)
--! =============================================================

-- 가장 가까운 적을 찾는 함수 (가정)
function FindNearestEnemy()
    -- ... 적을 찾는 복잡한 로직 ...
    return someEnemyPart -- 찾은 적의 Part를 반환
end
