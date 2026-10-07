<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('hr_campus_goals', function (Blueprint $table) {
            $table->id();
            $table->decimal('target_co2_kg', 10, 2)->default(5000.00);
            $table->decimal('current_co2_kg', 10, 2)->default(3840.00);
            $table->string('target_period')->default('Q4 2026');
            $table->timestamps();
        });

        Schema::create('hr_parking_bays', function (Blueprint $table) {
            $table->id();
            $table->string('bay_code'); // B-01, B-02, etc.
            $table->string('floor')->default('Deck B');
            $table->string('status')->default('available'); // available, reserved, occupied
            $table->string('assigned_employee')->nullable();
            $table->string('vehicle_plate')->nullable();
            $table->timestamps();
        });

        Schema::create('hr_co2_logs', function (Blueprint $table) {
            $table->id();
            $table->string('employee_name');
            $table->string('route_name');
            $table->decimal('co2_avoided_kg', 8, 2);
            $table->date('log_date');
            $table->timestamps();
        });

        Schema::create('hr_pinned_routes', function (Blueprint $table) {
            $table->id();
            $table->string('route_name');
            $table->integer('avg_commuters')->default(4);
            $table->decimal('co2_saving_kg', 8, 2)->default(12.5);
            $table->boolean('is_pinned')->default(true);
            $table->timestamps();
        });

        Schema::create('hr_incentive_programs', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->text('description');
            $table->integer('points_reward')->default(250);
            $table->string('status')->default('active'); // active, draft, completed
            $table->timestamps();
        });

        Schema::create('hr_fleet_awards', function (Blueprint $table) {
            $table->id();
            $table->string('squad_name');
            $table->integer('total_points')->default(1400);
            $table->string('badge')->default('Gold Vanguard');
            $table->integer('rank')->default(1);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('hr_fleet_awards');
        Schema::dropIfExists('hr_incentive_programs');
        Schema::dropIfExists('hr_pinned_routes');
        Schema::dropIfExists('hr_co2_logs');
        Schema::dropIfExists('hr_parking_bays');
        Schema::dropIfExists('hr_campus_goals');
    }
};
