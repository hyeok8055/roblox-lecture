import { LitElement, html, css } from 'lit';
import { customElement, property, state } from 'lit/decorators.js';

/**
 * 퀴즈 컴포넌트
 *
 * @example
 * <quiz-question
 *   question="print()의 역할은?"
 *   correct="B"
 *   options='["화면에 그림 그리기", "콘솔에 출력", "변수 생성", "아무것도 안함"]'
 *   correct-explanation="print()는 콘솔에 출력합니다"
 *   wrong-explanation="다시 생각해보세요"
 * ></quiz-question>
 */
@customElement('quiz-question')
export class QuizQuestion extends LitElement {
    static styles = css`
        :host {
            display: block;
            font-family: 'Pretendard', sans-serif;
        }

        .quiz-container {
            background: white;
            border-radius: 16px;
            padding: 20px;
            box-shadow: 0 2px 4px rgba(26,22,37,0.04), 0 4px 8px rgba(26,22,37,0.06), 0 8px 16px rgba(26,22,37,0.06);
        }

        .question {
            font-family: 'Space Grotesk', sans-serif;
            font-size: 1.15rem;
            font-weight: 700;
            margin-bottom: 1rem;
            color: #1a1625;
        }

        .options {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 8px;
        }

        @media (max-width: 480px) {
            .options {
                grid-template-columns: 1fr;
            }
        }

        .option {
            background: white;
            border: 2px solid #f8f6f4;
            border-radius: 12px;
            padding: 10px 14px;
            cursor: pointer;
            position: relative;
            overflow: hidden;
            transition: all 0.25s cubic-bezier(0.16, 1, 0.3, 1);
            box-shadow: 0 1px 2px rgba(26,22,37,0.04), 0 2px 4px rgba(26,22,37,0.04);
            text-align: left;
            width: 100%;
            font-family: inherit;
            font-size: 0.9rem;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .option::before {
            content: '';
            position: absolute;
            left: 0;
            top: 0;
            bottom: 0;
            width: 4px;
            background: #3d3654;
            transition: all 0.15s;
        }

        .option:hover:not(:disabled):not(.correct):not(.wrong) {
            border-color: #6BCFFF;
            transform: translateX(4px);
            box-shadow: 0 2px 4px rgba(26,22,37,0.04), 0 4px 8px rgba(26,22,37,0.06), 0 8px 16px rgba(26,22,37,0.06);
        }
        .option:hover:not(:disabled):not(.correct):not(.wrong)::before {
            width: 6px;
            background: #6BCFFF;
        }

        .option:disabled {
            cursor: not-allowed;
            opacity: 0.8;
        }

        .option.correct {
            border-color: #3DFFA2;
            background: rgba(61,255,162,0.08);
            animation: celebrate 0.5s cubic-bezier(0.34, 1.56, 0.64, 1);
        }
        .option.correct::before {
            width: 6px;
            background: #3DFFA2;
        }

        .option.wrong {
            border-color: #FF6B6B;
            background: rgba(255,107,107,0.08);
            animation: shake 0.4s ease-out;
        }
        .option.wrong::before {
            width: 6px;
            background: #FF6B6B;
        }

        .option-label {
            font-weight: 700;
            color: #3d3654;
            min-width: 24px;
        }

        .option-text {
            flex: 1;
        }

        .option-icon {
            width: 24px;
            height: 24px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 14px;
        }
        .option.correct .option-icon {
            background: #3DFFA2;
            color: #1a1625;
        }
        .option.wrong .option-icon {
            background: #FF6B6B;
            color: white;
        }

        .result {
            margin-top: 0.75rem;
            padding: 0.65rem 1rem;
            border-radius: 10px;
            font-size: 0.85rem;
            animation: slideUp 0.3s ease-out;
        }

        .result.success {
            background: linear-gradient(135deg, #D1FAE5 0%, #A7F3D0 100%);
            border: 1px solid #6EE7B7;
            color: #065F46;
        }

        .result.error {
            background: linear-gradient(135deg, #FEE2E2 0%, #FECACA 100%);
            border: 1px solid #FCA5A5;
            color: #991B1B;
        }

        .retry-btn {
            margin-top: 0.5rem;
            background: white;
            color: #1a1625;
            font-family: 'Space Grotesk', sans-serif;
            font-weight: 600;
            padding: 8px 16px;
            border-radius: 8px;
            border: 2px solid #f8f6f4;
            cursor: pointer;
            font-size: 0.85rem;
            transition: all 0.15s;
        }
        .retry-btn:hover {
            border-color: #6BCFFF;
            transform: translateY(-2px);
        }

        @keyframes celebrate {
            0% { transform: scale(1); }
            25% { transform: scale(1.02) rotate(-1deg); }
            50% { transform: scale(1.04) rotate(1deg); }
            75% { transform: scale(1.02) rotate(-0.5deg); }
            100% { transform: scale(1); }
        }

        @keyframes shake {
            0%, 100% { transform: translateX(0); }
            25% { transform: translateX(-8px); }
            75% { transform: translateX(8px); }
        }

        @keyframes slideUp {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }
    `;

    @property({ type: String }) question = '';
    @property({ type: String }) correct = 'A';
    @property({ type: Array }) options: string[] = [];
    @property({ type: String, attribute: 'correct-explanation' }) correctExplanation = '';
    @property({ type: String, attribute: 'wrong-explanation' }) wrongExplanation = '';

    @state() private selectedAnswer: string | null = null;
    @state() private isCorrect: boolean | null = null;
    @state() private answered = false;

    private labels = ['A', 'B', 'C', 'D'];

    private handleSelect(label: string) {
        if (this.answered) return;

        this.selectedAnswer = label;
        this.isCorrect = label === this.correct;
        this.answered = true;

        this.dispatchEvent(new CustomEvent('answer', {
            detail: { selected: label, correct: this.isCorrect },
            bubbles: true,
            composed: true
        }));
    }

    private retry() {
        this.selectedAnswer = null;
        this.isCorrect = null;
        this.answered = false;
    }

    render() {
        return html`
            <div class="quiz-container">
                <div class="question">${this.question}</div>
                <div class="options">
                    ${this.options.map((option, i) => {
                        const label = this.labels[i];
                        const isSelected = this.selectedAnswer === label;
                        const isCorrectAnswer = label === this.correct;

                        let className = 'option';
                        if (this.answered) {
                            if (isSelected && this.isCorrect) className += ' correct';
                            else if (isSelected && !this.isCorrect) className += ' wrong';
                            else if (isCorrectAnswer && !this.isCorrect) className += ' correct';
                        }

                        return html`
                            <button
                                class=${className}
                                ?disabled=${this.answered}
                                @click=${() => this.handleSelect(label)}
                            >
                                <span class="option-label">${label}.</span>
                                <span class="option-text">${option}</span>
                                ${this.answered && (isSelected || (isCorrectAnswer && !this.isCorrect)) ? html`
                                    <span class="option-icon">
                                        ${isCorrectAnswer ? '✓' : '✗'}
                                    </span>
                                ` : ''}
                            </button>
                        `;
                    })}
                </div>

                ${this.answered ? html`
                    <div class="result ${this.isCorrect ? 'success' : 'error'}">
                        ${this.isCorrect ? this.correctExplanation : this.wrongExplanation}
                    </div>
                    ${!this.isCorrect ? html`
                        <button class="retry-btn" @click=${this.retry}>다시 도전</button>
                    ` : ''}
                ` : ''}
            </div>
        `;
    }
}

declare global {
    interface HTMLElementTagNameMap {
        'quiz-question': QuizQuestion;
    }
}
