import { LitElement, html, css } from 'lit';
import { customElement, property, state } from 'lit/decorators.js';
import { unsafeHTML } from 'lit/directives/unsafe-html.js';

/**
 * 로블록스 전용 예제 - 코드 내 드롭다운 퀴즈
 *
 * 브라우저에서 실행 불가능한 로블록스 API 코드를 학습하기 위한 컴포넌트
 * 학생이 코드 내 빈칸을 드롭다운으로 채우고, 모두 맞추면 복사 가능
 *
 * @example
 * <roblox-quiz-example
 *   name="회전 장애물"
 *   setup="Part 1개 (Anchored ✓, 길쭉하게 추천)"
 *   concepts='["CFrame", "math.rad", "task.wait"]'
 *   blanks='[
 *     {"id": "b1", "correct": "script.Parent", "options": ["script", "script.Parent", "Parent", "game"]},
 *     {"id": "b2", "correct": "true", "options": ["true", "false", "1", "nil"]},
 *     {"id": "b3", "correct": "speed", "options": ["part", "speed", "CFrame", "0.03"]}
 *   ]'
 *   template="local part = [b1]\nlocal speed = 2\n\nwhile [b2] do\n    part.CFrame = part.CFrame * CFrame.Angles(0, math.rad([b3]), 0)\n    task.wait(0.03)\nend"
 *   full-code="local part = script.Parent\nlocal speed = 2\n\nwhile true do\n    part.CFrame = part.CFrame * CFrame.Angles(0, math.rad(speed), 0)\n    task.wait(0.03)\nend"
 * ></roblox-quiz-example>
 */

interface Blank {
    id: string;
    correct: string;
    options: string[];
}

interface ConceptInfo {
    emoji: string;
    short: string;
    detail: string;
}

