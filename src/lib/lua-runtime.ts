/**
 * Wasmoon Lua 런타임 래퍼
 * 브라우저에서 Lua 코드를 실행하기 위한 모듈
 */

import { LuaFactory, LuaEngine } from 'wasmoon';

// Roblox API 모킹
const ROBLOX_MOCK = `
-- Roblox Global Mocks
local _outputs = {}

-- print override
local _originalPrint = print
function print(...)
    local args = {...}
    local str = ""
    for i, v in ipairs(args) do
        if i > 1 then str = str .. "\\t" end
        str = str .. tostring(v)
    end
    table.insert(_outputs, {type = "log", message = str})
    _originalPrint(...)
end

function warn(...)
    local args = {...}
    local str = ""
    for i, v in ipairs(args) do
        if i > 1 then str = str .. "\\t" end
        str = str .. tostring(v)
    end
    table.insert(_outputs, {type = "warn", message = str})
end

-- wait (비동기 시뮬레이션)
function wait(seconds)
    seconds = seconds or 0.03
    return seconds
end

task = {
    wait = wait,
    spawn = function(f) f() end,
    delay = function(t, f) f() end
}

-- BrickColor
BrickColor = {
    new = function(name)
        return {
            Name = name,
            Color = {R = 1, G = 1, B = 1},
            __tostring = function() return "BrickColor(" .. name .. ")" end
        }
    end
}

-- Color3
Color3 = {
    new = function(r, g, b)
        return {R = r or 0, G = g or 0, B = b or 0}
    end,
    fromRGB = function(r, g, b)
        return {R = (r or 0)/255, G = (g or 0)/255, B = (b or 0)/255}
    end
}

-- Vector3
Vector3 = {
    new = function(x, y, z)
        return {
            X = x or 0, Y = y or 0, Z = z or 0,
            Magnitude = math.sqrt((x or 0)^2 + (y or 0)^2 + (z or 0)^2)
        }
    end,
    zero = {X = 0, Y = 0, Z = 0, Magnitude = 0}
}

-- CFrame
CFrame = {
    new = function(x, y, z)
        return {
            X = x or 0, Y = y or 0, Z = z or 0,
            Position = Vector3.new(x, y, z)
        }
    end
}

-- UDim2
UDim2 = {
    new = function(xs, xo, ys, yo)
        return {X = {Scale = xs or 0, Offset = xo or 0}, Y = {Scale = ys or 0, Offset = yo or 0}}
    end,
    fromScale = function(x, y)
        return UDim2.new(x, 0, y, 0)
    end,
    fromOffset = function(x, y)
        return UDim2.new(0, x, 0, y)
    end
}

-- 가상 인스턴스 생성
local function createInstance(className, parent)
    local instance = {
        ClassName = className,
        Name = className,
        Parent = parent,
        _children = {},

        FindFirstChild = function(self, name)
            for _, child in ipairs(self._children) do
                if child.Name == name then return child end
            end
            return nil
        end,

        GetChildren = function(self)
            return self._children
        end,

        Destroy = function(self)
            if self.Parent then
                for i, child in ipairs(self.Parent._children) do
                    if child == self then
                        table.remove(self.Parent._children, i)
                        break
                    end
                end
            end
            self.Parent = nil
        end,

        Clone = function(self)
            return createInstance(self.ClassName, nil)
        end
    }

    -- Part 속성
    if className == "Part" or className == "BasePart" then
        instance.Position = Vector3.new(0, 0, 0)
        instance.Size = Vector3.new(4, 1, 2)
        instance.BrickColor = BrickColor.new("Medium stone grey")
        instance.Color = Color3.fromRGB(163, 162, 165)
        instance.Transparency = 0
        instance.Anchored = false
        instance.CanCollide = true
        instance.Material = "Plastic"
    end

    -- Humanoid 속성
    if className == "Humanoid" then
        instance.Health = 100
        instance.MaxHealth = 100
        instance.WalkSpeed = 16
        instance.JumpPower = 50
        instance.JumpHeight = 7.2
    end

    -- GUI 속성
    if className == "TextLabel" or className == "TextButton" then
        instance.Text = ""
        instance.TextColor3 = Color3.new(0, 0, 0)
        instance.BackgroundColor3 = Color3.new(1, 1, 1)
        instance.Size = UDim2.new(0, 200, 0, 50)
        instance.Position = UDim2.new(0, 0, 0, 0)
    end

    if parent then
        table.insert(parent._children, instance)
    end

    return instance
end

Instance = {
    new = function(className, parent)
        return createInstance(className, parent)
    end
}

-- 가상 game 객체
local workspace = createInstance("Workspace", nil)
workspace.Name = "Workspace"

local players = createInstance("Players", nil)
players.Name = "Players"
players.LocalPlayer = createInstance("Player", nil)
players.LocalPlayer.Name = "Player1"
players.LocalPlayer.Character = createInstance("Model", nil)
local humanoid = createInstance("Humanoid", players.LocalPlayer.Character)

local replicatedStorage = createInstance("ReplicatedStorage", nil)
replicatedStorage.Name = "ReplicatedStorage"

game = {
    Workspace = workspace,
    Players = players,
    ReplicatedStorage = replicatedStorage,

    GetService = function(self, serviceName)
        if serviceName == "Workspace" then return workspace
        elseif serviceName == "Players" then return players
        elseif serviceName == "ReplicatedStorage" then return replicatedStorage
        else return createInstance(serviceName, nil)
        end
    end
}

-- script 객체
script = createInstance("Script", nil)
script.Name = "Script"
script.Parent = workspace

-- 전역으로 노출
_G.game = game
_G.workspace = workspace
_G.script = script
_G.Instance = Instance
_G.Vector3 = Vector3
_G.CFrame = CFrame
_G.Color3 = Color3
_G.BrickColor = BrickColor
_G.UDim2 = UDim2
_G.wait = wait
_G.task = task
_G.warn = warn

-- 출력 결과 반환 함수
function _getOutputs()
    return _outputs
end

function _clearOutputs()
    _outputs = {}
end
`;

