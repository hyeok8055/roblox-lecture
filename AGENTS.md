# AGENTS.md

This file provides guidance to Codex when working with this repository.

## 프로젝트 개요

**로블록스 과외 커리큘럼** - 로블록스 스튜디오와 Lua 스크립팅을 가르치는 교육 프로젝트.
Astro + Lit + Wasmoon 기반의 인터랙티브 슬라이드 형식.

- **GitHub**: https://github.com/hyeok8055/roblox-lecture
- **배포**: https://hyeok-lecture.netlify.app/

## 프로젝트 구조

```
/
├── src/
│   ├── pages/
│   │   ├── index.astro          # 메인 페이지 (24차시 커리큘럼 목록)
│   │   └── lessons/
│   │       ├── week01/          # 1주차
│   │       │   ├── a.astro      # 스튜디오 적응
│   │       │   └── b.astro      # 첫 스크립트
│   │       ├── week02/          # 2주차
│   │       │   ├── a.astro      # 변수 기초
│   │       │   └── b.astro      # 파트 속성 변경
│   │       ├── week03/          # 3주차
│   │       │   ├── a.astro      # 함수 기초
│   │       │   └── b.astro      # 이벤트 (Touched)
│   │       ├── week04/          # 4주차
│   │       │   ├── a.astro      # 조건문 기초
│   │       │   └── b.astro      # 조건문 활용
│   │       ├── week05/          # 5주차
│   │       │   ├── a.astro      # for 반복문
│   │       │   └── b.astro      # while 반복문
│   │       └── week06-12/       # 미작성
│   │
│   ├── layouts/
│   │   ├── BaseLayout.astro     # 기본 HTML 레이아웃 (CSS import)
│   │   └── LessonLayout.astro   # 레슨 공통 레이아웃 (네비게이션)
│   │
│   ├── components/
│   │   ├── astro/               # Astro 컴포넌트
│   │   │   ├── HintBox.astro
│   │   │   ├── Badge.astro
│   │   │   └── StepCard.astro
│   │   │
│   │   └── lit/                 # Lit Web Components
│   │       ├── index.ts         # 컴포넌트 등록
│   │       ├── LuaCodeBlock.ts  # 코드 블록 (구문 강조)
│   │       ├── LuaEditor.ts     # 코드 에디터 (실행 가능)
│   │       └── QuizQuestion.ts  # 퀴즈 컴포넌트
│   │
│   ├── styles/
│   │   └── global.css           # 전역 스타일 (CSS 변수, 컴포넌트)
│   │
│   └── lib/
│       └── lua-runtime.ts       # Wasmoon Lua 인터프리터
│
├── public/
│   ├── favicon.ico
│   └── favicon.svg
│
├── package.json
├── astro.config.mjs
├── tailwind.config.mjs
├── tsconfig.json
├── netlify.toml                 # Netlify 배포 설정
├── AGENTS.md
├── _design_sample.html          # 디자인 시스템 레퍼런스
└── .gitignore
```

## 기술 스택

- **Astro 5**: 정적 사이트 생성
- **Lit 3**: Web Components (LuaEditor, LuaCodeBlock, QuizQuestion)
- **TailwindCSS**: 유틸리티 CSS
- **Wasmoon**: 브라우저 Lua 인터프리터
- **TypeScript**: 타입 안전성

## 개발 명령어

```bash
npm install      # 의존성 설치
npm run dev      # 개발 서버 (localhost:4321)
npm run build    # 프로덕션 빌드 (dist/)
npm run preview  # 빌드 미리보기
```

## ⚠️ 디버깅 규칙

**브라우저 테스트는 반드시 Playwright 사용!**
- `curl`, `wget` 등 CLI 도구로 브라우저 테스트 금지
- `mcp__plugin_playwright_playwright__*` 도구 적극 활용
- 페이지 렌더링, UI 확인, 인터랙션 테스트 모두 Playwright로

## 새 차시 만들기

### 1. 레슨 파일 생성

`src/pages/lessons/week06/a.astro` (6주차 A):

