<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\BookingRideDemo;
use App\Models\Booking;
use App\Models\BookingTrip;
use App\Models\BookingFareSettlement;
use App\Models\BookingFareSplit;
use App\Models\BookingPaymentMethod;
use App\Models\BookingReceipt;

class BookingSeeder extends Seeder
{
    public function run(): void
    {
        $ride = BookingRideDemo::create([
            'id' => 1,
            'route_name' => 'Matara Clock Tower -> World Trade Center, Colombo',
            'driver_name' => 'Kasun Silva',
            'driver_rating' => 4.8,
            'vehicle_name' => 'Toyota Prius (Hybrid)',
            'vehicle_plate' => 'CAB-4288',
            'total_seats' => 4,
            'available_seats' => 3,
            'waypoints' => [
                ['name' => 'Matara Clock Tower', 'time' => '06:15 AM', 'type' => 'pickup'],
                ['name' => 'Welipenna Service Area', 'time' => '07:05 AM', 'type' => 'intermediate'],
                ['name' => 'Kottawa Interchange', 'time' => '07:35 AM', 'type' => 'intermediate'],
                ['name' => 'World Trade Center, Colombo', 'time' => '08:15 AM', 'type' => 'dropoff'],
            ],
        ]);

        $booking = Booking::create([
            'id' => 1,
            'user_id' => 1,
            'ride_id' => 1,
            'seats_booked' => 1,
            'payment_method' => 'Commercial Bank Corp (..4082)',
            'total_fare' => 800.00,
            'status' => 'confirmed',
            'pickup_time' => '06:15 AM',
            'dropoff_time' => '08:15 AM',
        ]);

        $trip = BookingTrip::create([
            'id' => 1,
            'booking_id' => 1,
            'status' => 'waiting',
            'driver_lat' => 6.0535,
            'driver_lng' => 80.2210,
            'eta_minutes' => 3,
            'grace_seconds' => 180,
            'distance_km' => 14.2,
            'co2_avoided_kg' => 2.4,
        ]);

        $settlement = BookingFareSettlement::create([
            'id' => 1,
            'trip_id' => 1,
            'total_gross_fare' => 7800.00,
            'base_rate' => 2400.00,
            'toll_fuel' => 4800.00,
            'operational_fee' => 600.00,
            'subsidy_percentage' => 75.00,
            'subsidy_amount' => 5850.00,
            'personal_share' => 800.00,
            'is_approved' => false,
            'partial_calibrated' => false,
        ]);

        BookingFareSplit::create([
            'settlement_id' => 1,
            'passenger_name' => 'Amanda C. (You)',
            'distance_km' => 14.2,
            'share_amount' => 800.00,
            'is_current_user' => true,
        ]);

        BookingFareSplit::create([
            'settlement_id' => 1,
            'passenger_name' => 'Naveen K.',
            'distance_km' => 10.2,
            'share_amount' => 575.00,
            'is_current_user' => false,
        ]);

        BookingFareSplit::create([
            'settlement_id' => 1,
            'passenger_name' => 'Kirthan S.',
            'distance_km' => 10.2,
            'share_amount' => 575.00,
            'is_current_user' => false,
        ]);

        BookingPaymentMethod::create([
            'user_id' => 1,
            'card_type' => 'Commercial Bank Corporate',
            'card_number_masked' => 'ending 4082',
            'is_default' => true,
        ]);

        BookingReceipt::create([
            'id' => 1,
            'trip_id' => 1,
            'receipt_number' => 'REC-2026-9042',
            'amount_paid' => 800.00,
            'payment_method' => 'Commercial Bank ending 4082',
            'co2_avoided_kg' => 2.4,
            'fuel_saved_l' => 1.8,
            'points_earned' => 120,
            'workday_exported' => false,
        ]);
    }
}