// 개념 설명 사전
const CONCEPT_DICTIONARY: Record<string, ConceptInfo> = {
    'script.Parent': {
        emoji: '🏠',
        short: '스크립트가 들어있는 파트',
        detail: '편지 봉투 📨 - 편지(스크립트)가 봉투(파트)에 들어있어요. script.Parent는 "내가 들어있는 곳"을 가리켜요!'
    },
    'BrickColor': {
        emoji: '🎨',
        short: '파트의 색깔',
        detail: '물감 팔레트 🎨 - 레고에 색칠하는 것처럼! BrickColor.new("Bright red")로 빨간색을 칠해요.'
    },
    'Transparency': {
        emoji: '👻',
        short: '투명도 (0=보임, 1=안보임)',
        detail: '유령 👻 - 0은 완전히 보이고, 1은 투명해요. 0.5는 반투명! 숫자가 클수록 투명해져요.'
    },
    'Vector3': {
        emoji: '📐',
        short: 'X, Y, Z 세 방향의 값',
        detail: '방 안에서 위치 찾기 🎯 - X는 좌우, Y는 위아래, Z는 앞뒤예요. Vector3.new(1, 2, 3)은 오른쪽1, 위로2, 앞으로3!'
    },
    'CFrame': {
        emoji: '🧭',
        short: '위치 + 방향을 함께 저장',
        detail: '나침반+GPS 🧭📍 - Vector3는 "어디에 있는지"만 알려줘요. CFrame은 "어디에 있고 + 어느 방향을 보는지"까지! 회전시킬 때는 CFrame을 써야 해요.'
    },
    'CFrame.Angles': {
        emoji: '🔄',
        short: '각 축으로 회전 각도',
        detail: '고개 움직이기 🙆 - X축=끄덕끄덕, Y축=젓기(좌우), Z축=갸우뚱. CFrame.Angles(X, Y, Z)로 회전해요!'
    },
    'math.rad': {
        emoji: '📏',
        short: '도(°)를 라디안으로 변환',
        detail: '외국어 번역기 🌐 - 우리는 90°처럼 말하지만, 컴퓨터는 라디안으로 계산해요. math.rad(90)으로 번역!'
    },
    'math.sin': {
        emoji: '🌊',
        short: '-1~1 부드러운 파동 값',
        detail: '파도 🌊 - sin 함수는 -1에서 1 사이를 부드럽게 왔다갔다해요. 크기가 자연스럽게 커졌다 작아졌다!'
    },
    'task.wait': {
        emoji: '⏱️',
        short: '지정한 시간만큼 대기',
        detail: '타이머 ⏱️ - task.wait(1)은 1초 쉬기! task.wait(0.5)는 0.5초(반초) 쉬기. while true do 안에 꼭 넣어야 게임이 안 멈춰요!'
    },
    'while': {
        emoji: '🔁',
        short: '조건이 참인 동안 반복',
        detail: '무한 달리기 🏃 - while true do는 영원히 반복! 회전하는 장애물, 깜빡이는 조명 등에 사용해요.'
    },
    'for': {
        emoji: '🔢',
        short: '정해진 횟수만큼 반복',
        detail: '카운트다운 📢 - for i = 1, 10 do는 1부터 10까지 10번 반복! 몇 번 반복할지 알 때 사용해요.'
    },
    'Instance.new': {
        emoji: '🏭',
        short: '새로운 오브젝트 생성',
        detail: '공장 🏭 - Instance.new("Part")로 새 파트를 만들어요! 레고 블록을 새로 꺼내는 것처럼.'
    },
    'Position': {
        emoji: '📍',
        short: '파트의 위치',
        detail: '지도 핀 📍 - part.Position으로 파트가 어디에 있는지 알 수 있어요. Vector3로 위치를 바꿀 수도 있어요!'
    },
    'Size': {
        emoji: '📦',
        short: '파트의 크기',
        detail: '택배 상자 📦 - part.Size = Vector3.new(2, 3, 4)면 가로2, 높이3, 깊이4인 상자 크기예요!'
    },
    'Anchored': {
        emoji: '⚓',
        short: '파트 고정 여부',
        detail: '닻 ⚓ - Anchored = true면 파트가 공중에 떠있어도 안 떨어져요. false면 중력에 의해 떨어져요!'
    },
    'Parent': {
        emoji: '🌳',
        short: '부모 오브젝트',
        detail: '가족 관계 🌳 - 나무에서 가지가 달린 것처럼, 모든 오브젝트는 부모가 있어요. workspace에 넣으면 화면에 보여요!'
    },
    'TextLabel': {
        emoji: '📝',
        short: '글자를 보여주는 UI',
        detail: '글자 표시판 📝 - 텍스트를 화면에 보여주는 UI 요소예요. Text 속성으로 글자를, TextColor3로 색상을 바꿀 수 있어요!'
    },
    'Color3.fromRGB': {
        emoji: '🎨',
        short: 'RGB로 색상 만들기',
        detail: '물감 섞기 🎨 - Red, Green, Blue 세 가지 색을 섞어요! Color3.fromRGB(255, 0, 0)은 빨강, (0, 255, 0)은 초록, (0, 0, 255)는 파랑!'
    },
    'ParticleEmitter': {
        emoji: '✨',
        short: '파티클 효과 생성기',
        detail: '반짝이 뿌리개 ✨ - Part에서 입자가 뿜어져 나와요! 불꽃, 연기, 반짝임 효과를 만들 수 있어요. Rate로 개수, Lifetime으로 수명 조절!'
    },
    'debounce': {
        emoji: '🔒',
        short: '연속 실행 방지 변수',
        detail: '잠금장치 🔒 - debounce가 true면 함수가 실행 안 돼요! 한 번 실행 후 쿨타임 동안 다시 실행되는 걸 막아줘요.'
    },
    'task.spawn': {
        emoji: '🚀',
        short: '별도 스레드에서 실행',
        detail: '분신술 🚀 - while true do가 있으면 그 아래 코드가 영원히 실행 안 돼요. task.spawn으로 "분신"을 만들어서 동시에 실행할 수 있어요!'
    },
    'humanoid.MaxHealth': {
        emoji: '💖',
        short: '최대 체력 값',
        detail: '체력 한계 💖 - Humanoid의 최대 체력이에요. 기본값은 100! humanoid.Health를 MaxHealth로 설정하면 완전 회복!'
    },
    'Touched': {
        emoji: '👆',
        short: '파트에 닿았을 때 이벤트',
        detail: '터치 감지 👆 - part.Touched:Connect(함수)로 연결하면, 누군가 파트에 닿을 때마다 함수가 실행돼요!'
    },
    'WalkSpeed': {
        emoji: '🏃',
        short: '캐릭터 이동 속도 (기본: 16)',
        detail: '달리기 속도 🏃 - humanoid.WalkSpeed로 이동 속도를 바꿔요! 0=정지, 16=기본, 32=2배 빠름, 50+=초고속! 스피드 패드에서 많이 사용해요.'
    },
    'JumpPower': {
        emoji: '🦘',
        short: '캐릭터 점프력 (기본: 50)',
        detail: '점프력 🦘 - humanoid.JumpPower로 점프 높이를 바꿔요! 0=점프 불가, 50=기본, 100=2배, 200+=로켓 점프! 점프 패드에서 사용해요.'
    },
    'Humanoid': {
        emoji: '🧠',
        short: '캐릭터의 두뇌 (능력치 관리)',
        detail: '캐릭터의 두뇌 🧠 - Health(체력), WalkSpeed(속도), JumpPower(점프력) 등 캐릭터의 모든 능력치를 관리해요! hit.Parent:FindFirstChild("Humanoid")로 찾아요.'
    },
    'HumanoidRootPart': {
        emoji: '🎯',
        short: '캐릭터의 중심 파트',
        detail: '캐릭터의 중심 🎯 - 캐릭터 모델의 "기준점"이에요. 텔레포트할 때 이 파트의 CFrame을 바꾸면 캐릭터가 순간이동해요!'
    },
    ':Destroy()': {
        emoji: '🗑️',
        short: '오브젝트를 완전히 삭제',
        detail: '완전 삭제 🗑️ - part:Destroy()하면 파트가 게임에서 완전히 사라져요! 코인 수집, 아이템 획득 등에 사용. 한 번 삭제하면 되돌릴 수 없어요!'
    },
    'CanCollide': {
        emoji: '💨',
        short: '충돌 여부 (true/false)',
        detail: '충돌 설정 💨 - true면 다른 파트와 부딪히고, false면 통과해요! 투명 코인이 발에 걸리지 않게 하려면 CanCollide = false!'
    },
    'ScreenGui': {
        emoji: '🖥️',
        short: '화면 UI의 컨테이너',
        detail: '화면 액자 🖥️ - 화면에 보이는 모든 UI(버튼, 글자, 이미지)를 담는 큰 액자예요! StarterGui 안에 넣으면 게임 시작할 때 자동으로 플레이어 화면에 나타나요.'
    },
    'Frame': {
        emoji: '📦',
        short: 'UI 요소들을 묶는 상자',
        detail: '정리 상자 📦 - 여러 UI(TextLabel, TextButton 등)를 하나로 묶어주는 컨테이너예요! 배경색, 투명도, 크기를 설정할 수 있고, 안에 넣은 UI들을 함께 이동/숨기기 할 수 있어요.'
    },
    'TextButton': {
        emoji: '🔘',
        short: '클릭할 수 있는 버튼',
        detail: '누르는 버튼 🔘 - TextLabel처럼 글자를 보여주지만, 클릭할 수 있어요! MouseButton1Click 이벤트로 클릭했을 때 동작을 연결해요.'
    },
    'UDim2': {
        emoji: '📐',
        short: 'UI 크기/위치 설정 값',
        detail: 'UI 자 📐 - UDim2.new(scaleX, offsetX, scaleY, offsetY)로 크기와 위치를 정해요! Scale(비율): 0.5 = 화면의 50%, Offset(픽셀): 100 = 100픽셀. 보통 Scale을 많이 써요!'
    },
    'MouseButton1Click': {
        emoji: '🖱️',
        short: '마우스 왼쪽 클릭 이벤트',
        detail: '클릭 감지 🖱️ - TextButton을 마우스로 클릭하면 실행! button.MouseButton1Click:Connect(function() ... end)로 연결해요. Touched처럼 이벤트예요!'
    },
    'LocalScript': {
        emoji: '💻',
        short: '클라이언트(내 컴퓨터)에서 실행',
        detail: '내 컴퓨터 전용 스크립트 💻 - GUI(버튼, 텍스트)를 다루려면 LocalScript를 써야 해요! 일반 Script는 서버에서 실행되지만, LocalScript는 내 화면에서 실행돼요.'
    },
    'StarterGui': {
        emoji: '🏠',
        short: 'GUI를 넣어두는 시작 폴더',
        detail: 'GUI 보관함 🏠 - StarterGui에 ScreenGui를 넣으면 게임 시작할 때 모든 플레이어 화면에 자동으로 나타나요! Explorer에서 StarterGui를 찾아보세요.'
    },
    'BackgroundTransparency': {
        emoji: '👻',
        short: 'UI 배경 투명도 (0=보임, 1=투명)',
        detail: 'UI 투명도 👻 - 0이면 배경이 완전히 보이고, 1이면 완전 투명! 글자만 보이게 하려면 BackgroundTransparency = 1로 설정해요.'
    },
    ':WaitForChild()': {
        emoji: '⏳',
        short: '자식 오브젝트가 로드될 때까지 대기',
        detail: '기다리기 ⏳ - :FindFirstChild()는 없으면 nil을 반환하지만, :WaitForChild()는 나타날 때까지 기다려요! GUI 요소를 찾을 때 안전하게 사용해요.'
    },
    'UICorner': {
        emoji: '⭕',
        short: 'UI 모서리를 둥글게',
        detail: '둥근 모서리 ⭕ - Frame이나 Button에 UICorner를 넣으면 모서리가 둥글어져요! CornerRadius로 얼마나 둥글게 할지 정해요. UDim.new(0, 12)는 12픽셀만큼 둥글게!'
    },
    'UIStroke': {
        emoji: '🖊️',
        short: 'UI 테두리/외곽선',
        detail: '테두리 그리기 🖊️ - UI에 외곽선을 추가해요! Thickness(두께), Color(색상)을 설정할 수 있어요. 예쁜 버튼을 만들 때 필수!'
    },
    'ImageLabel': {
        emoji: '🖼️',
        short: '이미지를 보여주는 UI',
        detail: '사진 액자 🖼️ - 화면에 이미지를 표시해요! Image 속성에 rbxassetid://숫자 형태로 이미지 ID를 넣어요. Toolbox에서 이미지를 찾을 수 있어요!'
    },
    'ImageButton': {
        emoji: '🎯',
        short: '클릭 가능한 이미지 버튼',
        detail: '이미지 버튼 🎯 - ImageLabel처럼 이미지를 보여주면서 클릭도 가능해요! MouseButton1Click으로 클릭 이벤트를 연결할 수 있어요.'
    },
    'TweenService': {
        emoji: '🎬',
        short: '부드러운 애니메이션 서비스',
        detail: '애니메이션 감독 🎬 - 위치, 크기, 투명도 등을 부드럽게 변화시켜요! TweenService:Create(대상, 정보, 목표)로 만들고 :Play()로 재생!'
    },
    'TweenInfo': {
        emoji: '⚙️',
        short: '트윈 애니메이션 설정',
        detail: '애니메이션 설정 ⚙️ - TweenInfo.new(시간, 스타일)로 얼마나 걸릴지, 어떤 느낌으로 움직일지 정해요! Enum.EasingStyle.Quad는 부드러운 가감속!'
    },
    'BillboardGui': {
        emoji: '🏷️',
        short: '3D 파트 위에 뜨는 GUI',
        detail: '머리 위 이름표 🏷️ - 파트 위에 떠다니는 GUI예요! 이름표, 체력바, 표시판 등에 사용해요. StudsOffset으로 얼마나 위에 뜰지 정하고, Size로 크기를 정해요.'
    },
    'Visible': {
        emoji: '👁️',
        short: 'UI 보이기/숨기기 (true/false)',
        detail: '보이기 설정 👁️ - Visible = true면 보이고, false면 안 보여요! 버튼 클릭으로 패널을 열고 닫을 때 사용해요. not으로 토글: frame.Visible = not frame.Visible'
    },
    'TextScaled': {
        emoji: '🔤',
        short: '글자 크기 자동 맞춤',
        detail: '자동 크기 🔤 - TextScaled = true로 설정하면 글자가 UI 크기에 맞게 자동으로 커지거나 작아져요! 다양한 화면 크기에서도 깔끔하게 보여요.'
    },
    'SurfaceGui': {
        emoji: '🪧',
        short: '파트 표면에 붙는 GUI',
        detail: '표면 GUI 🪧 - 파트의 표면에 직접 붙는 GUI예요! 간판, 안내판, TV 화면, 점수판 등에 사용해요. Face 속성으로 어느 면(Front, Back, Top 등)에 표시할지 정해요. BillboardGui와 달리 파트와 함께 회전해요!'
    },
    'Enum.NormalId': {
        emoji: '🧭',
        short: 'SurfaceGui가 붙을 면 방향',
        detail: '면 방향 🧭 - SurfaceGui의 Face 속성에 사용해요! Front(앞), Back(뒤), Top(위), Bottom(아래), Left(왼쪽), Right(오른쪽) 6가지가 있어요.'
    },
    'Tool': {
        emoji: '⚔️',
        short: '캐릭터가 장착하는 도구',
        detail: '장착 아이템 ⚔️ - 검, 지팡이, 총 같은 도구예요! Handle(손잡이)이 꼭 있어야 하고, StarterPack에 넣으면 게임 시작할 때 자동으로 받아요. Backpack에서 1~9키로 장착!'
    },
    'Handle': {
        emoji: '✋',
        short: 'Tool에서 손에 쥐는 파트',
        detail: '손잡이 ✋ - Tool 안에 반드시 있어야 하는 특별한 파트예요! 이름을 정확히 "Handle"로 해야 로블록스가 캐릭터 손에 붙여줘요. 검이라면 칼날+손잡이 파트 이름을 "Handle"로!'
    },
    'StarterPack': {
        emoji: '🎒',
        short: '시작 시 자동 지급 보관함',
        detail: '스타터 꾸러미 🎒 - StarterPack에 Tool을 넣으면 게임 시작할 때 모든 플레이어가 자동으로 받아요! Explorer에서 StarterPack을 찾아서 Tool을 드래그해요.'
    },
    'Backpack': {
        emoji: '🎽',
        short: '플레이어 도구 인벤토리',
        detail: '인벤토리 🎽 - 플레이어가 가지고 있는 Tool들이 들어있는 인벤토리예요! 화면 하단의 1~9 슬롯이 Backpack이에요. Tool을 Backpack에 넣으면 가방에 추가돼요!'
    },
    'Activated': {
        emoji: '🖱️',
        short: 'Tool 들고 클릭했을 때',
        detail: '활성화 클릭 🖱️ - Tool을 장착한 상태에서 마우스 왼쪽 클릭하면 실행돼요! tool.Activated:Connect(function() ... end)로 연결해요. 검 휘두르기, 총 쏘기에 사용!'
    },
    'Equipped': {
        emoji: '👊',
        short: 'Tool을 장착했을 때',
        detail: '장착 이벤트 👊 - 플레이어가 Tool을 꺼낼 때(1~9키) 실행돼요! tool.Equipped:Connect(function() ... end)로 연결. 장착 효과음, 특수 능력 활성화 등에 사용!'
    },
    'Unequipped': {
        emoji: '✌️',
        short: 'Tool을 해제했을 때',
        detail: '해제 이벤트 ✌️ - 플레이어가 Tool을 집어넣을 때 실행돼요! tool.Unequipped:Connect(function() ... end)로 연결. 능력 비활성화, 효과 제거 등에 사용!'
    },
    'TakeDamage': {
        emoji: '💢',
        short: '캐릭터에게 데미지 주기',
        detail: '데미지 공격 💢 - humanoid:TakeDamage(숫자)로 체력을 깎아요! Health를 직접 바꾸는 것보다 안전해요. TakeDamage(25)면 체력 -25! 0이 되면 사망!'
    },
    'BodyVelocity': {
        emoji: '🚀',
        short: '파트에 속도를 부여하는 힘',
        detail: '속도 엔진 🚀 - 파트를 특정 방향으로 날려요! Velocity로 방향과 속도를 설정하고, MaxForce로 최대 힘을 정해요. BodyVelocity.new()로 생성 후 orb에 넣어요!'
    },
    'Debris': {
        emoji: '🗑️',
        short: 'N초 후 자동 삭제 서비스',
        detail: '자동 청소부 🗑️ - Debris:AddItem(파트, 시간)으로 파트를 몇 초 후에 자동으로 삭제해요! 발사된 구체가 3초 후에 사라지게 할 때 사용. 직접 Destroy() 안 해도 돼요!'
    },
    'PointLight': {
        emoji: '💡',
        short: '점에서 빛이 나오는 광원',
        detail: '전구 효과 💡 - 파트 주변을 환하게 밝혀요! Brightness(밝기)와 Range(범위)로 조절해요. 마법 구체, 횃불, 가로등 등에 사용! Part나 Handle에 넣으면 빛 효과가 생겨요.'
    }
};

