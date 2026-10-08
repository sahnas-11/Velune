<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\DiscoveryLocation;
use App\Models\DiscoveryRide;
use App\Models\DiscoveryNotice;
use App\Models\DiscoveryNotification;
use App\Models\DiscoverySavedRoute;
use Carbon\Carbon;
use Illuminate\Support\Facades\Hash;

class DiscoverySeeder extends Seeder
{
    public function run(): void
    {
        // 1. Seed Users with corporate domains
        User::updateOrCreate(
            ['email' => 'jay@company.com'],
            [
                'name' => 'Jay Karunarathna',
                'password' => Hash::make('password123'),
                'role' => 'commuter',
                'email_verified_at' => Carbon::now(),
                'id_verified_at' => Carbon::now(),
                'government_id_last3' => '821',
            ]
        );

        User::updateOrCreate(
            ['email' => 'amanda@company.com'],
            [
                'name' => 'Amanda Jayawardena',
                'password' => Hash::make('password123'),
                'role' => 'hr_manager',
                'email_verified_at' => Carbon::now(),
                'id_verified_at' => Carbon::now(),
                'government_id_last3' => '102',
            ]
        );

        User::updateOrCreate(
            ['email' => 'nalin@company.com'],
            [
                'name' => 'Nalin Silva',
                'password' => Hash::make('password123'),
                'role' => 'mechanic',
                'email_verified_at' => Carbon::now(),
                'id_verified_at' => Carbon::now(),
                'government_id_last3' => '440',
            ]
        );

        User::updateOrCreate(
            ['email' => 'kaveen@company.com'],
            [
                'name' => 'Kaveen Perera',
                'password' => Hash::make('password123'),
                'role' => 'commuter',
                'email_verified_at' => Carbon::now(),
                'id_verified_at' => Carbon::now(),
                'government_id_last3' => '892',
            ]
        );

        // 2. Locations
        $locations = [
            ['name' => 'Matara Town', 'city' => 'Matara', 'zone' => 'Departure Hub', 'latitude' => 5.9485, 'longitude' => 80.5353],
            ['name' => 'Matara Clock Tower', 'city' => 'Matara', 'zone' => 'Central Hub', 'latitude' => 5.9496, 'longitude' => 80.5469],
            ['name' => 'Matara Expressway Hub', 'city' => 'Matara', 'zone' => 'Expressway', 'latitude' => 5.9610, 'longitude' => 80.5280],
            ['name' => 'Colombo Office HQ', 'city' => 'Colombo', 'zone' => 'HQ Zone', 'latitude' => 6.9271, 'longitude' => 79.8612],
            ['name' => 'World Trade Center', 'city' => 'Colombo', 'zone' => 'HQ Zone', 'latitude' => 6.9344, 'longitude' => 79.8428],
            ['name' => 'Colombo Fort', 'city' => 'Colombo', 'zone' => 'Corporate Zone', 'latitude' => 6.9355, 'longitude' => 79.8487],
            ['name' => 'Kottawa Interchange', 'city' => 'Colombo', 'zone' => 'Interchange', 'latitude' => 6.8416, 'longitude' => 79.9654],
            ['name' => 'Malabe Cyber Center', 'city' => 'Colombo', 'zone' => 'Tech Zone', 'latitude' => 6.9044, 'longitude' => 79.9544],
            ['name' => 'Kadawatha Exit', 'city' => 'Gampaha', 'zone' => 'Expressway', 'latitude' => 7.0016, 'longitude' => 79.9525],
        ];

        foreach ($locations as $loc) {
            DiscoveryLocation::create($loc);
        }

        // 3. Discovery Rides (for next 14 days)
        $today = Carbon::today();

        // Ride 1 (Primary demo ride matching Tissera's id 1)
        DiscoveryRide::create([
            'id' => 1,
            'driver_name' => 'Kasun Silva',
            'driver_rating' => 4.8,
            'driver_phone_masked' => '+94 77 ••• •288',
            'vehicle_model' => 'Silver Toyota Prius (Hybrid)',
            'vehicle_plate' => 'CAB-4288',
            'from_location' => 'Matara Town',
            'to_location' => 'Colombo Office HQ',
            'pickup_spot' => 'Matara Town / Gate 2 Hub',
            'dropoff_spot' => 'Colombo Office / Main Tower',
            'departure_time' => '08:00 AM',
            'arrival_time' => '09:30 AM',
            'date' => $today->copy()->addDay()->toDateString(),
            'seats_total' => 4,
            'seats_left' => 2,
            'price' => 450.00,
            'tag' => 'Direct Route',
            'verified_only' => true,
        ]);

        // Ride 2
        DiscoveryRide::create([
            'id' => 2,
            'driver_name' => 'Nimal Perera',
            'driver_rating' => 4.9,
            'driver_phone_masked' => '+94 71 ••• •512',
            'vehicle_model' => 'Honda Vezel (Hybrid)',
            'vehicle_plate' => 'WP CAD-1902',
            'from_location' => 'Matara Clock Tower',
            'to_location' => 'World Trade Center',
            'pickup_spot' => 'Matara Clock Tower Hub',
            'dropoff_spot' => 'WTC West Tower Lobby',
            'departure_time' => '08:15 AM',
            'arrival_time' => '09:45 AM',
            'date' => $today->copy()->addDay()->toDateString(),
            'seats_total' => 4,
            'seats_left' => 3,
            'price' => 500.00,
            'tag' => 'On-time 99%',
            'verified_only' => true,
        ]);

        // Ride 3
        DiscoveryRide::create([
            'id' => 3,
            'driver_name' => 'Chaminda Dias',
            'driver_rating' => 4.7,
            'driver_phone_masked' => '+94 76 ••• •991',
            'vehicle_model' => 'Nissan Note e-Power',
            'vehicle_plate' => 'WP CAJ-8812',
            'from_location' => 'Matara Express Hub',
            'to_location' => 'Colombo Fort',
            'pickup_spot' => 'Expressway Southern Gate',
            'dropoff_spot' => 'Fort Station Plaza',
            'departure_time' => '08:30 AM',
            'arrival_time' => '10:00 AM',
            'date' => $today->copy()->addDay()->toDateString(),
            'seats_total' => 3,
            'seats_left' => 1,
            'price' => 450.00,
            'tag' => 'Express Route',
            'verified_only' => true,
        ]);

        // 4. Daily Notice
        DiscoveryNotice::create([
            'title' => 'Daily Notice',
            'message' => 'Book executive rides by 6:00 PM today for priority assignment on peak morning routes.',
        ]);

        // 5. Saved Route
        DiscoverySavedRoute::create([
            'title' => 'Expressway Daily Commute',
            'from_location' => 'Matara Town',
            'to_location' => 'Colombo Office HQ',
        ]);

        // 6. Notifications
        DiscoveryNotification::create([
            'title' => 'Corporate ID Verified',
            'message' => 'Your government ID and corporate identity are certified for carpool access.',
        ]);
    }
}