export interface LuaOutput {
    type: 'log' | 'warn' | 'error';
    message: string;
}

export interface LuaExecutionResult {
    success: boolean;
    outputs: LuaOutput[];
    error?: string;
    returnValue?: unknown;
}

let luaFactory: LuaFactory | null = null;
let luaEngine: LuaEngine | null = null;
let isInitialized = false;

/**
 * Lua 엔진 초기화
 */
export async function initLuaEngine(): Promise<void> {
    if (isInitialized) return;

    try {
        luaFactory = new LuaFactory();
        luaEngine = await luaFactory.createEngine();

        // Roblox 모킹 코드 실행
        await luaEngine.doString(ROBLOX_MOCK);

        isInitialized = true;
        console.log('[LuaRuntime] 엔진 초기화 완료');
    } catch (err) {
        console.error('[LuaRuntime] 초기화 실패:', err);
        throw err;
    }
}

/**
 * Lua 코드 실행
 */
export async function executeLua(code: string): Promise<LuaExecutionResult> {
    if (!isInitialized || !luaEngine) {
        await initLuaEngine();
    }

    const outputs: LuaOutput[] = [];

    try {
        // 출력 초기화
        await luaEngine!.doString('_clearOutputs()');

        // 사용자 코드 실행
        const result = await luaEngine!.doString(code);

        // 출력 결과 가져오기
        const getOutputs = luaEngine!.global.get('_getOutputs') as () => Array<{type: string; message: string}>;
        const rawOutputs = getOutputs();

        if (rawOutputs && Array.isArray(rawOutputs)) {
            for (const out of rawOutputs) {
                outputs.push({
                    type: out.type as LuaOutput['type'],
                    message: out.message
                });
            }
        }

        return {
            success: true,
            outputs,
            returnValue: result
        };
    } catch (err) {
        const errorMessage = err instanceof Error ? err.message : String(err);

        return {
            success: false,
            outputs,
            error: errorMessage
        };
    }
}

/**
 * 엔진 리셋 (새로운 상태로)
 */
export async function resetEngine(): Promise<void> {
    if (luaEngine) {
        luaEngine.global.close();
    }
    isInitialized = false;
    luaEngine = null;
    await initLuaEngine();
}

/**
 * 엔진 종료
 */
export function closeLuaEngine(): void {
    if (luaEngine) {
        luaEngine.global.close();
        luaEngine = null;
    }
    isInitialized = false;
}
