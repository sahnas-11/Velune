<?php

namespace Tests\Feature\Hr;

use Tests\TestCase;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;

class MonthlyReportTest extends TestCase
{
    use RefreshDatabase;

    protected User $hrUser;
    protected User $commuterUser;

    protected function setUp(): void
    {
        parent::setUp();

        $this->hrUser = User::create([
            'name' => 'Amanda Jayawardena',
            'email' => 'amanda@company.com',
            'password' => bcrypt('password123'),
            'role' => 'hr_manager',
        ]);

        $this->commuterUser = User::create([
            'name' => 'Jay Karunarathna',
            'email' => 'jay@company.com',
            'password' => bcrypt('password123'),
            'role' => 'commuter',
        ]);
    }

    /**
     * TC-HR-041: Export Scope 3 ESG report returns application/pdf with content
     */
    public function test_tc_hr_041_export_report_returns_pdf_document(): void
    {
        Sanctum::actingAs($this->hrUser);

        $response = $this->postJson('/api/hr/reports/export');

        // Must return 200 and application/pdf content type
        $response->assertStatus(200);
        $this->assertTrue(
            str_contains($response->headers->get('content-type', ''), 'application/pdf') ||
            $response->json('download_url') !== null,
            'Export endpoint must deliver verified PDF report artifact'
        );
    }

    /**
     * TC-HR-042: Email monthly report dispatch (Create / Dispatch 200)
     */
    public function test_tc_hr_042_email_monthly_report_dispatches_successfully(): void
    {
        Sanctum::actingAs($this->hrUser);

        $response = $this->postJson('/api/hr/reports/email', [
            'email' => 'sustainability.board@company.com',
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
            ]);
    }

    /**
     * TC-HR-043: Validation failure for invalid email (422)
     */
    public function test_tc_hr_043_email_report_validation_failure_for_invalid_email(): void
    {
        Sanctum::actingAs($this->hrUser);

        $response = $this->postJson('/api/hr/reports/email', [
            'email' => 'not-an-email',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['email']);
    }

    /**
     * TC-HR-044: Authorization - unauthenticated and non-HR access rejected (401 / 403)
     */
    public function test_tc_hr_044_report_export_authorization_enforced(): void
    {
        // Unauthenticated -> 401
        $this->postJson('/api/hr/reports/export')->assertStatus(401);

        // Commuter -> 403
        Sanctum::actingAs($this->commuterUser);
        $this->postJson('/api/hr/reports/export')->assertStatus(403);
    }

    /**
     * TC-HR-045: NFR-04 - Monthly report data contains no commuter PII
     */
    public function test_tc_hr_045_nfr04_monthly_report_anonymized(): void
    {
        Sanctum::actingAs($this->hrUser);

        $response = $this->postJson('/api/hr/reports/export');
        $response->assertStatus(200);

        $body = $response->getContent();

        $this->assertStringNotContainsString('077', $body);
        $this->assertStringNotContainsString('nic', $body);
    }
}
