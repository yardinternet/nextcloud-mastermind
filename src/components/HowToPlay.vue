<template>
	<div class="how-to-play">
		<h2>{{ t('mastermind', 'How to play?') }}</h2>

		<p>
			{{ t('mastermind', 'Each day a new secret code of {length} colors is generated.', { length: CODE_LENGTH }) }}
			{{ t('mastermind', 'You have {attempts} attempts to guess it.', { attempts: MAX_ATTEMPTS }) }}
			{{ t('mastermind', 'After each guess, you get feedback about how close you were.') }}
		</p>

		<h3>{{ t('mastermind', 'The colors') }}</h3>
		<div class="color-palette">
			<div v-for="(color, i) in CHOICE_COLORS"
				:key="i"
				class="swatch"
				:style="`background: ${color}`" />
		</div>

		<h3>{{ t('mastermind', 'Feedback') }}</h3>
		<ul class="feedback-legend">
			<li>
				<span class="bullet bullet--correct" />
				<span><strong>{{ t('mastermind', 'Red bullet') }}</strong> — {{ t('mastermind', 'right color, right position') }}</span>
			</li>
			<li>
				<span class="bullet bullet--misplaced" />
				<span><strong>{{ t('mastermind', 'White bullet') }}</strong> — {{ t('mastermind', 'right color, wrong position') }}</span>
			</li>
			<li>
				<span class="bullet bullet--empty" />
				<span>{{ t('mastermind', 'No bullet') }} — {{ t('mastermind', 'color not in the solution') }}</span>
			</li>
		</ul>

		<h3>{{ t('mastermind', 'Example') }}</h3>
		<p>{{ t('mastermind', 'Suppose the secret code is:') }}</p>
		<div class="example-row">
			<div v-for="(digit, i) in exampleSolution"
				:key="'s' + i"
				class="cell"
				:style="`background: ${CHOICE_COLORS[digit]}`" />
		</div>
		<p>{{ t('mastermind', 'And you guess:') }}</p>
		<div class="example-row">
			<div v-for="(digit, i) in exampleGuess"
				:key="'g' + i"
				class="cell"
				:style="`background: ${CHOICE_COLORS[digit]}`" />
			<div class="feedback">
				<span v-for="k in exampleFeedback.correct" :key="'c' + k" class="bullet bullet--correct" />
				<span v-for="k in exampleFeedback.misplaced" :key="'m' + k" class="bullet bullet--misplaced" />
				<span v-for="k in (5 - exampleFeedback.correct - exampleFeedback.misplaced)" :key="'e' + k" class="bullet bullet--empty" />
			</div>
		</div>
		<p>
			{{ t('mastermind', 'You get {correct} red and {misplaced} white', {
				correct: exampleFeedback.correct,
				misplaced: exampleFeedback.misplaced,
			}) }}
		</p>
	</div>
</template>

<script setup lang="ts">
import { t } from '@nextcloud/l10n'
import { CHOICE_COLORS, MAX_ATTEMPTS, judgeGuess, CODE_LENGTH } from '../utils.ts'
import type { CHOICE_ID } from '../utils.ts'

const exampleSolution: CHOICE_ID[] = [0, 3, 4, 1, 5]
const exampleGuess: CHOICE_ID[] = [0, 4, 3, 2, 5]

const exampleFeedback = judgeGuess(exampleGuess, exampleSolution)
</script>

<style scoped lang="scss">
@use '../styles/game';

.how-to-play {
	max-width: 480px;
	margin: 0 auto;
	padding: 32px 24px;

	h2 {
		font-size: 24px;
		font-weight: 700;
		margin: 0 0 16px;
	}

	h3 {
		font-size: 16px;
		font-weight: 600;
		margin: 24px 0 10px;
	}

	p {
		line-height: 1.6;
		margin: 0 0 12px;
	}

	.color-palette {
		display: flex;
		gap: 8px;
		flex-wrap: wrap;
	}

	.swatch {
		width: 32px;
		height: 32px;
		border: 1px solid #c0c0c0;
		border-radius: 2px;
		box-shadow: 3px 3px 2px #e0e0e0;
	}

	.feedback-legend {
		list-style: none;
		padding: 0;
		margin: 0;
		display: flex;
		flex-direction: column;
		gap: 8px;

		li {
			display: flex;
			align-items: center;
			gap: 10px;
		}
	}

	.example-row {
		display: flex;
		align-items: center;
		gap: 8px;
		margin-bottom: 12px;
	}
}
</style>
