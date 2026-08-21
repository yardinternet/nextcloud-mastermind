# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Nextcloud app called **Mastermind** — a code-breaking game. It uses a PHP backend (Nextcloud OCP AppFramework) and a Vue 3 + TypeScript frontend built with Vite.

- **Nextcloud compatibility:** NC 33–35
- **PHP:** 8.1+, namespace `OCA\Mastermind`
- **Node:** v20 (see `.nvmrc`), npm 11.3+

## Commands

### Frontend

```bash
npm run build       # Production build
npm run dev         # One-shot development build (no dev server / HMR)
npm run watch       # Iterative dev: rebuilds on change
npm run lint        # ESLint
npm run stylelint   # CSS/SCSS linting
```

### Backend (PHP)

```bash
composer lint         # PHP syntax check
composer cs:check     # Dry-run code style check
composer cs:fix       # Fix code style
composer psalm        # Static analysis
composer test:unit    # Run PHPUnit tests
composer rector       # Modernize code + fix style
```

### Running a single test

```bash
./vendor/bin/phpunit tests -c tests/phpunit.xml --filter <TestName>
```

### Release

`release.sh` builds a signed App Store tarball from a clean `git archive` of
HEAD (uncommitted changes are ignored). It runs `npm ci && npm run build`,
then `composer install --no-dev`, and signs with
`$NEXTCLOUD_APP_KEY` (default `~/.nextcloud/certificates/mastermind.key`).
Output lands in `dist/`. Bump the version in `appinfo/info.xml` before running.

## Architecture

### Backend (`lib/`)

- `AppInfo/Application.php` — App bootstrap, implements `IBootstrap`
- `Controller/PageController.php` — Sole controller; renders the SPA template via `FrontpageRoute` at `/`
- `appinfo/info.xml` — Authoritative source for app version and Nextcloud min/max compatibility

### Frontend (`src/`)

- `main.ts` — Vue 3 app entry; mounts to `#mastermind`
- `App.vue` — Root component
- `components/` — `TheGame.vue`, `HowToPlay.vue`, `EndOfGameTransition.vue`
- `styles/_game.scss` — Shared game styles

### Templates (`templates/`)

- `index.php` — Loads compiled JS/CSS and provides the `#mastermind` mount point

### Tests (`tests/`)

- PHPUnit config: `tests/phpunit.xml`
- Bootstrap: `tests/bootstrap.php`
- Unit tests under `tests/unit/`

## Key Conventions

- Conventional commits are enforced by CI (`block-unconventional-commits` workflow)
- PHP code style follows `nextcloud/coding-standard` via PHP CS Fixer
- TypeScript/Vue follows `@nextcloud/eslint-config`