@customElement('roblox-quiz-example')
export class RobloxQuizExample extends LitElement {
    static styles = css`
        :host {
            display: block;
            font-family: 'Pretendard', sans-serif;
            height: 100%;
            overflow: hidden;
        }

        .container {
            display: grid;
            grid-template-columns: 1fr 2fr;
            grid-template-rows: 1fr;
            gap: 1rem;
            height: 100%;
            max-width: 1100px;
            margin: 0 auto;
            padding: 0.75rem 2rem;
            box-sizing: border-box;
        }

        /* 왼쪽 패널 */
        .left-panel {
            display: flex;
            flex-direction: column;
            gap: 0.75rem;
            padding: 0.5rem;
            align-self: start;
        }

        /* 오른쪽 패널 */
        .right-panel {
            display: flex;
            flex-direction: column;
            gap: 0.75rem;
            min-height: 0;
            overflow: hidden;
        }

        /* 헤더 */
        .header {
            margin-bottom: 0;
        }

        .title {
            font-family: 'Space Grotesk', sans-serif;
            font-size: 1.25rem;
            font-weight: 700;
            color: #1a1625;
            margin-bottom: 0.35rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .setup {
            background: linear-gradient(135deg, #e0f2fe 0%, #bae6fd 100%);
            border-left: 4px solid #0ea5e9;
            border-radius: 0 10px 10px 0;
            padding: 0.4rem 0.75rem;
            font-size: 0.8rem;
            color: #0369a1;
        }

        .setup-label {
            font-weight: 600;
        }

        /* 개념 뱃지 영역 */
        .concepts-section {
            margin-bottom: 0;
        }

        .concepts-title {
            font-size: 0.75rem;
            color: #64748b;
            margin-bottom: 0.4rem;
            font-weight: 500;
        }

        .concept-badges {
            display: flex;
            flex-wrap: wrap;
            gap: 0.35rem;
        }

        .concept-badge {
            display: inline-flex;
            align-items: center;
            gap: 0.25rem;
            padding: 0.3rem 0.6rem;
            background: white;
            border: 1.5px solid #e2e8f0;
            border-radius: 16px;
            font-size: 0.78rem;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.2s ease;
        }

        .concept-badge:hover {
            border-color: #6BCFFF;
            background: #f0f9ff;
            transform: translateY(-2px);
        }

        .concept-badge.expanded {
            border-color: #6BCFFF;
            background: #f0f9ff;
        }

        .concept-emoji {
            font-size: 1rem;
        }

        /* 개념 상세 설명 */
        .concept-detail {
            background: linear-gradient(135deg, #f0f9ff 0%, #e0f2fe 100%);
            border: 1px solid #bae6fd;
            border-radius: 12px;
            padding: 1rem;
            margin-top: 0.75rem;
            animation: slideDown 0.2s ease-out;
        }

        @keyframes slideDown {
            from { opacity: 0; transform: translateY(-8px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .concept-detail-title {
            font-weight: 700;
            margin-bottom: 0.5rem;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }

        .concept-detail-text {
            font-size: 0.9rem;
            color: #334155;
            line-height: 1.6;
        }

        /* 코드 블록 */
        .code-section {
            background: #1a1625;
            border-radius: 12px;
            overflow-y: auto;
            overflow-x: hidden;
            margin-bottom: 0;
            flex: 1;
            min-height: 0;
            scrollbar-width: none;
        }

        .code-section::-webkit-scrollbar {
            display: none;
        }

        .code-header {
            display: flex;
            align-items: center;
            padding: 8px 14px;
            gap: 6px;
        }

        .code-dots {
            display: flex;
            gap: 6px;
        }

        .code-dot {
            width: 10px;
            height: 10px;
            border-radius: 50%;
        }

        .code-dot.red { background: #FF6B6B; }
        .code-dot.yellow { background: #FFD93D; }
        .code-dot.green { background: #3DFFA2; }

        .code-title {
            margin-left: 6px;
            color: #9CA3AF;
            font-size: 0.78rem;
        }

        .code-content {
            padding: 0 1.25rem 1rem;
            font-family: 'JetBrains Mono', monospace;
            font-size: 0.82rem;
            line-height: 1.3;
            overflow-x: auto;
        }

        .code-line {
            display: flex;
            align-items: center;
            flex-wrap: wrap;
            min-height: 1.2em;
            padding: 0;
        }

        .code-text {
            color: #E8E6E3;
            white-space: pre;
        }

        /* 구문 강조 */
        .lua-keyword { color: #C792EA; }
        .lua-builtin { color: #82AAFF; }
        .lua-roblox { color: #89DDFF; }
        .lua-string { color: #C3E88D; }
        .lua-number { color: #F78C6C; }
        .lua-comment { color: #676E95; font-style: italic; }
        .lua-function { color: #FFCB6B; }
        .lua-property { color: #F07178; }
        .lua-operator { color: #89DDFF; }

        /* 드롭다운 */
        .dropdown-wrapper {
            position: relative;
            display: inline-block;
            margin: 0 2px;
        }

        .dropdown-button {
            background: #2d2640;
            border: 2px solid #6BCFFF;
            border-radius: 6px;
            padding: 2px 8px;
            color: #6BCFFF;
            font-family: 'JetBrains Mono', monospace;
            font-size: 0.82rem;
            cursor: pointer;
            transition: all 0.15s ease;
            display: inline-flex;
            align-items: center;
            gap: 4px;
            min-width: 80px;
            justify-content: space-between;
        }

        .dropdown-button:hover {
            background: #3d3654;
            border-color: #FFD93D;
        }

        .dropdown-button.correct {
            background: rgba(61, 255, 162, 0.2);
            border-color: #3DFFA2;
            color: #3DFFA2;
        }

        .dropdown-button.wrong {
            background: rgba(255, 107, 107, 0.2);
            border-color: #FF6B6B;
            color: #FF6B6B;
        }

        .dropdown-arrow {
            font-size: 0.7rem;
            transition: transform 0.2s;
        }

        .dropdown-button.open .dropdown-arrow {
            transform: rotate(180deg);
        }

        .dropdown-menu {
            position: absolute;
            top: calc(100% + 4px);
            left: 0;
            background: #2d2640;
            border: 2px solid #3d3654;
            border-radius: 8px;
            min-width: 150px;
            z-index: 100;
            box-shadow: 0 8px 24px rgba(0, 0, 0, 0.4);
            animation: dropdownOpen 0.15s ease-out;
        }

        @keyframes dropdownOpen {
            from { opacity: 0; transform: translateY(-8px); }
            to { opacity: 1; transform: translateY(0); }
        }

        .dropdown-option {
            padding: 7px 12px;
            color: #E8E6E3;
            cursor: pointer;
            transition: background 0.1s;
            font-family: 'JetBrains Mono', monospace;
            font-size: 0.82rem;
        }

        .dropdown-option:first-child {
            border-radius: 6px 6px 0 0;
        }

        .dropdown-option:last-child {
            border-radius: 0 0 6px 6px;
        }

        .dropdown-option:hover {
            background: #3d3654;
        }

        .dropdown-option.selected {
            background: rgba(107, 207, 255, 0.2);
            color: #6BCFFF;
        }

        /* 제출 영역 */
        .submit-section {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 0.5rem;
            flex-shrink: 0;
        }

        .progress-text {
            font-size: 0.85rem;
            color: #64748b;
        }

        .progress-text.complete {
            color: #3DFFA2;
            font-weight: 600;
        }

        .submit-btn {
            background: linear-gradient(180deg, #6BCFFF 0%, #3b82f6 100%);
            color: white;
            font-family: 'Space Grotesk', sans-serif;
            font-weight: 700;
            font-size: 0.9rem;
            padding: 10px 24px;
            border-radius: 12px;
            border: none;
            cursor: pointer;
            box-shadow: 0 4px 0 #2563eb, 0 4px 14px rgba(59, 130, 246, 0.35);
            transform: translateY(0);
            transition: all 0.15s;
        }

        .submit-btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 9px 0 #2563eb, 0 9px 28px rgba(59, 130, 246, 0.45);
        }

        .submit-btn:active {
            transform: translateY(4px);
            box-shadow: 0 2px 0 #2563eb, 0 2px 8px rgba(59, 130, 246, 0.2);
        }

        .submit-btn:disabled {
            opacity: 0.5;
            cursor: not-allowed;
            transform: none;
        }

        /* 복사 영역 */
        .copy-section {
            background: linear-gradient(135deg, #d1fae5 0%, #a7f3d0 100%);
            border: 2px solid #3DFFA2;
            border-radius: 12px;
            padding: 1rem;
            text-align: center;
            animation: celebrate 0.5s ease-out;
            flex-shrink: 0;
        }

        @keyframes celebrate {
            0% { transform: scale(0.95); opacity: 0; }
            50% { transform: scale(1.02); }
            100% { transform: scale(1); opacity: 1; }
        }

        .copy-section h3 {
            font-family: 'Space Grotesk', sans-serif;
            font-weight: 700;
            color: #065f46;
            margin-bottom: 1rem;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.5rem;
        }

        .copy-btn {
            background: linear-gradient(180deg, #3DFFA2 0%, #2DD88A 100%);
            color: #1a1625;
            font-family: 'Space Grotesk', sans-serif;
            font-weight: 700;
            font-size: 1.1rem;
            padding: 16px 40px;
            border-radius: 14px;
            border: none;
            cursor: pointer;
            box-shadow: 0 6px 0 #1FA86A, 0 6px 20px rgba(61, 255, 162, 0.35);
            transform: translateY(0);
            transition: all 0.15s;
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
        }

        .copy-btn:hover {
            transform: translateY(-3px);
            box-shadow: 0 9px 0 #1FA86A, 0 9px 28px rgba(61, 255, 162, 0.45);
        }

        .copy-btn:active {
            transform: translateY(4px);
            box-shadow: 0 2px 0 #1FA86A, 0 2px 8px rgba(61, 255, 162, 0.2);
        }

        .copy-btn.copied {
            background: linear-gradient(180deg, #FFD93D 0%, #F59E0B 100%);
            box-shadow: 0 6px 0 #D97706, 0 6px 20px rgba(245, 158, 11, 0.35);
        }

        .copy-hint {
            margin-top: 1rem;
            font-size: 0.85rem;
            color: #065f46;
        }

        /* 결과 메시지 */
        .result-message {
            padding: 1rem;
            border-radius: 12px;
            text-align: center;
            margin-bottom: 1rem;
            animation: slideDown 0.3s ease-out;
        }

        .result-message.partial {
            background: linear-gradient(135deg, #fef3c7 0%, #fde68a 100%);
            border: 1px solid #f59e0b;
            color: #92400e;
        }

        .result-message.wrong {
            background: linear-gradient(135deg, #fee2e2 0%, #fecaca 100%);
            border: 1px solid #f87171;
            color: #991b1b;
        }

        /* 잠금 상태 표시 */
        .lock-status {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 0.4rem;
            padding: 0.4rem 0.75rem;
            background: #f1f5f9;
            border-radius: 10px;
            font-size: 0.8rem;
            color: #64748b;
        }

        .lock-status.unlocked {
            background: #d1fae5;
            color: #065f46;
        }

        /* 리셋 버튼 */
        .reset-btn {
            background: white;
            color: #64748b;
            font-size: 0.85rem;
            padding: 8px 16px;
            border-radius: 8px;
            border: 2px solid #e2e8f0;
            cursor: pointer;
            transition: all 0.15s;
        }

        .reset-btn:hover {
            border-color: #FF6B6B;
            color: #FF6B6B;
        }
    `;

