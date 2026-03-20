<?php

declare(strict_types=1);

use OCP\Util;

$appId = OCA\Mastermind\AppInfo\Application::APP_ID;

Util::addScript($appId, $appId . '-main');
?>

<div id="mastermind"></div>
