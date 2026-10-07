<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('booking_rides_demo', function (Blueprint $table) {
            $table->id();
            $table->string('route_name');
            $table->string('driver_name');
            $table->decimal('driver_rating', 2, 1)->default(4.8);
            $table->string('vehicle_name');
            $table->string('vehicle_plate');
            $table->integer('total_seats')->default(4);
            $table->integer('available_seats')->default(3);
            $table->json('waypoints')->nullable();
            $table->json('polyline')->nullable();
            $table->timestamps();
        });

        Schema::create('booking_bookings', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_id')->nullable();
            $table->unsignedBigInteger('ride_id')->nullable();
            $table->integer('seats_booked')->default(1);
            $table->string('payment_method')->default('Commercial Bank Corp (..4082)');
            $table->decimal('total_fare', 10, 2)->default(800.00);
            $table->string('status')->default('confirmed'); // confirmed, cancelled
            $table->string('pickup_time')->nullable();
            $table->string('dropoff_time')->nullable();
            $table->timestamps();
        });

        Schema::create('booking_trips', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('booking_id')->nullable();
            $table->string('status')->default('waiting'); // waiting, boarded, completed
            $table->decimal('driver_lat', 10, 7)->default(6.0535);
            $table->decimal('driver_lng', 10, 7)->default(80.2210);
            $table->integer('eta_minutes')->default(3);
            $table->integer('grace_seconds')->default(180);
            $table->decimal('distance_km', 6, 2)->default(14.2);
            $table->decimal('co2_avoided_kg', 6, 2)->default(2.4);
            $table->timestamps();
        });

        Schema::create('booking_trip_events', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('trip_id');
            $table->string('event_type')->default('delay_report');
            $table->string('reason');
            $table->integer('delay_minutes')->default(5);
            $table->timestamps();
        });

        Schema::create('booking_trip_shares', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('trip_id');
            $table->string('share_token')->unique();
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });

        Schema::create('booking_fare_settlements', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('trip_id');
            $table->decimal('total_gross_fare', 10, 2)->default(7800.00);
            $table->decimal('base_rate', 10, 2)->default(2400.00);
            $table->decimal('toll_fuel', 10, 2)->default(4800.00);
            $table->decimal('operational_fee', 10, 2)->default(600.00);
            $table->decimal('subsidy_percentage', 5, 2)->default(75.00);
            $table->decimal('subsidy_amount', 10, 2)->default(5850.00);
            $table->decimal('personal_share', 10, 2)->default(800.00);
            $table->boolean('is_approved')->default(false);
            $table->boolean('partial_calibrated')->default(false);
            $table->timestamps();
        });

        Schema::create('booking_fare_splits', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('settlement_id');
            $table->string('passenger_name');
            $table->decimal('distance_km', 6, 2)->default(14.2);
            $table->decimal('share_amount', 10, 2)->default(800.00);
            $table->boolean('is_current_user')->default(false);
            $table->timestamps();
        });

        Schema::create('booking_payment_methods', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_id')->nullable();
            $table->string('card_type')->default('Commercial Bank Corporate');
            $table->string('card_number_masked')->default('ending 4082');
            $table->boolean('is_default')->default(true);
            $table->timestamps();
        });

        Schema::create('booking_ratings', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('trip_id');
            $table->integer('stars')->default(5);
            $table->json('feedback_tags')->nullable();
            $table->text('comment')->nullable();
            $table->timestamps();
        });

        Schema::create('booking_receipts', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('trip_id');
            $table->string('receipt_number')->unique();
            $table->decimal('amount_paid', 10, 2)->default(800.00);
            $table->string('payment_method')->default('Commercial Bank ending 4082');
            $table->decimal('co2_avoided_kg', 6, 2)->default(2.4);
            $table->decimal('fuel_saved_l', 6, 2)->default(1.8);
            $table->integer('points_earned')->default(120);
            $table->boolean('workday_exported')->default(false);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('booking_receipts');
        Schema::dropIfExists('booking_ratings');
        Schema::dropIfExists('booking_payment_methods');
        Schema::dropIfExists('booking_fare_splits');
        Schema::dropIfExists('booking_fare_settlements');
        Schema::dropIfExists('booking_trip_shares');
        Schema::dropIfExists('booking_trip_events');
        Schema::dropIfExists('booking_trips');
        Schema::dropIfExists('booking_bookings');
        Schema::dropIfExists('booking_rides_demo');
    }
};
