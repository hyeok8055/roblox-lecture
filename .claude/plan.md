# 로블록스 과외 프로젝트 리팩토링 계획

## 진행 상황

| 단계 | 상태 | 완료일 |
|------|------|--------|
| 1. 프로젝트 초기화 | ✅ 완료 | 2026-02-02 |
| 2. Lit 컴포넌트 | ✅ 완료 | 2026-02-02 |
| 3. Astro 레이아웃 | ✅ 완료 | 2026-02-02 |
| 4. Lua 런타임 | ✅ 완료 | 2026-02-02 |
| 5. 콘텐츠 재작성 | 🔄 진행중 | - |
| 6. 테스트 | ⏳ 대기 | - |

## 개요

**목표**: Astro + Vite + TypeScript + Lit 기반으로 완전 재작성하여 컴포넌트화 및 빠른 개발 환경 구축

**기술 스택**:
- **Astro**: 정적 사이트 생성, 레이아웃/페이지 관리
- **Vite**: 빠른 HMR, 빌드
- **TypeScript**: 타입 안전성
- **Lit**: 인터랙티브 웹 컴포넌트 (코드 에디터, 퀴즈)
- **Playwright**: E2E 테스트

---

## 1단계: 프로젝트 초기화 (1일)

### 1.1 Astro 프로젝트 생성
```bash
npm create astro@latest roblox-tutor -- --template minimal --typescript strict
cd roblox-tutor
npm install lit @playwright/test
```

### 1.2 폴더 구조 생성
```
roblox-tutor/
├── src/
│   ├── components/
│   │   ├── lit/                  # Lit 웹 컴포넌트
│   │   │   ├── LuaCodeBlock.ts   # 읽기 전용 코드 블록
│   │   │   ├── LuaEditor.ts      # 실행 가능한 코드 에디터
│   │   │   ├── QuizQuestion.ts   # 퀴즈 컴포넌트
│   │   │   └── index.ts          # 컴포넌트 등록
│   │   │
│   │   └── astro/                # Astro 컴포넌트
│   │       ├── Navigation.astro
│   │       ├── SlideProgress.astro
│   │       ├── HintBox.astro
│   │       └── Badge.astro
│   │
│   ├── layouts/
│   │   ├── BaseLayout.astro      # HTML 기본 구조
│   │   ├── LessonLayout.astro    # 레슨 페이지 래퍼
│   │   └── SlideLayout.astro     # 슬라이드 컨테이너
│   │
│   ├── pages/
│   │   ├── index.astro           # 메인 (12주 커리큘럼)
│   │   └── lessons/
│   │       ├── 01.astro          # 1차시
│   │       ├── 02/
│   │       │   ├── index.astro   # 2차시 목차
│   │       │   └── [part].astro  # 동적 파트 라우팅
│   │       └── ...
│   │
│   ├── content/
│   │   └── lessons/              # MDX 콘텐츠
│   │       ├── config.ts
│   │       └── 02/
│   │           ├── part1.mdx
│   │           └── ...
│   │
│   ├── styles/
│   │   ├── design-system.css     # 기존 CSS 포팅
│   │   ├── components.css
│   │   ├── code-blocks.css
│   │   └── global.css
│   │
│   └── lib/
│       ├── lua-runtime.ts        # Wasmoon 래퍼
│       └── roblox-mock.ts        # Roblox API 모킹
│
├── tests/
│   ├── navigation.spec.ts
│   ├── quiz.spec.ts
│   └── lua-editor.spec.ts
│
├── astro.config.mjs
├── playwright.config.ts
└── tsconfig.json
```

### 1.3 기존 CSS 포팅
- `assets/css/*.css` → `src/styles/` 복사
- CSS 변수 그대로 유지

---

## 2단계: 핵심 Lit 컴포넌트 구현 (3일)

### 2.1 `<lua-code-block>` - 읽기 전용 코드 표시

**파일**: `src/components/lit/LuaCodeBlock.ts`

```typescript
// 사용 예시
<lua-code-block title="example.lua" show-line-numbers>
local part = script.Parent
part.BrickColor = BrickColor.new("Bright red")
</lua-code-block>
```

**기능**:
- 자동 Lua 구문 강조 (정규식 기반)
- 터미널 스타일 헤더 (빨강/노랑/초록 버튼)
- 라인 넘버 옵션
- 복사 버튼

### 2.2 `<lua-editor>` - 실행 가능한 코드 에디터

**파일**: `src/components/lit/LuaEditor.ts`

```typescript
// 사용 예시
<lua-editor
  mission="print 함수로 'Hello'를 출력하세요"
  initial-code="-- 코드를 입력하세요"
  hints='["print() 함수 사용", "문자열은 따옴표로"]'
></lua-editor>
```

**기능**:
- 좌측: 미션/힌트 패널
- 우측: 코드 에디터 + 출력
- 리사이즈 가능
- 실행/초기화 버튼
- Wasmoon 연동

### 2.3 `<quiz-question>` - 퀴즈 컴포넌트

**파일**: `src/components/lit/QuizQuestion.ts`

