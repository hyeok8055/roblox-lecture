import { LitElement, html, css } from 'lit';
import { customElement, property, state } from 'lit/decorators.js';
import { unsafeHTML } from 'lit/directives/unsafe-html.js';

/**
 * 읽기 전용 Lua 코드 블록 컴포넌트
 *
 * @example
 * <lua-code-block title="example.lua" show-line-numbers>
 * local part = script.Parent
 * part.BrickColor = BrickColor.new("Bright red")
 * </lua-code-block>
 */
@customElement('lua-code-block')
export class LuaCodeBlock extends LitElement {
    static styles = css`
        :host {
            display: block;
            font-family: 'JetBrains Mono', monospace;
        }

        .code-block {
            background: var(--ink-deep, #1a1625);
            color: #E8E6E3;
            font-size: 0.85rem;
            line-height: 1.6;
            border-radius: 16px;
            padding: 48px 16px 16px;
            position: relative;
            overflow: hidden;
            max-width: 100%;
        }

        /* 터미널 윈도우 버튼 */
        .code-block::before {
            content: '';
            position: absolute;
            top: 16px;
            left: 20px;
            width: 12px;
            height: 12px;
            background: #FF6B6B;
            border-radius: 50%;
            box-shadow: 20px 0 0 #FFD93D, 40px 0 0 #3DFFA2;
        }

        .header {
            position: absolute;
            top: 12px;
            left: 80px;
            right: 60px;
            font-size: 0.8rem;
            color: #9CA3AF;
            font-weight: 500;
        }

        .copy-btn {
            position: absolute;
            top: 12px;
            right: 16px;
            background: transparent;
            border: 1px solid rgba(255,255,255,0.2);
            color: #9CA3AF;
            padding: 4px 10px;
            border-radius: 6px;
            cursor: pointer;
            font-size: 0.75rem;
            font-family: inherit;
            transition: all 0.15s;
        }
        .copy-btn:hover {
            background: rgba(255,255,255,0.1);
            color: white;
        }
        .copy-btn.copied {
            background: #3DFFA2;
            color: #1a1625;
            border-color: #3DFFA2;
        }

        .code-content {
            display: flex;
        }

        .line-numbers {
            padding-right: 16px;
            margin-right: 16px;
            border-right: 1px solid rgba(255,255,255,0.1);
            text-align: right;
            color: #676E95;
            user-select: none;
            font-size: 0.85rem;
        }
        .line-numbers span {
            display: block;
            line-height: 1.7;
        }

        .code-lines {
            flex: 1;
            min-width: 0;
            overflow-x: hidden;
        }

        .code-line {
            line-height: 1.7;
            white-space: pre-wrap;
            word-break: break-word;
        }

        /* Lua 구문 강조 */
        .lua-keyword { color: #C792EA; }
        .lua-builtin { color: #82AAFF; }
        .lua-roblox { color: #89DDFF; }
        .lua-string { color: #C3E88D; }
        .lua-number { color: #F78C6C; }
        .lua-comment { color: #676E95; font-style: italic; }
        .lua-function { color: #FFCB6B; }
        .lua-property { color: #F07178; }
        .lua-operator { color: #89DDFF; }
    `;

    @property({ type: String }) title = '';
    @property({ type: Boolean, attribute: 'show-line-numbers' }) showLineNumbers = false;
    @state() private copied = false;
    @state() private code = '';

    connectedCallback() {
        super.connectedCallback();
        // slot에서 코드 가져오기
        this.code = this.textContent?.trim() || '';
    }

    private highlightCode(code: string): string {
        // 순서 중요: 먼저 특수 패턴을 처리하고, 나중에 일반 패턴 처리
        let highlighted = code
            // HTML 이스케이프
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
            .replace(/\b(print|warn|wait|require|pairs|ipairs|type|tostring|tonumber|error|pcall|xpcall|select|unpack|setmetatable|getmetatable|rawget|rawset|next|assert|collectgarbage|loadstring|spawn|delay|tick|time|typeof)\b/g,
                '<span class="lua-builtin">$1</span>')
            // 속성 접근
            .replace(/\.([A-Za-z_][A-Za-z0-9_]*)/g, '.<span class="lua-property">$1</span>')
            // 함수 호출
            .replace(/\b([A-Za-z_][A-Za-z0-9_]*)\s*(?=\()/g, '<span class="lua-function">$1</span>');

        return highlighted;
    }

    private async copyCode() {
        try {
            await navigator.clipboard.writeText(this.code);
            this.copied = true;
            setTimeout(() => { this.copied = false; }, 2000);
        } catch (err) {
            console.error('복사 실패:', err);
        }
    }

    render() {
        const lines = this.code.split('\n');
        const highlightedLines = lines.map(line => this.highlightCode(line));

        return html`
            <div class="code-block">
                ${this.title ? html`<div class="header">${this.title}</div>` : ''}
                <button class="copy-btn ${this.copied ? 'copied' : ''}" @click=${this.copyCode}>
                    ${this.copied ? '복사됨!' : '복사'}
                </button>
                <div class="code-content">
                    ${this.showLineNumbers ? html`
                        <div class="line-numbers">
                            ${lines.map((_, i) => html`<span>${i + 1}</span>`)}
                        </div>
                    ` : ''}
                    <div class="code-lines">
                        ${highlightedLines.map(line => html`
                            <div class="code-line">${unsafeHTML(line || '&nbsp;')}</div>
                        `)}
                    </div>
                </div>
            </div>
        `;
    }
}

declare global {
    interface HTMLElementTagNameMap {
        'lua-code-block': LuaCodeBlock;
    }
}