```astro
---
import LessonLayout from '../../../layouts/LessonLayout.astro';
import HintBox from '../../../components/astro/HintBox.astro';

const editorCode = `-- 초기 코드`;
const quizOptions = JSON.stringify(["A", "B", "C", "D"]);
---

<LessonLayout title="제목" lessonNumber={6} totalSlides={9}>
    <!-- 슬라이드 1: 인트로 -->
    <section class="slide active">
        <div class="max-w-4xl mx-auto px-6 py-12 flex flex-col items-center justify-center min-h-[80vh]">
            <div class="text-center animate-in">
                <span class="badge badge-roblox mb-6">6주차 A</span>
                <h1 class="title-display mb-4">
                    제목<br>
                    <span class="text-neon-mint">부제목</span>
                </h1>
                <!-- 인트로 내용 -->
            </div>
        </div>
    </section>

    <!-- 슬라이드 2: 개념 -->
    <section class="slide">
        <div class="max-w-4xl mx-auto px-6 py-12">
            <!-- 개념 설명 -->
        </div>
    </section>

    <!-- 슬라이드 3: 실습 (전체화면) -->
    <section class="slide slide-fullscreen">
        <lua-editor
            mission="미션 설명"
            initial-code={editorCode}
            hints='["힌트1", "힌트2"]'
        ></lua-editor>
    </section>

    <!-- 슬라이드 4: 퀴즈 -->
    <section class="slide">
        <quiz-question
            question="질문?"
            correct="B"
            options={quizOptions}
            correct-explanation="정답 설명"
            wrong-explanation="오답 설명"
        ></quiz-question>
    </section>

    <script>
        import('../../../components/lit/index').catch(console.error);
    </script>
</LessonLayout>
```

### 2. 인덱스 페이지 업데이트

`src/pages/index.astro`에서 해당 차시 `active: true`로 변경.

## 주요 컴포넌트

### LuaCodeBlock - 코드 표시

```astro
<lua-code-block title="파일명.lua" show-line-numbers>
local part = script.Parent
print("Hello!")
</lua-code-block>
```

### LuaEditor - 코드 실습

```astro
<lua-editor
    mission="미션 설명"
    initial-code={editorCode}
    hints='["힌트1", "힌트2"]'
></lua-editor>
```

### QuizQuestion - 퀴즈

```astro
<quiz-question
    question="질문?"
    correct="B"
    options={JSON.stringify(["A답", "B답", "C답", "D답"])}
    correct-explanation="정답 설명"
    wrong-explanation="오답 설명"
></quiz-question>
```

### HintBox - 힌트 박스

```astro
<HintBox type="info" title="제목">
    내용
</HintBox>
<!-- type: info, tip, warning -->
```

## CSS 주의사항

1. **CSS는 Astro import 방식 사용** (BaseLayout.astro 참고)
   ```astro
   ---
   import '../styles/global.css';
   ---
   ```
   `<link>` 태그로 `/styles/global.css` 참조하면 404 에러 발생

2. **코드 블록은 세로 배치** (`flex flex-col`) - 가로 스크롤 방지

3. **`<` 문자는 이스케이프** - Astro 템플릿 내에서 `&lt;` 사용

## 12주 24차시 커리큘럼 진행 상황

> 주 2회 × 12주 = 24차시 (각 주에 A/B 2개 레슨)

### 1개월차: 기초 문법 (1~4주)
| 주차 | A | B | 상태 |
|------|---|---|------|
| 1 | 스튜디오 적응 | 첫 스크립트 | ✅ 완료 |
| 2 | 변수 기초 | 파트 속성 변경 | ✅ 완료 |
| 3 | 함수 기초 | 이벤트 (Touched) | ✅ 완료 |
| 4 | 조건문 기초 | 조건문 활용 | ✅ 완료 |

### 2개월차: 게임 로직 (5~8주)
| 주차 | A | B | 상태 |
|------|---|---|------|
| 5 | for 반복문 | while 반복문 | ✅ 완료 |
| 6 | Humanoid | 스피드/점프 패드 | 🔲 미작성 |
| 7 | GUI 기초 | 시작 화면 | 🔲 미작성 |
| 8 | Leaderstats | 점수 시스템 | 🔲 미작성 |

### 3개월차: 프로젝트 (9~12주)
| 주차 | A | B | 상태 |
|------|---|---|------|
| 9 | Client vs Server | RemoteEvent | 🔲 미작성 |
| 10 | 맵 제작 | 장애물 맵 | 🔲 미작성 |
| 11 | 게임 로직 | 아이템 상점 | 🔲 미작성 |
| 12 | 테스트 | 출시 | 🔲 미작성 |

## 배포

GitHub에 push하면 Netlify가 자동 배포.

```bash
git add -A
git commit -m "메시지"
git push
```

## 디자인 시스템 요약

### 색상 변수 (global.css)
```css
--ink-deep: #1a1625;      /* 텍스트 */
--ink-cream: #fdfcfb;     /* 배경 */
--neon-mint: #3DFFA2;     /* 성공/실행 */
--neon-coral: #FF6B6B;    /* 오류/정지 */
--neon-gold: #FFD93D;     /* 경고/힌트 */
--neon-sky: #6BCFFF;      /* 정보/링크 */
--roblox-red: #E31B23;    /* 로블록스 브랜드 */
```

### 주요 CSS 클래스
- `.slide` / `.slide.active` - 슬라이드
- `.slide-fullscreen` - 전체화면 실습
- `.lesson-card` - 콘텐츠 카드
- `.badge-*` - 뱃지 (lesson, quiz, lua, roblox)
- `.hint-box` / `.info-box` - 박스
- `.animate-in` - 등장 애니메이션
