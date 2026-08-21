<?php

declare(strict_types=1);

namespace Controller;

use OCA\Mastermind\AppInfo\Application;
use OCA\Mastermind\Controller\PageController;
use OCP\IRequest;
use PHPUnit\Framework\TestCase;

final class PageTest extends TestCase {
	public function testIndex(): void {
		$request = $this->createMock(IRequest::class);
		$controller = new PageController(Application::APP_ID, $request);

		$response = $controller->index();

		$this->assertEquals(Application::APP_ID, $response->getApp());
		$this->assertEquals('index', $response->getTemplateName());
	}
}
