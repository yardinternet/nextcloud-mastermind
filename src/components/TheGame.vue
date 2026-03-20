<template>
	<div class="main-content">
		<h2>
			{{ title }}
		</h2>
		<template v-if="!failed">
			<div v-for="n in numPlaceholders" :key="'p' + n" class="attempt attempt--placeholder">
				<div v-for="m in CODE_LENGTH"
					:key="m"
					class="cell"
					:style="`background: ${CELL_COLORS[NO_CHOICE]}`" />
				<div class="feedback" />
			</div>
		</template>
		<div v-if="!solved && !failed" class="attempt attempt--current">
			<button v-for="(digit, index) in currentGuess"
				:key="index"
				class="cell"
				:style="`background: ${CELL_COLORS[digit]}`"
				@click="openPicker(index, $event)" />
			<div class="feedback" />
		</div>
		<div v-for="(attempt, i) in lockedAttempts" :key="'a' + i" class="attempt attempt--locked">
			<div v-for="(digit, j) in attempt.guess"
				:key="j"
				class="cell"
				:style="`background: ${CHOICE_COLORS[digit]}`" />
			<div class="feedback">
				<span v-for="k in attempt.correct" :key="'c' + k" class="bullet bullet--correct" />
				<span v-for="k in attempt.misplaced" :key="'m' + k" class="bullet bullet--misplaced" />
				<span v-for="k in (CODE_LENGTH - attempt.correct - attempt.misplaced)"
					:key="'e' + k"
					class="bullet bullet--empty" />
			</div>
		</div>
		<button v-if="!solved && !failed && canSubmit"
			class="submit-btn"
			@click="submitGuess">
			Submit guess
		</button>
		<div v-else-if="!solved && !failed" class="submit-btn submit-btn--placeholder" />
		<div v-if="pickerIndex !== null" class="color-picker" :style="pickerStyle">
			<button v-for="choice in CHOICES"
				:key="choice"
				class="cell"
				:style="`background: ${CHOICE_COLORS[choice]}`"
				@click="selectChoice(choice)">
				<span class="key-hint">{{ choice + 1 }}</span>
			</button>
		</div>
		<div v-if="pickerIndex !== null" class="picker-overlay" @click="closePicker" />

		<EndOfGameTransition
			:show="solved || failed"
			:success="solved"
			:solution="solution"
			:guess-count="lockedAttempts.length"
			@retry="retry"
			@previous="emit('previous')" />
	</div>
</template>

<script setup lang="ts">
import { computed, onMounted, onUnmounted, ref } from 'vue'
import {
	CELL_COLORS,
	CHOICE_COLORS,
	CHOICES,
	CODE_LENGTH,
	MAX_ATTEMPTS,
	NO_CHOICE,
	dateToCode,
	judgeGuess,
} from '../utils.ts'
import type { CHOICE_ID } from '../utils.ts'
import EndOfGameTransition from './EndOfGameTransition.vue'

const emit = defineEmits<{ previous: [] }>()

type LockedAttempt = {
	guess: CHOICE_ID[]
	correct: number
	misplaced: number
}

const lockedAttempts = ref<LockedAttempt[]>([])
const currentGuess = ref<(CHOICE_ID | typeof NO_CHOICE)[]>(Array(CODE_LENGTH).fill(NO_CHOICE))
const pickerIndex = ref<number | null>(null)
const pickerStyle = ref<string>('')
const solved = ref(false)
const failed = ref(false)

const numPlaceholders = computed(() => Math.max(MAX_ATTEMPTS - 1 - lockedAttempts.value.length, 0))
const canSubmit = computed(() => currentGuess.value.every(d => d !== NO_CHOICE))

const props = defineProps({
	date: {
		type: String,
		default: new Date().toISOString().slice(0, 10),
	},
	title: {
		type: String,
		default: '',
	},
})

