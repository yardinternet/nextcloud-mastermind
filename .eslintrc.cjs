module.exports = {
	extends: [
		'@nextcloud',
	],
	overrides: [
		{
			files: ['**/*.vue'],
			parserOptions: {
				parser: '@typescript-eslint/parser',
			},
		},
	],
	rules: {
		'jsdoc/require-jsdoc': 'off',
		'vue/first-attribute-linebreak': 'off',
	},
}