    @property({ type: String }) name = '';
    @property({ type: String }) setup = '';
    @property({ type: String }) concepts = '[]';
    @property({ type: String }) blanks = '[]';
    @property({ type: String }) template = '';
    @property({ attribute: 'full-code', type: String }) fullCode = '';

    @state() private parsedBlanks: Blank[] = [];
    @state() private parsedConcepts: string[] = [];
    @state() private userAnswers: Record<string, string> = {};
    @state() private openDropdown: string | null = null;
    @state() private expandedConcept: string | null = null;
    @state() private submitted = false;
    @state() private allCorrect = false;
    @state() private copied = false;
    @state() private correctCount = 0;

    connectedCallback() {
        super.connectedCallback();
        this.parseData();
        // Close dropdowns when clicking outside
        document.addEventListener('click', this.handleOutsideClick);
    }

    disconnectedCallback() {
        super.disconnectedCallback();
        document.removeEventListener('click', this.handleOutsideClick);
    }

    private handleOutsideClick = (e: Event) => {
        const path = e.composedPath();
        const clickedDropdown = path.some((el: any) =>
            el.classList?.contains('dropdown-wrapper')
        );
        if (!clickedDropdown) {
            this.openDropdown = null;
        }
    };

    updated(changedProperties: Map<string, unknown>) {
        if (changedProperties.has('blanks') || changedProperties.has('concepts')) {
            this.parseData();
        }
    }

