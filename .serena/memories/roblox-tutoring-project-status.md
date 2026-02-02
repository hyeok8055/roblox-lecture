# 로블록스 과외 프로젝트 작업 현황

## 프로젝트 정보
- **GitHub**: https://github.com/hyeok8055/roblox-lecture
- **배포 URL**: https://hyeok-lecture.netlify.app
- **로컬 경로**: `C:\workspace\roblox-lecture`
- **배포 방법**: Git push → Netlify 자동 배포

---

## 기술 스택

| 기술 | 용도 |
|------|------|
| Astro 5 | 정적 사이트 생성 |
| Lit 3 | Web Components (LuaEditor, LuaCodeBlock, QuizQuestion) |
| TailwindCSS | 유틸리티 CSS |
| Wasmoon | 브라우저 Lua 인터프리터 |
| TypeScript | 타입 안전성 |

---

## 현재 파일 구조 (2026-02-02 업데이트)

```
/
├── src/
│   ├── pages/
│   │   ├── index.astro          # 메인 페이지 (커리큘럼 목록)
│   │   └── lessons/
│   │       ├── week01/
│   │       │   ├── a.astro      # 1A: 스튜디오 적응
│   │       │   └── b.astro      # 1B: 첫 스크립트
│   │       ├── week02/
│   │       │   ├── a.astro      # 2A: 변수 기초
│   │       │   └── b.astro      # 2B: 파트 속성 변경
│   │       ├── week03/
│   │       │   ├── a.astro      # 3A: 함수 기초
│   │       │   └── b.astro      # 3B: 이벤트 (Touched)
│   │       ├── week04/
│   │       │   ├── a.astro      # 4A: 조건문 기초
│   │       │   └── b.astro      # 4B: 조건문 활용
│   │       └── week05/
│   │           ├── a.astro      # 5A: 반복문 (for)
│   │           └── b.astro      # 5B: 반복문 (while)
│   │
│   ├── layouts/
│   │   ├── BaseLayout.astro
│   │   └── LessonLayout.astro
│   │
│   ├── components/
│   │   ├── astro/
│   │   │   ├── HintBox.astro
│   │   │   ├── Badge.astro
│   │   │   └── StepCard.astro
│   │   │
│   │   └── lit/
│   │       ├── index.ts
│   │       ├── LuaCodeBlock.ts
│   │       ├── LuaEditor.ts
│   │       └── QuizQuestion.ts
│   │
│   ├── styles/
│   │   └── global.css
│   │
│   └── lib/
│       └── lua-runtime.ts
│
├── public/
├── astro.config.mjs
├── tailwind.config.mjs
├── netlify.toml
└── CLAUDE.md
```

---

## 24차시 커리큘럼 진행 상황 (2026-02-02 업데이트)

### Phase 1 완료 - 1~5주차 (10개 차시)

| 차시 | 제목 | 슬라이드 | 경로 |
|------|------|---------|------|
| 1A | 스튜디오 적응 | 9개 | /lessons/week01/a |
| 1B | 첫 스크립트 | 10개 | /lessons/week01/b |
| 2A | 변수 기초 | 9개 | /lessons/week02/a |
| 2B | 파트 속성 변경 | 10개 | /lessons/week02/b |
| 3A | 함수 기초 | 9개 | /lessons/week03/a |
| 3B | 이벤트 (Touched) | 10개 | /lessons/week03/b |
| 4A | 조건문 기초 | 10개 | /lessons/week04/a |
| 4B | 조건문 활용 | 10개 | /lessons/week04/b |
| 5A | 반복문 (for) | 9개 | /lessons/week05/a |
| 5B | 반복문 (while) | 10개 | /lessons/week05/b |

### Phase 2 미완료 - 6~12주차 (14개 차시)

| 주차 | A차시 | B차시 |
|------|-------|-------|
| 6 | Humanoid | 스피드/점프 패드 |
| 7 | GUI 기초 | 시작 화면 |
| 8 | Leaderstats | 점수 시스템 |
| 9 | Client vs Server | RemoteEvent |
| 10 | 맵 제작 | 장애물 맵 |
| 11 | 게임 로직 | 아이템 상점 |
| 12 | 테스트 | 출시 |

### 각 차시 포함 내용
- 빈칸 채우기 실습 (`___` 플레이스홀더)
- 스튜디오 가이드 (단계별 안내)
- 로블록스 예제 3~5개
- 퀴즈 2~3문제

---

## 개발 명령어

```bash
npm install      # 의존성 설치
npm run dev      # 개발 서버 (localhost:4321)
npm run build    # 프로덕션 빌드
npm run preview  # 빌드 미리보기
```

---

## 배포

```bash
git add -A
git commit -m "메시지"
git push
# → Netlify 자동 배포
```

---

## 새 차시 만들기

1. `src/pages/lessons/weekXX/a.astro` 또는 `b.astro` 생성
2. `LessonLayout` import (경로: `../../../layouts/LessonLayout.astro`)
3. hints는 frontmatter에서 `JSON.stringify()` 사용
4. Lit 컴포넌트 사용 (`<lua-editor>`, `<quiz-question>`)
5. `index.astro`에서 해당 차시 `active: true` 설정

CLAUDE.md 참고.
