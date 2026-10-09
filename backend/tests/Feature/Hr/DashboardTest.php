<?php

namespace Tests\Feature\Hr;

use Tests\TestCase;
use App\Models\User;
use App\Models\HrCampusGoal;
use App\Models\HrParkingBay;
use App\Models\HrPinnedRoute;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;

class DashboardTest extends TestCase
{
    use RefreshDatabase;

    protected User $hrUser;
    protected User $commuterUser;
    protected User $mechanicUser;

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

        $this->mechanicUser = User::create([
            'name' => 'Nalin Silva',
            'email' => 'nalin@company.com',
            'password' => bcrypt('password123'),
            'role' => 'mechanic',
        ]);
    }

    /**
     * TC-HR-001: Read dashboard summary metrics (success 200)
     */
    public function test_tc_hr_001_read_dashboard_returns_success_and_aggregated_data(): void
    {
        $goal = HrCampusGoal::create([
            'target_co2_kg' => 5000.00,
            'current_co2_kg' => 3840.00,
            'target_period' => 'Q4 2026',
        ]);

        HrParkingBay::create([
            'bay_code' => 'B-01',
            'status' => 'occupied',
        ]);

        HrParkingBay::create([
            'bay_code' => 'B-02',
            'status' => 'available',
        ]);

        Sanctum::actingAs($this->hrUser);

        $response = $this->getJson('/api/hr/dashboard');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'data' => [
                    'campus_goal',
                    'total_bays',
                    'occupied_bays',
                    'pinned_routes',
                    'monthly_co2_kg',
                    'corporate_subsidy_spent_lkr',
                    'active_commuters',
                ],
            ])
            ->assertJson([
                'success' => true,
                'data' => [
                    'total_bays' => 2,
                    'occupied_bays' => 1,
                ],
            ]);
    }

    /**
     * TC-HR-002: Update campus decarbonization target goal (success 200)
     */
    public function test_tc_hr_002_update_campus_goal_updates_database(): void
    {
        $goal = HrCampusGoal::create([
            'target_co2_kg' => 5000.00,
            'current_co2_kg' => 3840.00,
            'target_period' => 'Q4 2026',
        ]);

        Sanctum::actingAs($this->hrUser);

        $response = $this->putJson("/api/hr/goals/{$goal->id}", [
            'target_co2_kg' => 6200.00,
            'current_co2_kg' => 4100.00,
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'id' => $goal->id,
                    'target_co2_kg' => '6200.00',
                ],
            ]);

        $this->assertDatabaseHas('hr_campus_goals', [
            'id' => $goal->id,
            'target_co2_kg' => 6200.00,
        ]);
    }

    /**
     * TC-HR-003: Validation failure on updating goal with invalid data (422)
     */
    public function test_tc_hr_003_update_goal_fails_validation_for_missing_or_non_numeric(): void
    {
        $goal = HrCampusGoal::create([
            'target_co2_kg' => 5000.00,
            'current_co2_kg' => 3840.00,
            'target_period' => 'Q4 2026',
        ]);

        Sanctum::actingAs($this->hrUser);

        $response = $this->putJson("/api/hr/goals/{$goal->id}", [
            'target_co2_kg' => 'invalid-string',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['target_co2_kg']);
    }

    /**
     * TC-HR-004: Authorization - unauthenticated access rejected (401)
     */
    public function test_tc_hr_004_unauthenticated_request_rejected_with_401(): void
    {
        $response = $this->getJson('/api/hr/dashboard');
        $response->assertStatus(401);
    }

    /**
     * TC-HR-005: Authorization - non-HR role rejected (403)
     */
    public function test_tc_hr_005_commuter_role_forbidden_from_dashboard_with_403(): void
    {
        Sanctum::actingAs($this->commuterUser);

        $response = $this->getJson('/api/hr/dashboard');
        $response->assertStatus(403);
    }

    /**
     * TC-HR-006: NFR-04 - Response contains no individual commuter PII
     */
    public function test_tc_hr_006_nfr04_dashboard_contains_no_commuter_pii(): void
    {
        HrCampusGoal::create([
            'target_co2_kg' => 5000.00,
            'current_co2_kg' => 3840.00,
            'target_period' => 'Q4 2026',
        ]);

        Sanctum::actingAs($this->hrUser);

        $response = $this->getJson('/api/hr/dashboard');
        $response->assertStatus(200);

        $body = $response->getContent();

        // Must not contain commuter private data
        $this->assertStringNotContainsString('@company.com', $body);
        $this->assertStringNotContainsString('077', $body);
        $this->assertStringNotContainsString('phone', $body);
        $this->assertStringNotContainsString('nic', $body);
    }
}
