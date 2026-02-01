import { LitElement, html, css } from 'lit';
import { customElement, property, state } from 'lit/decorators.js';
import { executeLua, initLuaEngine, type LuaOutput } from '../../lib/lua-runtime';

/**
 * 프로그래머스 스타일 Lua 코드 에디터
 */
@customElement('lua-editor')
export class LuaEditor extends LitElement {
    static styles = css`
        :host {
            display: block;
            font-family: 'Pretendard', sans-serif;
            height: 100%;
            width: 100%;
        }

        /* 전체 컨테이너 */
        .editor-wrapper {
            background: #263747;
            border-radius: 12px;
            overflow: hidden;
            box-shadow: 0 8px 32px rgba(0,0,0,0.3);
            display: flex;
            flex-direction: column;
            height: 100%;
            min-height: 500px;
        }

        /* 상단 헤더 */
        .editor-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 12px 20px;
            background: #1e2d3d;
            border-bottom: 1px solid #3d4f5f;
        }

        .header-title {
            font-size: 1rem;
            font-weight: 600;
            color: #fff;
        }

        .header-controls {
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .theme-btn {
            padding: 4px 10px;
            border-radius: 4px;
            font-size: 0.75rem;
            cursor: pointer;
            border: 1px solid #3d4f5f;
            background: transparent;
            color: #8b9eb0;
            transition: all 0.15s;
        }
        .theme-btn.active {
            background: #3d4f5f;
            color: #fff;
        }
        .theme-btn:hover {
            border-color: #5a7a8a;
        }

        .lang-badge {
            padding: 4px 12px;
            border-radius: 4px;
            font-size: 0.75rem;
            font-weight: 600;
            background: #3d4f5f;
            color: #98d4ff;
        }

        /* 메인 영역 (2단) */
        .main-area {
            display: grid;
            grid-template-columns: 380px 1fr;
            flex: 1;
            overflow: hidden;
        }

        @media (max-width: 900px) {
            .main-area {
                grid-template-columns: 1fr;
            }
            .problem-panel {
                max-height: 200px;
            }
        }

        /* 왼쪽: 문제 설명 */
        .problem-panel {
            background: #1e2d3d;
            padding: 24px;
            overflow-y: auto;
            border-right: 1px solid #3d4f5f;
        }

        .problem-label {
            font-size: 0.8rem;
            color: #8b9eb0;
            margin-bottom: 12px;
            font-weight: 500;
        }

        .problem-title {
            font-size: 1.1rem;
            font-weight: 700;
            color: #fff;
            margin-bottom: 20px;
            line-height: 1.6;
        }

        .hints-section {
            margin-top: 24px;
            padding-top: 20px;
            border-top: 1px solid #3d4f5f;
        }

        .hints-toggle {
            display: flex;
            align-items: center;
            gap: 8px;
            width: 100%;
            padding: 10px 14px;
            background: rgba(255,217,61,0.1);
            border: 1px solid rgba(255,217,61,0.3);
            border-radius: 8px;
            color: #ffd93d;
            font-size: 0.85rem;
            cursor: pointer;
            transition: all 0.15s;
        }
        .hints-toggle:hover {
            background: rgba(255,217,61,0.15);
            border-color: rgba(255,217,61,0.5);
        }

        .hints-list {
            margin-top: 12px;
            padding: 0;
            list-style: none;
        }
        .hints-list li {
            color: #c5d1dc;
            font-size: 0.85rem;
            padding: 10px 14px;
            background: rgba(255,255,255,0.03);
            border-radius: 6px;
            margin-bottom: 8px;
            border-left: 3px solid #ffd93d;
            line-height: 1.5;
        }

        /* 오른쪽: 코드 + 출력 */
        .code-area {
            display: flex;
            flex-direction: column;
            background: #263747;
            overflow: hidden;
        }

        /* 코드 에디터 헤더 */
        .code-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 10px 16px;
            background: #1e2d3d;
            border-bottom: 1px solid #3d4f5f;
        }

        .file-tab {
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 6px 14px;
            background: #263747;
            border-radius: 6px 6px 0 0;
            border: 1px solid #3d4f5f;
            border-bottom: none;
            margin-bottom: -1px;
        }
        .file-tab span {
            font-family: 'JetBrains Mono', monospace;
            font-size: 0.8rem;
            color: #98d4ff;
        }

        /* 코드 편집 영역 */
        .code-editor {
            flex: 1;
            display: flex;
            overflow: hidden;
            min-height: 250px;
        }

        .line-numbers {
            padding: 16px 0;
            background: #1e2d3d;
            text-align: right;
            user-select: none;
            min-width: 50px;
            border-right: 1px solid #3d4f5f;
        }
        .line-numbers span {
            display: block;
            padding: 0 12px;
            font-family: 'JetBrains Mono', monospace;
            font-size: 0.9rem;
            line-height: 1.7;
            color: #5a6f7f;
        }

        .code-input-wrapper {
            flex: 1;
            overflow: auto;
        }

        .code-textarea {
            width: 100%;
            height: 100%;
            min-height: 200px;
            padding: 16px;
            background: transparent;
            border: none;
            color: #e8eaed;
            font-family: 'JetBrains Mono', monospace;
            font-size: 0.9rem;
            line-height: 1.7;
            resize: none;
            outline: none;
        }
        .code-textarea::placeholder {
            color: #5a6f7f;
        }

        /* 리사이저 */
        .resizer {
            height: 6px;
            background: #3d4f5f;
            cursor: row-resize;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .resizer::after {
            content: '';
            width: 40px;
            height: 3px;
            background: #5a7a8a;
            border-radius: 2px;
        }
        .resizer:hover {
            background: #4d6070;
        }

        /* 출력 영역 */
        .output-area {
            background: #1e2d3d;
            min-height: 120px;
            max-height: 200px;
            overflow-y: auto;
            display: flex;
            flex-direction: column;
        }

        .output-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 10px 16px;
            border-bottom: 1px solid #3d4f5f;
        }

        .output-label {
            font-size: 0.8rem;
            font-weight: 600;
            color: #98d4ff;
        }

        .output-clear {
            background: transparent;
            border: none;
            color: #5a6f7f;
            font-size: 0.75rem;
            cursor: pointer;
            padding: 4px 8px;
        }
        .output-clear:hover {
            color: #8b9eb0;
        }

        .output-content {
            flex: 1;
            padding: 12px 16px;
            font-family: 'JetBrains Mono', monospace;
            font-size: 0.85rem;
            color: #c5d1dc;
            line-height: 1.6;
        }

        .output-empty {
            color: #5a6f7f;
            font-style: italic;
        }

        .output-line {
            padding: 2px 0;
        }
        .output-line.log { color: #e8eaed; }
        .output-line.warn { color: #ffd93d; }
        .output-line.error { color: #ff6b6b; }

        .output-success {
            color: #3dffa2;
            display: flex;
            align-items: center;
            gap: 6px;
        }

        /* 하단 버튼 영역 */
        .footer {
            display: flex;
            justify-content: flex-end;
            align-items: center;
            gap: 10px;
            padding: 12px 20px;
            background: #1e2d3d;
            border-top: 1px solid #3d4f5f;
        }

        .btn {
            padding: 10px 20px;
            border-radius: 6px;
            font-size: 0.85rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.15s;
            display: inline-flex;
            align-items: center;
            gap: 6px;
        }

        .btn-reset {
            background: transparent;
            border: 1px solid #3d4f5f;
            color: #8b9eb0;
        }
        .btn-reset:hover {
            border-color: #5a7a8a;
            color: #c5d1dc;
        }

        .btn-run {
            background: #3d4f5f;
            border: 1px solid #5a7a8a;
            color: #fff;
        }
        .btn-run:hover {
            background: #4d6070;
        }
        .btn-run:disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }
        .btn-run.running {
            background: #ffd93d;
            color: #1e2d3d;
            border-color: #ffd93d;
        }

        .btn-submit {
            background: linear-gradient(180deg, #44d7b6 0%, #32c6a6 100%);
            border: none;
            color: #fff;
        }
        .btn-submit:hover {
            background: linear-gradient(180deg, #55e8c7 0%, #44d7b6 100%);
        }

        /* 스크롤바 */
        .problem-panel::-webkit-scrollbar,
        .output-area::-webkit-scrollbar,
        .code-input-wrapper::-webkit-scrollbar {
            width: 8px;
            height: 8px;
        }
        .problem-panel::-webkit-scrollbar-thumb,
        .output-area::-webkit-scrollbar-thumb,
        .code-input-wrapper::-webkit-scrollbar-thumb {
            background: #3d4f5f;
            border-radius: 4px;
        }
        .problem-panel::-webkit-scrollbar-track,
        .output-area::-webkit-scrollbar-track,
        .code-input-wrapper::-webkit-scrollbar-track {
            background: #1e2d3d;
        }
    `;

