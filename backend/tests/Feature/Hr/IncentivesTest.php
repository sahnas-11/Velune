<?php

namespace Tests\Feature\Hr;

use Tests\TestCase;
use App\Models\User;
use App\Models\HrIncentiveProgram;
use App\Models\HrFleetAward;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;

class IncentivesTest extends TestCase
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
     * TC-HR-051: Read incentive programs and fleet awards (Read 200)
     */
    public function test_tc_hr_051_read_incentives_returns_programs_and_awards(): void
    {
        HrIncentiveProgram::create([
            'title' => 'Green Commuter Subsidy',
            'description' => 'LKR 5,000 monthly transit allowance',
            'points_reward' => 500,
            'status' => 'active',
        ]);

        HrFleetAward::create([
            'squad_name' => 'QA Team Carpoolers',
            'total_points' => 1200,
            'badge' => 'Gold Pioneer',
            'rank' => 1,
        ]);

        Sanctum::actingAs($this->hrUser);

        $response = $this->getJson('/api/hr/incentives');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'programs' => [
                    '*' => [
                        'id',
                        'title',
                        'description',
                        'points_reward',
                    ],
                ],
                'awards' => [
                    '*' => [
                        'id',
                        'squad_name',
                        'total_points',
                        'badge',
                        'rank',
                    ],
                ],
            ]);
    }

    /**
     * TC-HR-052: Create new commuter incentive program (Create 201)
     */
    public function test_tc_hr_052_create_incentive_creates_database_row(): void
    {
        Sanctum::actingAs($this->hrUser);

        $response = $this->postJson('/api/hr/incentives', [
            'title' => 'Expressway Toll Subsidy',
            'description' => 'Company covers Southern Expressway tolls for carpools with 3+ passengers',
            'points_reward' => 350,
        ]);

        $response->assertStatus(201)
            ->assertJson([
                'success' => true,
                'data' => [
                    'title' => 'Expressway Toll Subsidy',
                    'points_reward' => 350,
                ],
            ]);

        $this->assertDatabaseHas('hr_incentive_programs', [
            'title' => 'Expressway Toll Subsidy',
            'points_reward' => 350,
        ]);
    }

    /**
     * TC-HR-053: Update incentive program (Update 200)
     */
    public function test_tc_hr_053_update_incentive_modifies_reward(): void
    {
        $program = HrIncentiveProgram::create([
            'title' => 'Breakfast Voucher Incentive',
            'description' => 'Free campus cafeteria breakfast for carpools arriving before 8:15 AM',
            'points_reward' => 150,
            'status' => 'active',
        ]);

        Sanctum::actingAs($this->hrUser);

        $response = $this->putJson("/api/hr/incentives/{$program->id}", [
            'points_reward' => 200,
            'status' => 'completed',
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'id' => $program->id,
                    'points_reward' => 200,
                    'status' => 'completed',
                ],
            ]);

        $this->assertDatabaseHas('hr_incentive_programs', [
            'id' => $program->id,
            'points_reward' => 200,
            'status' => 'completed',
        ]);
    }

    /**
     * TC-HR-054: Delete incentive program (Delete 200)
     */
    public function test_tc_hr_054_delete_incentive_removes_from_database(): void
    {
        $program = HrIncentiveProgram::create([
            'title' => 'Deprecated Summer Voucher',
            'description' => 'Expired program',
            'points_reward' => 50,
            'status' => 'completed',
        ]);

        Sanctum::actingAs($this->hrUser);

        $response = $this->deleteJson("/api/hr/incentives/{$program->id}");

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
            ]);

        $this->assertDatabaseMissing('hr_incentive_programs', [
            'id' => $program->id,
        ]);
    }

    /**
     * TC-HR-055: Validation failure on missing fields or non-integer points (422)
     */
    public function test_tc_hr_055_create_incentive_validation_failure(): void
    {
        Sanctum::actingAs($this->hrUser);

        $response = $this->postJson('/api/hr/incentives', [
            'description' => 'Missing title and invalid points',
            'points_reward' => 'not-an-int',
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['title', 'points_reward']);
    }

    /**
     * TC-HR-056: Authorization - unauthenticated and non-HR access rejected (401 / 403)
     */
    public function test_tc_hr_056_incentive_authorization_enforced(): void
    {
        $program = HrIncentiveProgram::create([
            'title' => 'Protected Program',
            'description' => 'Only HR can manage',
            'points_reward' => 100,
        ]);

        // Unauthenticated -> 401
        $this->deleteJson("/api/hr/incentives/{$program->id}")->assertStatus(401);

        // Commuter -> 403
        Sanctum::actingAs($this->commuterUser);
        $this->deleteJson("/api/hr/incentives/{$program->id}")->assertStatus(403);
    }
}
