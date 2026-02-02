# Arcade Classroom 디자인 시스템

로블록스 과외 커리큘럼 슬라이드 제작용 디자인 가이드.

> **레퍼런스**: `_design_sample.html` 파일의 `<style>` 태그를 그대로 복사해서 사용.

---

## 핵심 컨셉

**고급 게임 UI의 정교함 + 교실 칠판의 친근함**

---

## 금지 사항 (AI 클리셰 회피)

| 금지 | 대안 |
|------|------|
| Inter, Roboto, system-ui | **Pretendard** + **Space Grotesk** + **JetBrains Mono** |
| 보라색 그라데이션 | 단색 기반 + 네온 포인트 |
| `rounded-lg` 카드 그리드 | 비대칭 배치, 겹침, 오프셋 |
| 파란 버튼 + 흰 배경 | 3D 깊이감 버튼 |
| `shadow-lg` | 다층 그림자 시스템 |

---

## HTML 템플릿 (head에 포함)

```html
<script src="https://cdn.tailwindcss.com"></script>
<link href="https://cdn.jsdelivr.net/gh/orioncactus/pretendard@v1.3.9/dist/web/static/pretendard.css" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@500;700&display=swap" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;600&display=swap" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@24,400,1,0" rel="stylesheet">
```

---

## CSS 변수

```css
:root {
    /* 베이스: 잉크 톤 */
    --ink-deep: #1a1625;
    --ink-medium: #2d2640;
    --ink-light: #3d3654;
    --ink-pale: #f8f6f4;
    --ink-cream: #fdfcfb;

    /* 액션: 네온 포인트 */
    --neon-mint: #3DFFA2;      /* 실행/성공 */
    --neon-coral: #FF6B6B;     /* 정지/오류 */
    --neon-gold: #FFD93D;      /* 강조/경고 */
    --neon-sky: #6BCFFF;       /* 정보/링크 */

    /* 로블록스 브랜드 */
    --roblox-red: #E2231A;
    --roblox-charcoal: #393B3D;

    /* Lua 구문 강조 */
    --lua-keyword: #C792EA;    /* local, function, if, then, end */
    --lua-builtin: #82AAFF;    /* print, wait, require */
    --lua-roblox: #89DDFF;     /* script, game, workspace */
    --lua-string: #C3E88D;     /* "문자열" */
    --lua-number: #F78C6C;     /* 123 */
    --lua-comment: #676E95;    /* -- 주석 */
    --lua-function: #FFCB6B;   /* 함수명 */
    --lua-property: #F07178;   /* .Parent */

    /* 폰트 */
    --font-display: 'Space Grotesk', sans-serif;
    --font-body: 'Pretendard', sans-serif;
    --font-code: 'JetBrains Mono', monospace;

    /* 타이포 스케일 */
    --text-hero: clamp(2.5rem, 5vw, 4rem);
    --text-title: clamp(1.5rem, 3vw, 2rem);
    --text-subtitle: 1.25rem;
    --text-body: 1rem;
    --text-caption: 0.875rem;
    --text-code: 0.9rem;

    /* 그림자 */
    --shadow-subtle: 0 1px 2px rgba(26,22,37,0.04), 0 2px 4px rgba(26,22,37,0.04);
    --shadow-card: 0 2px 4px rgba(26,22,37,0.04), 0 4px 8px rgba(26,22,37,0.06), 0 8px 16px rgba(26,22,37,0.06);
    --shadow-elevated: 0 4px 8px rgba(26,22,37,0.06), 0 8px 16px rgba(26,22,37,0.08), 0 16px 32px rgba(26,22,37,0.08);

    /* 전환 */
    --ease-out-expo: cubic-bezier(0.16, 1, 0.3, 1);
    --ease-out-back: cubic-bezier(0.34, 1.56, 0.64, 1);
    --duration-fast: 150ms;
    --duration-normal: 250ms;
    --duration-slow: 400ms;
}
```

---

## 핵심 컴포넌트

### 코드 블록 (터미널 스타일)
```css
.code-block {
    background: var(--ink-deep);
    color: #E8E6E3;
    font-family: var(--font-code);
    line-height: 1.7;
    border-radius: 16px;
    padding: 48px 24px 24px;
    position: relative;
}
.code-block::before {
    content: '';
    position: absolute;
    top: 16px; left: 20px;
    width: 12px; height: 12px;
    background: #FF6B6B;
    border-radius: 50%;
    box-shadow: 20px 0 0 #FFD93D, 40px 0 0 #3DFFA2;
}
```