    @property({ type: String }) mission = '';
    @property({ type: String, attribute: 'initial-code' }) initialCode = '';
    @property({ type: Array }) hints: string[] = [];

    @state() private code = '';
    @state() private outputs: LuaOutput[] = [];
    @state() private isRunning = false;
    @state() private showHints = false;
    @state() private executionSuccess = false;
    @state() private error: string | null = null;
    @state() private lineCount = 1;

    connectedCallback() {
        super.connectedCallback();
        this.code = this.initialCode || this.textContent?.trim() || '';
        this.updateLineCount();
        initLuaEngine().catch(console.error);
    }

    private updateLineCount() {
        this.lineCount = Math.max(this.code.split('\n').length, 10);
    }

    private handleCodeChange(e: Event) {
        const textarea = e.target as HTMLTextAreaElement;
        this.code = textarea.value;
        this.updateLineCount();
    }

    private async runCode() {
        if (this.isRunning) return;

        this.isRunning = true;
        this.outputs = [];
        this.error = null;
        this.executionSuccess = false;

        try {
            const result = await executeLua(this.code);

            if (result.success) {
                this.outputs = result.outputs;
                this.executionSuccess = true;
            } else {
                this.error = result.error || '알 수 없는 오류';
                this.outputs = result.outputs;
            }
        } catch (err) {
            this.error = err instanceof Error ? err.message : '실행 오류';
        } finally {
            this.isRunning = false;
        }
    }

