<?php

declare(strict_types=1);

use OCP\Util;

Util::addScript(OCA\Mastermind\AppInfo\Application::APP_ID, OCA\Mastermind\AppInfo\Application::APP_ID . '-main');
Util::addStyle(OCA\Mastermind\AppInfo\Application::APP_ID, OCA\Mastermind\AppInfo\Application::APP_ID . '-main');

?>

<div id="mastermind"></div>
