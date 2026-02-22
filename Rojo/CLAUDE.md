# Rojo 프로젝트 CLAUDE.md

## 개요

Roblox Studio와 파일시스템 간 실시간 동기화를 위한 Rojo 프로젝트.
수업 차시별 예제 파트/스크립트를 Rojo로 관리하여 Studio에 동기화한다.

## ⚠️ 핵심 안전 규칙 (데이터 삭제 방지)

**Rojo는 project.json에 정의되지 않은 Workspace 자식을 삭제한다!**

### 절대 하면 안 되는 것

```json
// ❌ 위험! Workspace 전체를 관리하면 기존 데이터 삭제됨
{
  "Workspace": {
    "$path": "src/workspace"
  }
}

// ❌ 위험! Workspace에 SpawnLocation/Baseplate 등을 정의하면
//    정의 안 된 기존 자식(수업자료 등)이 삭제됨
{
  "Workspace": {
    "SpawnLocation": { ... },
    "Baseplate": { ... },
    "수업자료": { "$path": "..." }
  }
}
```

### 반드시 이렇게 해야 하는 것

```json
// ✅ 안전! 특정 하위 경로만 관리 → 나머지 Studio 데이터에 영향 없음
{
  "Workspace": {
    "수업자료": {
      "$className": "Folder",
      "9주차": {
        "$path": "src/workspace/수업자료/9주차"
      }
    }
  }
}
```

**원칙**: Workspace 아래에는 관리할 특정 폴더 경로만 정의한다.
SpawnLocation, Baseplate, Lighting, Camera 등은 절대 정의하지 않는다.

## 새 차시 작업 세팅 방법

### 1. 디렉토리 생성

```
Rojo/src/workspace/수업자료/{N주차}/
├── 파트이름/
│   ├── init.meta.json      # Part 클래스 + 속성
│   ├── Script.server.luau   # 서버 스크립트
│   └── CoinGui.model.json   # BillboardGui 등 (선택)
```

### 2. default.project.json 수정

기존 차시는 유지하고, 새 차시만 추가:

```json
{
  "name": "WeekN_프로젝트명",
  "tree": {
    "$className": "DataModel",
    "ServerScriptService": {
      "필요한스크립트": {
        "$path": "src/server"
      }
    },
    "Workspace": {
      "수업자료": {
        "$className": "Folder",
        "8주차": {
          "$path": "src/workspace/수업자료/8주차"
        },
        "9주차": {
          "$path": "src/workspace/수업자료/9주차"
        }
      }
    }
  }
}
```

### 3. Rojo 서버 시작

```bash
# 반드시 상위 폴더에서 실행! (aftman.toml이 있는 곳)
cd "c:/workspace/_26_로블록스_과외"
rojo serve Rojo/default.project.json
```

aftman.toml이 상위 폴더에 있으므로, 상위 폴더에서 실행해야 올바른 Rojo 버전(7.6.1)이 사용된다.

### 4. .rbxm 모델 빌드 (선택)

```bash
cd "c:/workspace/_26_로블록스_과외"
rojo build Rojo/build-{N주차}.project.json -o Rojo/{N주차}.rbxm
```

## 파일 형식 가이드

### init.meta.json (Part 정의)

```json
{
  "className": "Part",
  "properties": {
    "Anchored": true,
    "Size": [가로, 세로, 깊이],
    "Position": [x, y, z],
    "Color": [r, g, b],
    "Material": "Neon"
  }
}
```

- 소문자 `className`, `properties` 사용
- Color는 0~1 범위 float
- Material: "SmoothPlastic", "Neon", "Foil" 등

### .model.json (GUI/복합 객체)

```json
{
  "ClassName": "BillboardGui",
  "Properties": {
    "Size": { "UDim2": [[0, 80], [0, 40]] },
    "StudsOffset": { "Vector3": [0, 3, 0] },
    "AlwaysOnTop": true
  },
  "Children": [
    {
      "Name": "Label",
      "ClassName": "TextLabel",
      "Properties": {
        "Size": { "UDim2": [[1, 0], [1, 0]] },
        "Text": "+5 GOLD",
        "TextScaled": true,
        "TextColor3": { "Color3": [1, 0.85, 0.2] },
        "Font": "GothamBold",
        "BackgroundTransparency": 1
      }
    }
  ]
}
```

- PascalCase: `ClassName`, `Properties`, `Children`, `Name`
- 복합 타입은 명시적 래퍼 필수: `{ "UDim2": [...] }`, `{ "Color3": [...] }`, `{ "Vector3": [...] }`, `{ "UDim": [...] }`
- Enum은 문자열: `"Face": "Top"`, `"Font": "GothamBold"`

### 이모지 주의

Roblox TextLabel에서 최신 유니코드 이모지가 깨진다:
- ❌ 깨짐 (Unicode 9.0+): 🪙 🥈 🥉 → 텍스트로 대체 (GOLD, SILVER 등)
- ✅ 작동 (Unicode 6.0 이하): 💰 ⚠️ 🔒 🔓 💫 🔊 🔄 ⭐ ❤️

## 버전 정보

- Rojo: 7.6.1 (aftman 관리, protocol 4)
- Studio 플러그인: 7.6.1 (버전 일치 필수!)
- aftman.toml 위치: `c:/workspace/_26_로블록스_과외/aftman.toml`

## 기존 차시 구조 (8주차)

```
src/workspace/수업자료/8주차/
├── BasicCoin/          # 기본 코인 (+1, debounce 없음)
├── DebounceCoin/       # debounce 패턴 코인 (+1)
├── Gold/               # 금 코인 (+5, getScore 함수)
├── Silver/             # 은 코인 (+3)
├── Bronze/             # 동 코인 (+1)
├── SpinCoin/           # 회전 코인 (while + CFrame)
├── SoundCoin/          # 효과음 코인 (Instance.new Sound)
├── RespawnCoin/        # 재생성 코인 (Transparency 숨기기)
├── CoinGivePart/       # +10 코인 지급 발판 (SurfaceGui)
├── CoinRemovePart/     # -5 코인 함정 발판 (SurfaceGui)
└── CoinDoor/           # 슬라이딩 도어 (TweenService, SurfaceGui 양면)

src/server/
└── init.server.luau    # Leaderstats 시스템 (Coins, Level)
```