    private resetCode() {
        this.code = this.initialCode;
        this.outputs = [];
        this.error = null;
        this.executionSuccess = false;
        this.updateLineCount();
    }

    private clearOutput() {
        this.outputs = [];
        this.error = null;
        this.executionSuccess = false;
    }

    private toggleHints() {
        this.showHints = !this.showHints;
    }

    render() {
        const lineNumbers = Array.from({ length: this.lineCount }, (_, i) => i + 1);

        return html`
            <div class="editor-wrapper">
                <!-- 상단 헤더 -->
                <div class="editor-header">
                    <div class="header-title">Lua 실습</div>
                    <div class="header-controls">
                        <button class="theme-btn active">dark</button>
                        <span class="lang-badge">Lua</span>
                    </div>
                </div>

                <!-- 메인 영역 -->
                <div class="main-area">
                    <!-- 왼쪽: 미션 -->
                    <div class="problem-panel">
                        <div class="problem-label">🎯 미션</div>
                        <div class="problem-title">${this.mission}</div>

                        ${this.hints.length > 0 ? html`
                            <div class="hints-section">
                                <button class="hints-toggle" @click=${this.toggleHints}>
                                    <span>💡</span>
                                    ${this.showHints ? '힌트 숨기기' : '힌트 보기'}
                                </button>
                                ${this.showHints ? html`
                                    <ul class="hints-list">
                                        ${this.hints.map(hint => html`<li>${hint}</li>`)}
                                    </ul>
                                ` : ''}
                            </div>
                        ` : ''}
                    </div>

                    <!-- 오른쪽: 코드 + 출력 -->
                    <div class="code-area">
                        <!-- 코드 헤더 -->
                        <div class="code-header">
                            <div class="file-tab">
                                <span>script.lua</span>
                            </div>
                        </div>

                        <!-- 코드 편집 -->
                        <div class="code-editor">
                            <div class="line-numbers">
                                ${lineNumbers.map(n => html`<span>${n}</span>`)}
                            </div>
                            <div class="code-input-wrapper">
                                <textarea
                                    class="code-textarea"
                                    .value=${this.code}
                                    @input=${this.handleCodeChange}
                                    placeholder="-- 여기에 Lua 코드를 작성하세요"
                                    spellcheck="false"
                                ></textarea>
                            </div>
                        </div>

                        <!-- 리사이저 -->
                        <div class="resizer"></div>

                        <!-- 출력 영역 -->
                        <div class="output-area">
                            <div class="output-header">
                                <span class="output-label">실행 결과</span>
                                <button class="output-clear" @click=${this.clearOutput}>지우기</button>
                            </div>
                            <div class="output-content">
                                ${this.outputs.length === 0 && !this.error && !this.executionSuccess
                                    ? html`<div class="output-empty">실행 결과가 여기에 표시됩니다.</div>`
                                    : ''}

                                ${this.outputs.map(out => html`
                                    <div class="output-line ${out.type}">${out.message}</div>
                                `)}

                                ${this.error ? html`
                                    <div class="output-line error">❌ ${this.error}</div>
                                ` : ''}

                                ${this.executionSuccess && this.outputs.length === 0 && !this.error ? html`
                                    <div class="output-success">
                                        <span>✓</span> 실행 완료 (출력 없음)
                                    </div>
                                ` : ''}
                            </div>
                        </div>
                    </div>
                </div>

                <!-- 하단 버튼 -->
                <div class="footer">
                    <button class="btn btn-reset" @click=${this.resetCode}>초기화</button>
                    <button
                        class="btn btn-run ${this.isRunning ? 'running' : ''}"
                        @click=${this.runCode}
                        ?disabled=${this.isRunning}
                    >
                        ${this.isRunning ? '⏳ 실행 중...' : '▶ 코드 실행'}
                    </button>
                </div>
            </div>
        `;
    }
}

declare global {
    interface HTMLElementTagNameMap {
        'lua-editor': LuaEditor;
    }
}
