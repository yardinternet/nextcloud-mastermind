<template>
	<Transition name="game-end">
		<div v-if="show" :class="`game-end ${success ? 'game-end--success' : 'game-end--failure'}`">
			<template v-if="success">
				<div v-for="(piece, i) in confettiPieces"
					:key="i"
					class="confetti"
					:style="`left:${piece.left}%; animation-delay:${piece.delay}s; animation-duration:${piece.duration}s; background:${piece.color}; width:${piece.size}px; height:${piece.size}px;`" />
			</template>
			<div class="game-end__card">
				<div class="game-end__emoji">
					{{ success ? '🎉' : '😞' }}
				</div>
				<h2 class="game-end__title">
					{{ success ? 'You solved it!' : 'Better luck next time' }}
				</h2>
				<p class="game-end__subtitle">
					{{ success ? `Solved in ${guessCount} ${guessCount === 1 ? 'guess' : 'guesses'}` : 'The solution was:' }}
				</p>
				<div class="game-end__solution-row">
					<div v-for="(digit, i) in solution"
						:key="i"
						class="cell"
						:style="`background: ${CHOICE_COLORS[digit]}`" />
				</div>
				<div class="game-end__card-actions">
					<button type="button" @click="emit('retry')">
						Try again
					</button>
					<button type="button" @click="emit('previous')">
						Previous puzzle
					</button>
				</div>
			</div>
		</div>
	</Transition>
</template>

<script setup lang="ts">
import type { PropType } from 'vue'
import { CHOICE_COLORS } from '../utils.ts'
import type { CHOICE_ID } from '../utils.ts'

const emit = defineEmits<{ retry: [], previous: [] }>()

const confettiColors = Object.values(CHOICE_COLORS)
const confettiPieces = Array.from({ length: 36 }, (_, i) => ({
	left: (i * 2.78 + (i % 7) * 5.3) % 100,
	delay: (i * 0.13) % 2,
	duration: 2 + (i * 0.19) % 1.5,
	color: confettiColors[i % confettiColors.length],
	size: 7 + (i * 3) % 9,
}))

defineProps({
	show: {
		type: Boolean,
		default: false,
	},
	success: {
		type: Boolean,
		default: false,
	},
	solution: {
		type: Array as PropType<CHOICE_ID[]>,
		required: true,
	},
	guessCount: {
		type: Number,
		default: 0,
	},
})
</script>

<style scoped lang="scss">
@use '../styles/game';

.game-end {
	position: fixed;
	inset: 0;
	z-index: 100;
	display: flex;
	align-items: center;
	justify-content: center;
	background: rgba(255, 255, 255, 0.75);
	backdrop-filter: blur(3px);
	overflow: hidden;

	&--failure {
		background: rgba(0, 0, 0, 0.55);
	}

	.game-end__card {
		position: relative;
		z-index: 1;
		text-align: center;
		background: white;
		border-radius: 16px;
		padding: 40px 56px;
		box-shadow: 0 8px 40px rgba(0, 0, 0, 0.18);
	}

	.game-end__emoji {
		font-size: 56px;
		line-height: 1;
		margin-bottom: 16px;
	}

	.game-end__title {
		font-size: 28px;
		font-weight: 700;
		margin: 0 0 8px;
		color: #1a1a1a;
	}

	.game-end__subtitle {
		font-size: 16px;
		color: #606060;
		margin: 0 0 20px;
	}

	.game-end__solution-row {
		display: flex;
		justify-content: center;
		gap: 8px;
		margin-bottom: 20px;
	}

	.game-end__card-actions {
		display: flex;
		justify-content: center;
		gap: 8px;

		button {
			padding: 8px 16px;
			cursor: pointer;
			border: 1px solid #c0c0c0;
			border-radius: 6px;
			background: #f0f0f0;
			font-size: 14px;

			&:hover {
				background: #e0e0e0;
			}
		}
	}
}

@keyframes confetti-fall {
	0%   { transform: translateY(-20px) rotate(0deg);   opacity: 1; }
	85%  { opacity: 1; }
	100% { transform: translateY(105vh) rotate(600deg); opacity: 0; }
}

.confetti {
	position: fixed;
	top: 0;
	border-radius: 2px;
	animation: confetti-fall linear infinite;
	pointer-events: none;
}

@keyframes card-pop {
	from { transform: scale(0.75); opacity: 0; }
	to   { transform: scale(1);    opacity: 1; }
}

.game-end-enter-active {
	transition: opacity 0.4s ease;

	.game-end__card {
		animation: card-pop 0.5s 0.15s both cubic-bezier(0.34, 1.56, 0.64, 1);
	}
}

.game-end-enter-from {
	opacity: 0;
}
</style>
