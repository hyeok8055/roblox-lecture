# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 프로젝트 개요

**로블록스 과외 커리큘럼** - 로블록스 스튜디오와 Lua 스크립팅을 가르치는 교육 프로젝트. Astro + Lit + Wasmoon 기반의 인터랙티브 슬라이드 형식.

## 프로젝트 구조

```
/_26_로블록스_과외/
├── .gitignore
├── _design_sample.html         # 디자인 시스템 레퍼런스
├── CLAUDE.md
│
└── roblox-tutor/               # Astro 프로젝트
    ├── src/
    │   ├── pages/
    │   │   ├── index.astro     # 메인 페이지 (커리큘럼 목록)
    │   │   └── lessons/
    │   │       ├── 01.astro    # 1차시: 스튜디오 적응
    │   │       ├── 02.astro    # 2차시: 변수와 속성
    │   │       ├── 03.astro    # 3차시: 함수와 이벤트
    │   │       ├── 04.astro    # 4차시: 조건문
    │   │       └── 05.astro    # 5차시: 반복문
    │   │
    │   ├── layouts/
    │   │   ├── BaseLayout.astro    # 기본 HTML 레이아웃
    │   │   └── LessonLayout.astro  # 레슨 공통 레이아웃 (네비게이션)
    │   │
    │   ├── components/
    │   │   ├── astro/              # Astro 컴포넌트
    │   │   │   ├── HintBox.astro
    │   │   │   ├── Badge.astro
    │   │   │   └── StepCard.astro
    │   │   │
    │   │   └── lit/                # Lit Web Components
    │   │       ├── index.ts        # 컴포넌트 등록
    │   │       ├── LuaCodeBlock.ts # 코드 블록 (구문 강조)
    │   │       ├── LuaEditor.ts    # 코드 에디터 (실행 가능)
    │   │       └── QuizQuestion.ts # 퀴즈 컴포넌트
    │   │
    │   ├── styles/
    │   │   └── global.css          # 전역 스타일
    │   │
    │   └── lib/
    │       └── lua-runtime.ts      # Wasmoon Lua 인터프리터
    │
    ├── public/
    │   └── favicon.svg
    │
    ├── package.json
    ├── astro.config.mjs
    ├── tailwind.config.mjs
    └── tsconfig.json
```

## 기술 스택

- **Astro 5**: 정적 사이트 생성
- **Lit 3**: Web Components (LuaEditor, LuaCodeBlock, QuizQuestion)
- **TailwindCSS**: 유틸리티 CSS
- **Wasmoon**: 브라우저 Lua 인터프리터
- **TypeScript**: 타입 안전성
- **Pretendard + Space Grotesk + JetBrains Mono**: 폰트

## 개발 명령어

```bash
cd roblox-tutor
npm install      # 의존성 설치
npm run dev      # 개발 서버 (localhost:4321)
npm run build    # 프로덕션 빌드
npm run preview  # 빌드 미리보기
```

## 새 차시 만들기

### 1. 레슨 파일 생성

`src/pages/lessons/06.astro` 생성:

```astro
---
import LessonLayout from '../../layouts/LessonLayout.astro';
import HintBox from '../../components/astro/HintBox.astro';

const editorCode = `-- 초기 코드`;
const quizOptions = JSON.stringify(["A", "B", "C", "D"]);
---

<LessonLayout title="제목" lessonNumber={6} totalSlides={5}>
    <!-- 슬라이드 1: 인트로 -->
    <section class="slide active">
        <!-- 내용 -->
    </section>

    <!-- 슬라이드 2: 개념 -->
    <section class="slide">
        <!-- 내용 -->
    </section>

    <!-- 슬라이드 3: 실습 (전체화면) -->
    <section class="slide slide-fullscreen">
        <lua-editor
            mission="미션 설명"
            initial-code={editorCode}
            hints='["힌트1", "힌트2"]'
        ></lua-editor>
    </section>

    <!-- Lit 컴포넌트 로드 -->
    <script>
        import('../../components/lit/index').catch(console.error);
    </script>
</LessonLayout>
```

### 2. 인덱스 페이지 업데이트

`src/pages/index.astro`에 새 차시 카드 추가.

## Lit 컴포넌트 사용법

### LuaCodeBlock - 코드 표시용

```astro
<lua-code-block title="파일명.lua" show-line-numbers>
local part = script.Parent
print("Hello!")
</lua-code-block>
```

### LuaEditor - 코드 실습용

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

## CSS 클래스

### 레이아웃
- `.slide` - 슬라이드 컨테이너
- `.slide.active` - 현재 활성 슬라이드
- `.slide-fullscreen` - 전체화면 실습 슬라이드
- `.animate-in` - 등장 애니메이션

### 컴포넌트
- `.lesson-card` - 콘텐츠 카드
- `.hint-box` - 힌트 박스 (금색)
- `.info-box` - 정보 박스 (보라색)
- `.badge-*` - 뱃지 (lesson, quiz, lua, roblox)

### 주의사항
- 코드 블록은 **세로 배치** (`flex flex-col`) 사용 - 가로 스크롤 방지
- `<` 문자는 `&lt;`로 이스케이프 (Astro 템플릿 내)

## 디자인 시스템: "Arcade Classroom"

### 색상 변수

```css
/* 베이스 */
--ink-deep: #1a1625;
--ink-cream: #fdfcfb;

/* 네온 포인트 */
--neon-mint: #3DFFA2;   /* 실행/성공 */
--neon-coral: #FF6B6B;  /* 정지/오류 */
--neon-gold: #FFD93D;   /* 강조/경고 */
--neon-sky: #6BCFFF;    /* 정보/링크 */

/* Lua 구문 강조 */
--lua-keyword: #C792EA;
--lua-builtin: #82AAFF;
--lua-string: #C3E88D;
--lua-number: #F78C6C;
--lua-comment: #676E95;
```

## 12주 커리큘럼

### 1개월차: 기초 문법
| 차시 | 주제 | 상태 |
|------|------|------|
| 1 | 스튜디오 적응 | ✅ 완료 |
| 2 | 변수와 속성 | ✅ 완료 |
| 3 | 함수와 이벤트 | ✅ 완료 |
| 4 | 조건문 | ✅ 완료 |

### 2개월차: 게임 로직
| 차시 | 주제 | 상태 |
|------|------|------|
| 5 | 반복문 | ✅ 완료 |
| 6 | Humanoid | 🔲 미작성 |
| 7 | GUI | 🔲 미작성 |
| 8 | Leaderstats | 🔲 미작성 |

### 3개월차: 프로젝트
| 차시 | 주제 | 상태 |
|------|------|------|
| 9 | Client vs Server | 🔲 미작성 |
| 10 | 맵 제작 | 🔲 미작성 |
| 11 | 게임 로직 | 🔲 미작성 |
| 12 | 출시 | 🔲 미작성 |

## 배포

```bash
cd roblox-tutor
npm run build
# dist/ 폴더를 Netlify/Vercel에 배포
```
