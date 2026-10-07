<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Foundation Users
        User::firstOrCreate(
            ['email' => 'amanda@velune.lk'],
            [
                'name' => 'Amanda Jayawardena',
                'password' => bcrypt('password123'),
            ]
        );

        User::firstOrCreate(
            ['email' => 'nalin@velune.lk'],
            [
                'name' => 'Nalin Silva',
                'password' => bcrypt('password123'),
            ]
        );

        User::firstOrCreate(
            ['email' => 'kaveen@velune.lk'],
            [
                'name' => 'Kaveen Perera',
                'password' => bcrypt('password123'),
            ]
        );

        // Module Seeders
        $this->call([
            BookingSeeder::class,
            EmergencySeeder::class,
            HrCorporateSeeder::class,
        ]);
    }
}
