<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\HrCampusGoal;
use App\Models\HrParkingBay;
use App\Models\HrCo2Log;
use App\Models\HrPinnedRoute;
use App\Models\HrIncentiveProgram;
use App\Models\HrFleetAward;

class HrCorporateSeeder extends Seeder
{
    public function run(): void
    {
        HrCampusGoal::create([
            'target_co2_kg' => 5000.00,
            'current_co2_kg' => 3840.00,
            'target_period' => 'Q4 2026',
        ]);

        $bays = [
            ['bay_code' => 'B-01', 'floor' => 'Deck B', 'status' => 'occupied', 'assigned_employee' => 'Kasun Silva', 'vehicle_plate' => 'CAB-4288'],
            ['bay_code' => 'B-02', 'floor' => 'Deck B', 'status' => 'available', 'assigned_employee' => null, 'vehicle_plate' => null],
            ['bay_code' => 'B-03', 'floor' => 'Deck B', 'status' => 'reserved', 'assigned_employee' => 'Amanda Jayawardena', 'vehicle_plate' => 'WP CAD-1002'],
            ['bay_code' => 'B-04', 'floor' => 'Deck B', 'status' => 'available', 'assigned_employee' => null, 'vehicle_plate' => null],
            ['bay_code' => 'B-05', 'floor' => 'Deck B', 'status' => 'occupied', 'assigned_employee' => 'Naveen K.', 'vehicle_plate' => 'WP CAJ-9921'],
        ];
        foreach ($bays as $bay) {
            HrParkingBay::create($bay);
        }

        $logs = [
            ['employee_name' => 'Amanda C.', 'route_name' => 'Matara -> Colombo WTC', 'co2_avoided_kg' => 14.2, 'log_date' => '2026-10-07'],
            ['employee_name' => 'Naveen K.', 'route_name' => 'Galle -> Colombo Fort', 'co2_avoided_kg' => 11.8, 'log_date' => '2026-10-06'],
            ['employee_name' => 'Kirthan S.', 'route_name' => 'Kottawa -> Cyber Center', 'co2_avoided_kg' => 8.4, 'log_date' => '2026-10-05'],
        ];
        foreach ($logs as $log) {
            HrCo2Log::create($log);
        }

        $routes = [
            ['route_name' => 'Southern Expressway Corridor', 'avg_commuters' => 4, 'co2_saving_kg' => 18.5, 'is_pinned' => true],
            ['route_name' => 'Kandy - Colombo Expressway (Central)', 'avg_commuters' => 3, 'co2_saving_kg' => 14.2, 'is_pinned' => true],
            ['route_name' => 'Katunayake Airport Link', 'avg_commuters' => 3, 'co2_saving_kg' => 9.8, 'is_pinned' => false],
        ];
        foreach ($routes as $route) {
            HrPinnedRoute::create($route);
        }

        $incentives = [
            ['title' => 'Expressway Green Commuter Tier 1', 'description' => 'Complete 10 carpool rides monthly on expressway corridors.', 'points_reward' => 500, 'status' => 'active'],
            ['title' => 'Early Bird Zero-Emissions Carpool', 'description' => 'Arrive before 7:30 AM at Orion City campus in a 3+ carpool.', 'points_reward' => 250, 'status' => 'active'],
            ['title' => 'Carpool Captain Champion', 'description' => 'Host 20 carpool trips as verified corporate driver.', 'points_reward' => 1000, 'status' => 'active'],
        ];
        foreach ($incentives as $inc) {
            HrIncentiveProgram::create($inc);
        }

        $awards = [
            ['squad_name' => 'FinTech Green Squad', 'total_points' => 2450, 'badge' => 'Diamond Elite', 'rank' => 1],
            ['squad_name' => 'Expressway Commute Pioneers', 'total_points' => 1980, 'badge' => 'Gold Vanguard', 'rank' => 2],
            ['squad_name' => 'Colombo Cyber Commuters', 'total_points' => 1650, 'badge' => 'Silver Fleet', 'rank' => 3],
        ];
        foreach ($awards as $award) {
            HrFleetAward::create($award);
        }
    }
}
