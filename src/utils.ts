import { getCanonicalLocale } from '@nextcloud/l10n'

export function toDateString(d: Date): string {
	return d.toISOString().slice(0, 10)
}

const dateFormatter = new Intl.DateTimeFormat(getCanonicalLocale(), { dateStyle: 'long' })

export function formatDate(dateString: string): string {
	return dateFormatter.format(new Date(dateString + 'T12:00:00'))
}

export const CODE_LENGTH = 5
export const MAX_ATTEMPTS = 12

export type CHOICE_ID = 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7;
export const NO_CHOICE = 9

export const CHOICE_COLORS: Record<CHOICE_ID, string> = {
	0: '#f04040',
	1: '#ff8040',
	2: '#ffff40',
	3: '#40ff40',
	4: '#4080ff',
	5: '#c080c0',
	6: '#404040',
	7: '#e0e0e0',
}
export const CELL_COLORS: Record<CHOICE_ID | typeof NO_CHOICE, string> = {
	...CHOICE_COLORS,
	9: '#ffffff',
}

export const CHOICES = [0, 1, 2, 3, 4, 5, 6, 7] as const

export function judgeGuess(guess: CHOICE_ID[], solution: CHOICE_ID[]): { correct: number, misplaced: number } {
	let correct = 0
	const guessRem: CHOICE_ID[] = []
	const solRem: CHOICE_ID[] = []

	for (let i = 0; i < solution.length; i++) {
		if (guess[i] === solution[i]) {
			correct++
		} else {
			guessRem.push(guess[i])
			solRem.push(solution[i])
		}
	}

	let misplaced = 0
	for (const color of guessRem) {
		const idx = solRem.indexOf(color)
		if (idx !== -1) {
			misplaced++
			solRem.splice(idx, 1)
		}
	}

	return { correct, misplaced }
}

export const dateToCode = (date: string): string => {
	// days since Unix epoch (UTC)
	let n = Math.floor(Date.parse(date) / 86_400_000)

	// integer hash so that sequential days produce codes that don't look similar
	n = Math.imul(n ^ (n >>> 16), 0x45d9f3b)
	n = Math.imul(n ^ (n >>> 16), 0x45d9f3b)
	n = (n ^ (n >>> 16)) >>> 0

	// pull out 5 groups of 3 bits, each digit is 0–7
	return Array.from({ length: 5 }, (_, i) => (n >>> (i * 3)) & 7).join('')
}
