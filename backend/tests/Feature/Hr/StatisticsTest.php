<?php

namespace Tests\Feature\Hr;

use Tests\TestCase;
use App\Models\User;
use App\Models\HrPinnedRoute;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;

class StatisticsTest extends TestCase
{
    use RefreshDatabase;

    protected User $hrUser;
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

        $this->mechanicUser = User::create([
            'name' => 'Nalin Silva',
            'email' => 'nalin@company.com',
            'password' => bcrypt('password123'),
            'role' => 'mechanic',
        ]);
    }

    /**
     * TC-HR-031: Read pinned routes and statistics (Read 200)
     */
    public function test_tc_hr_031_read_pinned_routes_returns_list(): void
    {
        HrPinnedRoute::create([
            'route_name' => 'Kottawa - Campus Line',
            'avg_commuters' => 86,
            'co2_saving_kg' => 45.20,
            'is_pinned' => true,
        ]);

        Sanctum::actingAs($this->hrUser);

        $response = $this->getJson('/api/hr/pinned-routes');

        $response->assertStatus(200)
            ->assertJsonStructure([
                'success',
                'data' => [
                    '*' => [
                        'id',
                        'route_name',
                        'avg_commuters',
                        'co2_saving_kg',
                        'is_pinned',
                    ],
                ],
            ]);
    }

    /**
     * TC-HR-032: Toggle route pinned status (Update 200)
     */
    public function test_tc_hr_032_toggle_pinned_route_updates_database(): void
    {
        $route = HrPinnedRoute::create([
            'route_name' => 'Malabe Express Corridor',
            'avg_commuters' => 54,
            'co2_saving_kg' => 32.10,
            'is_pinned' => true,
        ]);

        Sanctum::actingAs($this->hrUser);

        $response = $this->postJson("/api/hr/pinned-routes/{$route->id}/toggle");

        $response->assertStatus(200)
            ->assertJson([
                'success' => true,
                'data' => [
                    'id' => $route->id,
                    'is_pinned' => false,
                ],
            ]);

        $this->assertDatabaseHas('hr_pinned_routes', [
            'id' => $route->id,
            'is_pinned' => false,
        ]);
    }

    /**
     * TC-HR-033: NFR-04 - Statistics response only contains aggregated data
     */
    public function test_tc_hr_033_nfr04_statistics_contains_no_commuter_pii(): void
    {
        HrPinnedRoute::create([
            'route_name' => 'Kadawatha Express',
            'avg_commuters' => 41,
            'co2_saving_kg' => 28.00,
            'is_pinned' => true,
        ]);

        Sanctum::actingAs($this->hrUser);

        $response = $this->getJson('/api/hr/pinned-routes');
        $response->assertStatus(200);

        $body = $response->getContent();

        $this->assertStringNotContainsString('@company.com', $body);
        $this->assertStringNotContainsString('phone', $body);
        $this->assertStringNotContainsString('email', $body);
    }

    /**
     * TC-HR-034: Authorization - unauthenticated and non-HR access rejected (401 / 403)
     */
    public function test_tc_hr_034_statistics_authorization_enforced(): void
    {
        $route = HrPinnedRoute::create([
            'route_name' => 'Test Route',
            'avg_commuters' => 10,
            'co2_saving_kg' => 5.0,
            'is_pinned' => true,
        ]);

        // Unauthenticated -> 401
        $this->postJson("/api/hr/pinned-routes/{$route->id}/toggle")->assertStatus(401);

        // Mechanic -> 403
        Sanctum::actingAs($this->mechanicUser);
        $this->postJson("/api/hr/pinned-routes/{$route->id}/toggle")->assertStatus(403);
    }
}
