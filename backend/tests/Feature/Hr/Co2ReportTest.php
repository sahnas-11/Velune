<?php

namespace Tests\Feature\Hr;

use Tests\TestCase;
use App\Models\User;
use App\Models\HrCo2Log;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;

class Co2ReportTest extends TestCase
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
     * TC-HR-011: Read CO2 reduction logs list (Read 200)
     */
    public function test_tc_hr_011_read_co2_logs_returns_list_of_records(): void
    {
        HrCo2Log::create([
            'employee_name' => 'Department Vanpool Alpha',
            'route_name' => 'Kottawa - Colombo HQ',
            'co2_avoided_kg' => 84.50,
            'log_date' => '2026-10-01',
        ]);

        Sanctum::actingAs($this->hrUser);

        $response = $this->getJson('/api/hr/co2-logs');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'data' => [
                    '*' => [
                        'id',
                        'employee_name',
                        'route_name',
                        'co2_avoided_kg',
                        'log_date',
                    ],
                ],
            ]);
    }

    /**
     * TC-HR-012: Create new Scope 3 CO2 log (Create 201)
     */
    public function test_tc_hr_012_create_co2_log_persists_row_in_database(): void
    {
        Sanctum::actingAs($this->hrUser);

        $payload = [
            'employee_name' => 'Malabe Carpool Cluster',
            'route_name' => 'Malabe Express Shuttle',
            'co2_avoided_kg' => 112.75,
            'log_date' => '2026-10-05',
        ];

        $response = $this->postJson('/api/hr/co2-logs', $payload);

        $response->assertStatus(201)
            ->assertJson([
                'success' => true,
                'data' => [
                    'route_name' => 'Malabe Express Shuttle',
                    'co2_avoided_kg' => '112.75',
                ],
            ]);

        $this->assertDatabaseHas('hr_co2_logs', [
            'route_name' => 'Malabe Express Shuttle',
            'co2_avoided_kg' => 112.75,
        ]);
    }

    /**
     * TC-HR-013: Delete CO2 reduction log (Delete 200)
     */
    public function test_tc_hr_013_delete_co2_log_removes_record_from_database(): void
    {
        $log = HrCo2Log::create([
            'employee_name' => 'Temporary Fleet Entry',
            'route_name' => 'Galle Corridor',
            'co2_avoided_kg' => 45.00,
            'log_date' => '2026-10-02',
        ]);

        Sanctum::actingAs($this->hrUser);

        $response = $this->deleteJson("/api/hr/co2-logs/{$log->id}");

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
            ]);

        $this->assertDatabaseMissing('hr_co2_logs', [
            'id' => $log->id,
        ]);
    }

    /**
     * TC-HR-014: Validation failure on missing required fields (422)
     */
    public function test_tc_hr_014_create_co2_log_validation_failure(): void
    {
        Sanctum::actingAs($this->hrUser);

        $response = $this->postJson('/api/hr/co2-logs', [
            'route_name' => 'Kadawatha Express',
            // Missing employee_name, co2_avoided_kg, log_date
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['employee_name', 'co2_avoided_kg', 'log_date']);
    }

    /**
     * TC-HR-015: Authorization - unauthenticated or non-HR access rejected
     */
    public function test_tc_hr_015_unauthenticated_and_commuter_cannot_create_co2_logs(): void
    {
        // 1. Unauthenticated -> 401
        $unauth = $this->postJson('/api/hr/co2-logs', [
            'employee_name' => 'Test',
            'route_name' => 'Test Route',
            'co2_avoided_kg' => 50,
            'log_date' => '2026-10-01',
        ]);
        $unauth->assertStatus(401);

        // 2. Commuter -> 403
        Sanctum::actingAs($this->commuterUser);
        $forbidden = $this->postJson('/api/hr/co2-logs', [
            'employee_name' => 'Test',
            'route_name' => 'Test Route',
            'co2_avoided_kg' => 50,
            'log_date' => '2026-10-01',
        ]);
        $forbidden->assertStatus(403);
    }
}