const code = dateToCode(props.date)
const solution = code.split('').map(Number) as CHOICE_ID[]

function openPicker(index: number, event: MouseEvent) {
	const button = event.currentTarget as HTMLElement
	const container = button.closest('.main-content') as HTMLElement
	const buttonRect = button.getBoundingClientRect()
	const containerRect = container.getBoundingClientRect()

	const top = buttonRect.bottom - containerRect.top + 4
	let left = buttonRect.left - containerRect.left

	const pickerWidth = 168
	if (left + pickerWidth > containerRect.width) {
		left = containerRect.width - pickerWidth
	}

	pickerStyle.value = `top: ${top}px; left: ${left}px;`
	pickerIndex.value = index
}

function selectChoice(choice: CHOICE_ID) {
	if (pickerIndex.value !== null) {
		currentGuess.value[pickerIndex.value] = choice
	}
	pickerIndex.value = null
}

function closePicker() {
	pickerIndex.value = null
}

function onKeyDown(event: KeyboardEvent) {
	if (pickerIndex.value === null) return
	const num = parseInt(event.key)
	if (num >= 1 && num <= 8) {
		selectChoice((num - 1) as CHOICE_ID)
	}
}

onMounted(() => document.addEventListener('keydown', onKeyDown))
onUnmounted(() => document.removeEventListener('keydown', onKeyDown))

function retry() {
	lockedAttempts.value = []
	currentGuess.value = Array(CODE_LENGTH).fill(NO_CHOICE)
	failed.value = false
	solved.value = false
}

function submitGuess() {
	const guess = currentGuess.value as CHOICE_ID[]
	const { correct, misplaced } = judgeGuess(guess, solution)
	lockedAttempts.value.unshift({ guess: [...guess], correct, misplaced })
	currentGuess.value = Array(CODE_LENGTH).fill(NO_CHOICE)
	if (correct === CODE_LENGTH) {
		solved.value = true
	} else if (lockedAttempts.value.length === MAX_ATTEMPTS) {
		failed.value = true
	}
}
</script>

<style scoped lang="scss">
@use '../styles/game';

.main-content {
	position: relative;
	height: 100%;
	display: flex;
	flex-direction: column;
	align-items: center;
	justify-content: center;

	.attempt {
		display: flex;
		gap: 8px;
		align-items: center;
		border-radius: 4px;

		&--current {
			background: rgba(0, 130, 201, 0.08);
			outline: 1px solid rgba(0, 130, 201, 0.35);
			padding: 4px;

			.cell {
				cursor: pointer;
				box-shadow: inset 0 0 0 2px rgba(0, 130, 201, 0.6), 3px 3px 2px #e0e0e0;
				margin: 0;
			}

			margin: 4px 0;
		}

		&--placeholder {
			padding: 2px 4px;
		}
		&--locked {
			padding: 2px 4px;
		}
	}

	.submit-btn {
		padding: 4px 8px;
		cursor: pointer;
		border: 1px solid #c0c0c0;
		border-radius: 2px;
		background: #f0f0f0;

		&--placeholder {
			cursor: default;
			background: transparent;
			border-color: transparent;
		}
	}

	.color-picker {
		position: absolute;
		z-index: 10;
		display: grid;
		grid-template-columns: repeat(4, 32px);
		gap: 8px;
		padding: 8px;
		background: white;
		border: 1px solid #c0c0c0;
		box-shadow: 2px 4px 8px rgba(0, 0, 0, 0.15);
		border-radius: 4px;

		.cell {
			position: relative;
		}

		.key-hint {
			position: absolute;
			bottom: 2px;
			right: 3px;
			font-size: 9px;
			font-weight: 700;
			line-height: 1;
			color: white;
			text-shadow: 0 0 3px rgba(0, 0, 0, 0.9);
			pointer-events: none;
		}
	}

	.picker-overlay {
		position: fixed;
		inset: 0;
		z-index: 9;
	}

}
</style>
