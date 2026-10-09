<?php

namespace Tests\Feature\Hr;

use Tests\TestCase;
use App\Models\User;
use App\Models\HrParkingBay;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;

class ParkingAllocationTest extends TestCase
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
     * TC-HR-021: Read all parking bays (Read 200)
     */
    public function test_tc_hr_021_read_parking_bays_returns_collection(): void
    {
        HrParkingBay::create([
            'bay_code' => 'B-12',
            'floor' => 'Deck B',
            'status' => 'available',
        ]);

        Sanctum::actingAs($this->hrUser);

        $response = $this->getJson('/api/hr/parking-bays');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'data' => [
                    '*' => [
                        'id',
                        'bay_code',
                        'floor',
                        'status',
                    ],
                ],
            ]);
    }

    /**
     * TC-HR-022: Create new priority parking bay (Create 201)
     */
    public function test_tc_hr_022_create_parking_bay_creates_row(): void
    {
        Sanctum::actingAs($this->hrUser);

        $response = $this->postJson('/api/hr/parking-bays', [
            'bay_code' => 'B-15',
            'floor' => 'Deck B - Carpool VIP',
            'status' => 'reserved',
            'assigned_employee' => 'Kottawa Transit Group',
            'vehicle_plate' => 'WP-CAA-8842',
        ]);

        $response->assertStatus(201)
            ->assertJson([
                'success' => true,
                'data' => [
                    'bay_code' => 'B-15',
                    'status' => 'reserved',
                ],
            ]);

        $this->assertDatabaseHas('hr_parking_bays', [
            'bay_code' => 'B-15',
            'status' => 'reserved',
            'vehicle_plate' => 'WP-CAA-8842',
        ]);
    }

    /**
     * TC-HR-023: Update parking bay allocation (Update 200)
     */
    public function test_tc_hr_023_update_parking_bay_modifies_status(): void
    {
        $bay = HrParkingBay::create([
            'bay_code' => 'B-16',
            'floor' => 'Deck B',
            'status' => 'available',
        ]);

        Sanctum::actingAs($this->hrUser);

        $response = $this->putJson("/api/hr/parking-bays/{$bay->id}", [
            'status' => 'occupied',
            'assigned_employee' => 'Malabe Carpool Group B',
            'vehicle_plate' => 'WP-KQ-9901',
        ]);

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'id' => $bay->id,
                    'status' => 'occupied',
                ],
            ]);

        $this->assertDatabaseHas('hr_parking_bays', [
            'id' => $bay->id,
            'status' => 'occupied',
            'vehicle_plate' => 'WP-KQ-9901',
        ]);
    }

    /**
     * TC-HR-024: Delete / release parking spot (Delete 200)
     */
    public function test_tc_hr_024_release_parking_spot_deletes_row(): void
    {
        $bay = HrParkingBay::create([
            'bay_code' => 'B-99',
            'floor' => 'Deck B',
            'status' => 'occupied',
        ]);

        Sanctum::actingAs($this->hrUser);

        $response = $this->deleteJson("/api/hr/parking-bays/{$bay->id}");

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
            ]);

        $this->assertDatabaseMissing('hr_parking_bays', [
            'id' => $bay->id,
        ]);
    }

    /**
     * TC-HR-025: Validation failure on missing bay_code (422)
     */
    public function test_tc_hr_025_create_parking_bay_validation_error(): void
    {
        Sanctum::actingAs($this->hrUser);

        $response = $this->postJson('/api/hr/parking-bays', [
            'floor' => 'Deck B',
            // Missing bay_code
        ]);

        $response->assertStatus(422)
            ->assertJsonValidationErrors(['bay_code']);
    }

    /**
     * TC-HR-026: Authorization - unauthenticated and non-HR access rejected (401 / 403)
     */
    public function test_tc_hr_026_parking_bay_authorization_enforced(): void
    {
        $bay = HrParkingBay::create([
            'bay_code' => 'B-20',
            'floor' => 'Deck B',
        ]);

        // Unauthenticated -> 401
        $this->deleteJson("/api/hr/parking-bays/{$bay->id}")->assertStatus(401);

        // Commuter -> 403
        Sanctum::actingAs($this->commuterUser);
        $this->deleteJson("/api/hr/parking-bays/{$bay->id}")->assertStatus(403);
    }
}