```typescript
// 사용 예시
<quiz-question
  question="print()의 역할은?"
  correct="B"
  correct-explanation="print()는 콘솔에 출력합니다"
  wrong-explanation="다시 생각해보세요"
>
  <quiz-option value="A">화면에 그림 그리기</quiz-option>
  <quiz-option value="B">콘솔에 출력</quiz-option>
  <quiz-option value="C">변수 생성</quiz-option>
  <quiz-option value="D">아무것도 안함</quiz-option>
</quiz-question>
```

**기능**:
- 4지선다 (slot 기반)
- 정답/오답 애니메이션
- 설명 표시
- 재시도 옵션

---

## 3단계: Astro 레이아웃/컴포넌트 (2일)

### 3.1 BaseLayout.astro
- HTML 보일러플레이트
- 폰트 로드 (Pretendard, Space Grotesk, JetBrains Mono)
- TailwindCSS CDN
- Lit 컴포넌트 등록

### 3.2 LessonLayout.astro
- 네비게이션 바
- 진행률 표시
- 전체화면 버튼
- 이전/다음 버튼

### 3.3 SlideLayout.astro
- 슬라이드 컨테이너
- 키보드/스와이프 네비게이션
- 슬라이드 전환 애니메이션

### 3.4 재사용 컴포넌트
- `HintBox.astro`: 힌트/팁 박스
- `Badge.astro`: 뱃지 (lesson, quiz, lua, roblox)
- `Navigation.astro`: 네비게이션 바

---

## 4단계: Lua 런타임 포팅 (1일)

### 4.1 lua-runtime.ts
- 기존 `lua-runner.js` TypeScript로 변환
- Wasmoon 1.16.0 래핑
- 단계별 실행 기능 유지

### 4.2 roblox-mock.ts
- 기존 `roblox-mock.js` TypeScript로 변환
- BrickColor, Color3, Vector3, CFrame 클래스
- game, workspace, script 전역 객체

---

## 5단계: 콘텐츠 재작성 (5-7일)

### 5.1 메인 페이지 (index.astro)
- 12주 커리큘럼 카드 그리드
- 활성/잠금 상태 표시

### 5.2 1차시 재작성
- 기존 5개 슬라이드 → Astro 페이지
- 인라인 CSS/JS 제거
- 컴포넌트 활용

### 5.3 2차시 재작성
- 6개 파트 → MDX 콘텐츠
- 코드 블록 → `<lua-code-block>`
- 코드 에디터 → `<lua-editor>`
- 퀴즈 → `<quiz-question>`

### 5.4 3-12차시 신규 작성
- MDX 템플릿 활용
- 빠른 콘텐츠 생산

---

## 6단계: Playwright 테스트 (1일)

### 6.1 테스트 설정
```typescript
// playwright.config.ts
export default defineConfig({
  testDir: './tests',
  webServer: {
    command: 'npm run dev',
    port: 4321,
  },
});
```

### 6.2 테스트 케이스
1. **네비게이션**: 슬라이드 이동, 키보드, 스와이프
2. **퀴즈**: 정답/오답 피드백, 상태 유지
3. **코드 에디터**: 코드 실행, 출력 확인
4. **반응형**: 모바일/데스크톱 레이아웃

---

## 핵심 파일 목록

| 파일 | 설명 |
|------|------|
| `src/components/lit/LuaCodeBlock.ts` | 코드 표시 컴포넌트 |
| `src/components/lit/LuaEditor.ts` | 코드 에디터 컴포넌트 |
| `src/components/lit/QuizQuestion.ts` | 퀴즈 컴포넌트 |
| `src/layouts/LessonLayout.astro` | 레슨 레이아웃 |
| `src/lib/lua-runtime.ts` | Wasmoon 래퍼 |
| `src/lib/roblox-mock.ts` | Roblox API 모킹 |
| `src/styles/design-system.css` | CSS 변수/기본 스타일 |

---

## 검증 방법

1. **개발 서버 실행**
   ```bash
   npm run dev
   ```

2. **Playwright 테스트**
   ```bash
   npx playwright test
   ```

3. **빌드 확인**
   ```bash
   npm run build
   npm run preview
   ```

4. **수동 테스트**
   - 슬라이드 네비게이션 (키보드, 클릭, 스와이프)
   - 코드 실행 및 출력 확인
   - 퀴즈 정답/오답 확인
   - 전체화면 토글

---

## 예상 일정

| 단계 | 기간 | 산출물 |
|------|------|--------|
| 1. 프로젝트 초기화 | 1일 | 빈 Astro 프로젝트 |
| 2. Lit 컴포넌트 | 3일 | 3개 핵심 컴포넌트 |
| 3. Astro 레이아웃 | 2일 | 레이아웃, 공통 컴포넌트 |
| 4. Lua 런타임 | 1일 | TypeScript 포팅 완료 |
| 5. 콘텐츠 재작성 | 5-7일 | 1-2차시 + 템플릿 |
| 6. 테스트 | 1일 | Playwright 테스트 |
| **총합** | **13-15일** | 완전히 새로운 시스템 |
