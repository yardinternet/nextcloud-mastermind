<template>
	<NcContent app-name="mastermind">
		<NcAppNavigation>
			<NcAppNavigationList>
				<NcAppNavigationItem :name="t('mastermind', 'How to play?')"
					:active="currentView === 'howtoplay'"
					@click="currentView = 'howtoplay'" />
				<NcAppNavigationCaption :name="t('mastermind', 'Puzzles')" />
				<NcAppNavigationItem v-for="entry in navEntries"
					:key="entry.date"
					:name="entry.label"
					:active="currentView === 'game' && selectedDate === entry.date"
					@click="selectDate(entry.date)" />
			</NcAppNavigationList>
			<template #footer>
				<div class="date-picker-section">
					<NcDateTimePickerNative v-model="pickerDate"
						type="date"
						:label="t('mastermind', 'Pick a date')"
						:max="new Date()" />
				</div>
			</template>
		</NcAppNavigation>
		<NcAppContent>
			<HowToPlay v-if="currentView === 'howtoplay'" />
			<div v-else-if="isFuture" class="future-notice">
				<p>{{ t('mastermind', 'The puzzle for {date} is not available yet.', { date: formatDate(selectedDate) }) }}</p>
			</div>
			<TheGame v-else
				:key="selectedDate"
				:date="selectedDate"
				:title="selectedTitle"
				@previous="goToPreviousDay" />
		</NcAppContent>
	</NcContent>
</template>

<script setup lang="ts">
import { t } from '@nextcloud/l10n'
import NcAppContent from '@nextcloud/vue/components/NcAppContent'
import NcAppNavigation from '@nextcloud/vue/components/NcAppNavigation'
import NcAppNavigationCaption from '@nextcloud/vue/components/NcAppNavigationCaption'
import NcAppNavigationItem from '@nextcloud/vue/components/NcAppNavigationItem'
import NcAppNavigationList from '@nextcloud/vue/components/NcAppNavigationList'
import NcContent from '@nextcloud/vue/components/NcContent'
import NcDateTimePickerNative from '@nextcloud/vue/components/NcDateTimePickerNative'
import { computed, ref } from 'vue'

import HowToPlay from './components/HowToPlay.vue'
import TheGame from './components/TheGame.vue'
import { formatDate, toDateString } from './utils.ts'

const VISITED_KEY = 'mastermind.hasVisited'

const today = toDateString(new Date())

const navEntries = Array.from({ length: 10 }, (_, i) => {
	const date = toDateString(new Date(Date.now() - i * 86_400_000))
	const label = i === 0
		? t('mastermind', "Today's puzzle")
		: i === 1
			? t('mastermind', "Yesterday's puzzle")
			: t('mastermind', 'Puzzle of {date}', { date: formatDate(date) })
	return { date, label }
})

const hasVisited = localStorage.getItem(VISITED_KEY) === 'true'
const currentView = ref<'game' | 'howtoplay'>(hasVisited ? 'game' : 'howtoplay')
const selectedDate = ref(today)

if (!hasVisited) {
	localStorage.setItem(VISITED_KEY, 'true')
}

const selectedTitle = computed(() => {
	const entry = navEntries.find(e => e.date === selectedDate.value)
	return entry ? entry.label : t('mastermind', 'Puzzle of {date}', { date: formatDate(selectedDate.value) })
})

function selectDate(date: string) {
	selectedDate.value = date
	currentView.value = 'game'
}

function goToPreviousDay() {
	const d = new Date(selectedDate.value + 'T12:00:00')
	d.setDate(d.getDate() - 1)
	selectedDate.value = toDateString(d)
	currentView.value = 'game'
}

const isFuture = computed(() => selectedDate.value > today)

const pickerDate = computed({
	get: () => new Date(selectedDate.value + 'T12:00:00'),
	set: (d: Date | null) => {
		if (d) {
			selectDate(toDateString(d))
		}
	},
})
</script>

<style scoped lang="scss">
.date-picker-section {
	padding: 8px 16px 16px;
}

.future-notice {
	height: 100%;
	display: flex;
	align-items: center;
	justify-content: center;
	color: var(--color-text-maxcontrast);
	font-size: 1.1em;
}
</style>