    private parseData() {
        try {
            this.parsedBlanks = JSON.parse(this.blanks);
            this.parsedConcepts = JSON.parse(this.concepts);
            // Initialize user answers
            this.parsedBlanks.forEach(blank => {
                if (!this.userAnswers[blank.id]) {
                    this.userAnswers[blank.id] = '';
                }
            });
        } catch (e) {
            console.error('Failed to parse blanks or concepts:', e);
        }
    }

    private highlightCode(text: string): string {
        let highlighted = text
            .replace(/&/g, '&amp;')
            .replace(/</g, '&lt;')
            .replace(/>/g, '&gt;')
            // 문자열 (큰따옴표)
            .replace(/"([^"\\]|\\.)*"/g, '<span class="lua-string">$&</span>')
            // 문자열 (작은따옴표)
            .replace(/'([^'\\]|\\.)*'/g, '<span class="lua-string">$&</span>')
            // 주석
            .replace(/--.*/g, '<span class="lua-comment">$&</span>')
            // 숫자
            .replace(/\b(\d+\.?\d*)\b/g, '<span class="lua-number">$1</span>')
            // Roblox 전역 객체
            .replace(/\b(script|game|workspace|Instance|Vector3|CFrame|BrickColor|Color3|UDim2|Enum|TweenService|Players|ReplicatedStorage|ServerStorage|StarterGui)\b/g,
                '<span class="lua-roblox">$1</span>')
            // Lua 키워드
            .replace(/\b(local|function|end|if|then|else|elseif|for|while|do|return|and|or|not|in|repeat|until|break|nil|true|false)\b/g,
                '<span class="lua-keyword">$1</span>')
            // 내장 함수
            .replace(/\b(print|warn|wait|require|pairs|ipairs|type|tostring|tonumber|error|pcall|xpcall|select|unpack|setmetatable|getmetatable|rawget|rawset|next|assert|collectgarbage|loadstring|spawn|delay|tick|time|typeof|math|task)\b/g,
                '<span class="lua-builtin">$1</span>')
            // 속성 접근
            .replace(/\.([A-Za-z_][A-Za-z0-9_]*)/g, '.<span class="lua-property">$1</span>')
            // 함수 호출
            .replace(/\b([A-Za-z_][A-Za-z0-9_]*)\s*(?=\()/g, '<span class="lua-function">$1</span>');

        return highlighted;
    }

    private dropdownInstanceCounter = 0;

    private renderCodeWithBlanks() {
        const lines = this.template.split('\n');
        this.dropdownInstanceCounter = 0; // Reset counter for each render

        return lines.map((line, lineIndex) => {
            // Parse line to find blank placeholders [b1], [b2], etc.
            const parts: (string | { blankId: string; instanceId: string })[] = [];
            const blankRegex = /\[([^\]]+)\]/g;
            let lastIndex = 0;
            let match;

            while ((match = blankRegex.exec(line)) !== null) {
                // Add text before the blank
                if (match.index > lastIndex) {
                    parts.push(line.slice(lastIndex, match.index));
                }
                // Add blank placeholder with unique instance ID
                const instanceId = `${match[1]}_${this.dropdownInstanceCounter++}`;
                parts.push({ blankId: match[1], instanceId });
                lastIndex = match.index + match[0].length;
            }
            // Add remaining text
            if (lastIndex < line.length) {
                parts.push(line.slice(lastIndex));
            }

            // If no blanks in this line, just return highlighted text
            if (parts.length === 1 && typeof parts[0] === 'string') {
                return html`
                    <div class="code-line">
                        <span class="code-text">${unsafeHTML(this.highlightCode(line))}</span>
                    </div>
                `;
            }

            return html`
                <div class="code-line">
                    ${parts.map(part => {
                        if (typeof part === 'string') {
                            return html`<span class="code-text">${unsafeHTML(this.highlightCode(part))}</span>`;
                        } else {
                            const blank = this.parsedBlanks.find(b => b.id === part.blankId);
                            if (!blank) return html`<span class="code-text">[???]</span>`;
                            return this.renderDropdown(blank, part.instanceId);
                        }
                    })}
                </div>
            `;
        });
    }

    private renderDropdown(blank: Blank, instanceId: string) {
        const isOpen = this.openDropdown === instanceId;
        const currentValue = this.userAnswers[blank.id] || '';
        const isCorrect = this.submitted && currentValue === blank.correct;
        const isWrong = this.submitted && currentValue && currentValue !== blank.correct;

        return html`
            <span class="dropdown-wrapper" @click=${(e: Event) => e.stopPropagation()}>
                <button
                    class="dropdown-button ${isOpen ? 'open' : ''} ${isCorrect ? 'correct' : ''} ${isWrong ? 'wrong' : ''}"
                    @click=${() => this.toggleDropdown(instanceId)}
                    ?disabled=${this.allCorrect}
                >
                    <span>${currentValue || '선택하세요'}</span>
                    ${!this.allCorrect ? html`
                        <span class="dropdown-arrow">▼</span>
                    ` : isCorrect ? html`<span>✓</span>` : html`<span>✗</span>`}
                </button>
                ${isOpen && !this.allCorrect ? html`
                    <div class="dropdown-menu">
                        ${blank.options.map(option => html`
                            <div
                                class="dropdown-option ${currentValue === option ? 'selected' : ''}"
                                @click=${() => this.selectOption(blank.id, option)}
                            >
                                ${option}
                            </div>
                        `)}
                    </div>
                ` : ''}
            </span>
        `;
    }

    private toggleDropdown(instanceId: string) {
        if (this.allCorrect) return;
        this.openDropdown = this.openDropdown === instanceId ? null : instanceId;
    }

    private selectOption(blankId: string, option: string) {
        this.userAnswers = { ...this.userAnswers, [blankId]: option };
        this.openDropdown = null;
        this.submitted = false; // Reset submitted state when answer changes
    }

    private handleSubmit() {
        this.submitted = true;
        this.correctCount = 0;

        for (const blank of this.parsedBlanks) {
            if (this.userAnswers[blank.id] === blank.correct) {
                this.correctCount++;
            }
        }

        this.allCorrect = this.correctCount === this.parsedBlanks.length;
    }

    private handleReset() {
        this.userAnswers = {};
        this.parsedBlanks.forEach(blank => {
            this.userAnswers[blank.id] = '';
        });
        this.submitted = false;
        this.allCorrect = false;
        this.correctCount = 0;
        this.copied = false;
    }

    private async copyCode() {
        try {
            await navigator.clipboard.writeText(this.fullCode);
            this.copied = true;
            setTimeout(() => { this.copied = false; }, 2000);
        } catch (err) {
            console.error('복사 실패:', err);
        }
    }

    private toggleConcept(concept: string) {
        this.expandedConcept = this.expandedConcept === concept ? null : concept;
    }

    private getConceptInfo(concept: string): ConceptInfo {
        // Try to find exact match first
        if (CONCEPT_DICTIONARY[concept]) {
            return CONCEPT_DICTIONARY[concept];
        }
        // Try to find partial match
        for (const key of Object.keys(CONCEPT_DICTIONARY)) {
            if (concept.toLowerCase().includes(key.toLowerCase()) ||
                key.toLowerCase().includes(concept.toLowerCase())) {
                return CONCEPT_DICTIONARY[key];
            }
        }
        // Default
        return {
            emoji: '📚',
            short: concept,
            detail: `${concept}에 대해 더 알아보세요!`
        };
    }

    render() {
        const totalBlanks = this.parsedBlanks.length;
        const allAnswered = this.parsedBlanks.every(b => this.userAnswers[b.id]);

        return html`
            <div class="container">
                <!-- 왼쪽 패널: 헤더 + 개념 -->
                <div class="left-panel">
                    <div class="header">
                        <h2 class="title">
                            <span>🎮</span>
                            ${this.name}
                        </h2>
                        ${this.setup ? html`
                            <div class="setup">
                                <span class="setup-label">📦 준비물:</span> ${this.setup}
                            </div>
                        ` : ''}
                    </div>

                    ${this.parsedConcepts.length > 0 ? html`
                        <div class="concepts-section">
                            <div class="concepts-title">💡 사용된 개념 (클릭하면 상세 설명!)</div>
                            <div class="concept-badges">
                                ${this.parsedConcepts.map(concept => {
                                    const info = this.getConceptInfo(concept);
                                    return html`
                                        <button
                                            class="concept-badge ${this.expandedConcept === concept ? 'expanded' : ''}"
                                            @click=${() => this.toggleConcept(concept)}
                                        >
                                            <span class="concept-emoji">${info.emoji}</span>
                                            <span>${concept}</span>
                                        </button>
                                    `;
                                })}
                            </div>
                            ${this.expandedConcept ? html`
                                <div class="concept-detail">
                                    <div class="concept-detail-title">
                                        <span>${this.getConceptInfo(this.expandedConcept).emoji}</span>
                                        <span>${this.expandedConcept}</span>
                                    </div>
                                    <div class="concept-detail-text">
                                        ${this.getConceptInfo(this.expandedConcept).detail}
                                    </div>
                                </div>
                            ` : ''}
                        </div>
                    ` : ''}
                </div>

                <!-- 오른쪽 패널: 코드 + 제출/복사 -->
                <div class="right-panel">
                    <div class="code-section">
                        <div class="code-header">
                            <div class="code-dots">
                                <div class="code-dot red"></div>
                                <div class="code-dot yellow"></div>
                                <div class="code-dot green"></div>
                            </div>
                            <span class="code-title">빈칸을 채워주세요!</span>
                        </div>
                        <div class="code-content">
                            ${this.renderCodeWithBlanks()}
                        </div>
                    </div>

                    ${this.submitted && !this.allCorrect ? html`
                        <div class="result-message ${this.correctCount > 0 ? 'partial' : 'wrong'}">
                            ${this.correctCount > 0
                                ? `${this.correctCount}/${totalBlanks}개 정답! 나머지도 맞춰보세요 💪`
                                : '다시 한번 생각해보세요! 힌트: 개념 뱃지를 클릭해보세요 💡'
                            }
                        </div>
                    ` : ''}

                    ${!this.allCorrect ? html`
                        <div class="submit-section">
                            <div class="lock-status">
                                🔒 모든 빈칸을 맞춰야 복사 가능! (${this.submitted ? this.correctCount : 0}/${totalBlanks})
                            </div>
                            <button
                                class="submit-btn"
                                @click=${this.handleSubmit}
                                ?disabled=${!allAnswered}
                            >
                                ✅ 제출하기
                            </button>
                            ${this.submitted ? html`
                                <button class="reset-btn" @click=${this.handleReset}>
                                    🔄 다시 풀기
                                </button>
                            ` : ''}
                        </div>
                    ` : html`
                        <div class="copy-section">
                            <h3>🎉 모든 정답! (${totalBlanks}/${totalBlanks})</h3>
                            <button
                                class="copy-btn ${this.copied ? 'copied' : ''}"
                                @click=${this.copyCode}
                            >
                                ${this.copied ? '✓ 복사됨!' : '📋 코드 복사하기'}
                            </button>
                            <div class="copy-hint">
                                💡 로블록스 스튜디오에서 Part에 Script를 넣고 붙여넣기!
                            </div>
                            <button class="reset-btn" @click=${this.handleReset} style="margin-top: 1rem;">
                                🔄 다시 풀기
                            </button>
                        </div>
                    `}
                </div>
            </div>
        `;
    }
}

declare global {
    interface HTMLElementTagNameMap {
        'roblox-quiz-example': RobloxQuizExample;
    }
}
