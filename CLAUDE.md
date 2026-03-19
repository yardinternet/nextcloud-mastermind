# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Nextcloud app called **Mastermind** — a code-breaking game. It uses a PHP backend (Nextcloud OCP AppFramework) and a Vue 3 + TypeScript frontend built with Vite.

- **Nextcloud compatibility:** NC 33–34
- **PHP:** 8.1+, namespace `OCA\Mastermind`
- **Node:** v20 (see `.nvmrc`), npm 11.3+

## Commands

### Frontend

```bash
npm run build       # Production build
npm run dev         # Development build
npm run watch       # Watch mode
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

## Architecture

### Backend (`lib/`)

- `AppInfo/Application.php` — App bootstrap, implements `IBootstrap`
- `Controller/PageController.php` — Renders the main SPA template via `FrontpageRoute`
- `Controller/ApiController.php` — OCS API controller

### Frontend (`src/`)

- `main.ts` — Vue 3 app entry point, mounts to `#mastermind` DOM element
- `App.vue` — Root component

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
- OpenAPI spec is generated via `composer openapi` (`generate-spec`)
