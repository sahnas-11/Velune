<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('discovery_otp_codes', function (Blueprint $table) {
            $table->id();
            $table->string('email');
            $table->string('code_hash');
            $table->timestamp('expires_at');
            $table->integer('attempts')->default(0);
            $table->timestamps();
        });

        Schema::create('discovery_locations', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('city');
            $table->string('zone')->default('Standard');
            $table->decimal('latitude', 10, 7)->nullable();
            $table->decimal('longitude', 10, 7)->nullable();
            $table->timestamps();
        });

        Schema::create('discovery_rides', function (Blueprint $table) {
            $table->id();
            $table->string('driver_name')->default('Kasun Silva');
            $table->decimal('driver_rating', 2, 1)->default(4.8);
            $table->string('driver_avatar')->nullable();
            $table->string('driver_phone_masked')->default('+94 77 ••• •288');
            $table->string('vehicle_model')->default('Toyota Prius (Hybrid)');
            $table->string('vehicle_plate')->default('CAB-4288');
            $table->string('from_location')->default('Matara Town');
            $table->string('to_location')->default('Colombo Office HQ');
            $table->string('pickup_spot')->default('Gate 2 Hub');
            $table->string('dropoff_spot')->default('Main Tower');
            $table->string('departure_time')->default('08:00 AM');
            $table->string('arrival_time')->default('09:30 AM');
            $table->date('date');
            $table->integer('seats_total')->default(4);
            $table->integer('seats_left')->default(2);
            $table->decimal('price', 8, 2)->default(450.00);
            $table->string('tag')->default('Direct Route');
            $table->boolean('verified_only')->default(true);
            $table->json('polyline')->nullable();
            $table->timestamps();
        });

        Schema::create('discovery_saved_searches', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_id')->nullable();
            $table->string('from_location');
            $table->string('to_location');
            $table->string('preferred_time')->nullable();
            $table->timestamps();
        });

        Schema::create('discovery_saved_routes', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_id')->nullable();
            $table->string('title')->default('Daily Work Commute');
            $table->string('from_location');
            $table->string('to_location');
            $table->timestamps();
        });

        Schema::create('discovery_bookmarks', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_id')->nullable();
            $table->unsignedBigInteger('ride_id');
            $table->timestamps();
        });

        Schema::create('discovery_ride_reports', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_id')->nullable();
            $table->unsignedBigInteger('ride_id');
            $table->string('reason');
            $table->text('details')->nullable();
            $table->timestamps();
        });

        Schema::create('discovery_notices', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_id')->nullable();
            $table->string('title');
            $table->text('message');
            $table->timestamp('dismissed_at')->nullable();
            $table->timestamps();
        });

        Schema::create('discovery_notifications', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('user_id')->nullable();
            $table->string('title');
            $table->text('message');
            $table->timestamp('read_at')->nullable();
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('discovery_notifications');
        Schema::dropIfExists('discovery_notices');
        Schema::dropIfExists('discovery_ride_reports');
        Schema::dropIfExists('discovery_bookmarks');
        Schema::dropIfExists('discovery_saved_routes');
        Schema::dropIfExists('discovery_saved_searches');
        Schema::dropIfExists('discovery_rides');
        Schema::dropIfExists('discovery_locations');
        Schema::dropIfExists('discovery_otp_codes');
    }
};