### Lua 구문 강조
```css
.lua-keyword { color: var(--lua-keyword); }
.lua-builtin { color: var(--lua-builtin); }
.lua-roblox { color: var(--lua-roblox); }
.lua-string { color: var(--lua-string); }
.lua-number { color: var(--lua-number); }
.lua-comment { color: var(--lua-comment); font-style: italic; }
.lua-function { color: var(--lua-function); }
.lua-property { color: var(--lua-property); }
```

### 실행 버튼 (3D)
```css
.btn-run {
    background: linear-gradient(180deg, var(--neon-mint) 0%, #2DD88A 100%);
    box-shadow: 0 6px 0 #1FA86A, 0 6px 20px rgba(61,255,162,0.35);
    border-radius: 14px;
}
.btn-run:hover { transform: translateY(-3px); }
.btn-run:active { transform: translateY(4px); }
```

### 정지 버튼
```css
.btn-stop {
    background: linear-gradient(180deg, var(--neon-coral) 0%, #E85555 100%);
    box-shadow: 0 6px 0 #C44444;
}
```

### 퀴즈 옵션
```css
.quiz-option {
    border: 2px solid var(--ink-pale);
    border-radius: 16px;
}
.quiz-option::before { /* 왼쪽 4px 바, hover시 6px + neon-sky */ }
.quiz-option.correct { border-color: var(--neon-mint); }
.quiz-option.wrong { border-color: var(--neon-coral); animation: shake; }
```

### 힌트 박스 (금색)
```css
.hint-box {
    background: linear-gradient(135deg, #FFFBEB 0%, #FEF3C7 100%);
    border-left: 4px solid var(--neon-gold);
    border-radius: 0 16px 16px 0;
}
```

### Lua 팁 박스 (보라색)
```css
.info-box {
    background: linear-gradient(135deg, #EDE9FE 0%, #DDD6FE 100%);
    border-left: 4px solid var(--lua-keyword);
    border-radius: 0 16px 16px 0;
}
```

### 레슨 카드
```css
.lesson-card {
    background: white;
    border-radius: 20px;
    padding: 28px;
    box-shadow: var(--shadow-card);
}
.lesson-card:hover {
    transform: translateY(-4px) rotate(0.3deg);
}
```

### 뱃지
```css
.badge-lesson { background: var(--ink-deep); color: white; }
.badge-quiz { background: var(--neon-gold); color: var(--ink-deep); }
.badge-lua { background: linear-gradient(135deg, #1e3a5f 0%, #2d5a87 100%); color: white; }
.badge-roblox { background: var(--roblox-red); color: white; }
```

---

## 애니메이션

```css
/* 등장 - .animate-in 클래스 사용 */
@keyframes slideUp {
    from { opacity: 0; transform: translateY(24px); }
    to { opacity: 1; transform: translateY(0); }
}
.slide.active .animate-in {
    animation: slideUp 0.5s var(--ease-out-expo) backwards;
}
/* nth-child로 100ms씩 딜레이 */

/* 코드 실행 하이라이트 */
.code-line.executing {
    background: rgba(61,255,162,0.15);
    border-left: 3px solid var(--neon-mint);
}

/* 코드 블록 실행 중 */
.code-block.running {
    animation: pulse-glow 1.5s ease-in-out infinite;
}
```

---

## 레이아웃 원칙

| 요소 | 값 |
|------|-----|
| 슬라이드 패딩 | `48px` |
| 카드 border-radius | `20px` (레슨), `16px` (코드/퀴즈) |
| 버튼 border-radius | `14px` |

---

## 색상 사용 규칙

| 용도 | 색상 |
|------|------|
| 배경 | `--ink-cream` |
| 텍스트 | `--ink-deep` |
| 실행/성공 | `--neon-mint` |
| 정지/오류 | `--neon-coral` |
| 힌트/강조 | `--neon-gold` |
| 정보/링크 | `--neon-sky` |

**슬라이드당 네온 색상 1-2개만 사용.**
