# 로블록스 과외 프로젝트 작업 현황

## 프로젝트 정보
- **배포 URL**: https://hyeok-lecture.netlify.app
- **로컬 경로**: `G:\내 드라이브\_26_로블록스_과외`
- **배포 방법**: Netlify CLI (`netlify deploy --prod --dir=.`)

---

## 현재 파일 구조

```
/_26_로블록스_과외/
├── index.html                 # 메인 페이지 (12주 커리큘럼 목록)
├── _design_sample.html        # 디자인 시스템 레퍼런스
├── CLAUDE.md                  # 프로젝트 가이드
│
├── assets/
│   ├── css/
│   │   ├── design-system.css  # CSS 변수, 타이포, 베이스
│   │   ├── components.css     # 버튼, 카드, 뱃지
│   │   ├── code-blocks.css    # 코드 블록 + Lua 구문 강조
│   │   ├── quiz.css           # 퀴즈 컴포넌트
│   │   └── navigation.css     # 네비게이션, 슬라이드 시스템
│   │
│   └── js/
│       ├── core/
│       │   ├── slide-navigation.js   # 슬라이드 시스템 (키보드/스와이프)
│       │   ├── quiz-engine.js        # 퀴즈 로직
│       │   └── fullscreen.js         # 전체화면 API
│       │
│       └── lua/
│           └── lua-runner.js         # Fengari 기반 Lua 실행기
│
├── templates/
│   └── lesson-template.html          # 새 차시용 보일러플레이트
│
├── 1차시/
│   └── Lesson01.html                 # 스튜디오 적응 (완료)
│
└── 2차시/
    └── Lesson02.html                 # Lua 기초와 인터랙티브 오브젝트 (완료)
```

---

## 완료된 차시

### 1차시: 스튜디오 적응
- Explorer/Properties 패널
- Anchored 속성
- 파트 조작 기초

### 2차시: Lua 기초와 인터랙티브 오브젝트 (총 30슬라이드)

**슬라이드 구성:**
| 슬라이드 | 주제 |
|----------|------|
| 1-3 | 타이틀, Lua 소개, print와 주석 |
| 4-8 | 변수, 자료형, 산술/비교/논리 연산자 |
| 9 | 퀴즈 1 |
| 10-14 | if 조건문, if-else, while, for(숫자), for(테이블) |
| 15 | 퀴즈 2 |
| 16 | script.Parent |
| **17-19** | **Roblox 레퍼런스 (game, Humanoid, Instance/Part)** |
| 20-21 | 속성 변경 실습, Touched 이벤트 |
| 22 | 퀴즈 3 |
| 23-24 | 킬존 만들기, 인터랙티브 책 |
| 25 | 퀴즈 4 |
| 26 | 요약 |
| 27-30 | 숙제 안내, 스피드 부스터, 힐존, 마무리 |

---

## 기술 스택

### Lua 인터프리터
- **Fengari** (Pure JavaScript Lua 5.3)
- CDN: `https://cdn.jsdelivr.net/npm/fengari-web@0.1.4/dist/fengari-web.js`
- file:// 프로토콜 호환 (Wasmoon은 CORS 문제로 사용 불가)

### 슬라이드 시스템
- `SlideNavigator` 클래스
- 키보드: 좌우 화살표, 스페이스바, F(전체화면)
- 터치: 스와이프 제스처
- **중요**: textarea/input 포커스 시 키보드 네비게이션 비활성화

### 코드 에디터
- `min-height: 320px` (실습 영역)
- `.code-snippet` 클래스: 작은 코드 블록용 (상단 점 없음)

---

## 최근 변경사항 (2025-01-26)

1. **슬라이드 순서 재배치**
   - Roblox 레퍼런스(game, Humanoid, Instance/Part)를 script.Parent(16) 바로 뒤(17-19)로 이동
   - 총 31슬라이드 → 30슬라이드 (중복 script 슬라이드 제거)

2. **코드 스니펫 스타일 수정**
   - `.code-snippet` 클래스 추가 (상단 점 제거)
   - 슬라이드 18, 19의 작은 코드 블록 적용

3. **코드 에디터 높이 증가**
   - `min-height: 260px` → `min-height: 320px`

4. **index.html 업데이트**
   - 2차시 활성화 (잠금 해제)
   - 제목: "Lua 기초와 인터랙티브 오브젝트"
   - 설명 업데이트

---

## 다음 작업 (TODO)

- [ ] 3차시 제작: 함수와 이벤트 (Touched 심화, Kill Part)
- [ ] 4차시 제작: 조건문 심화
- [ ] Lesson01.html 모듈화 (인라인 CSS/JS → 외부 파일)

---

## 배포 명령어

```bash
cd "G:\내 드라이브\_26_로블록스_과외"
netlify deploy --prod --dir=.
```

---

## 주의사항

1. **Lua 실행**: Fengari 사용 (Wasmoon은 file:// CORS 문제)
2. **슬라이드 번호**: section id와 SlideNavigator totalSlides 일치 필요
3. **키보드 입력**: textarea 포커스 시 슬라이드 이동 비활성화 처리됨
4. **코드 블록**: 큰 블록은 `.code-block`, 작은 스니펫은 `.code-snippet`
