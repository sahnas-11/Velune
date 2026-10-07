<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('emergency_active_rides', function (Blueprint $table) {
            $table->id();
            $table->string('route_name')->default('Southern Expressway Corridor');
            $table->string('status')->default('En Route - On Schedule');
            $table->string('departure_location')->default('Matara Interchange');
            $table->string('destination_location')->default('Colombo World Trade Center');
            $table->string('driver_name')->default('Kasun Silva');
            $table->decimal('driver_rating', 2, 1)->default(4.8);
            $table->integer('passenger_count')->default(3);
            $table->integer('speed_kmh')->default(82);
            $table->decimal('distance_left_km', 6, 2)->default(14.2);
            $table->string('eta_time')->default('08:42 AM (12 mins)');
            $table->timestamps();
        });

        Schema::create('emergency_incidents', function (Blueprint $table) {
            $table->id();
            $table->string('incident_number')->unique();
            $table->unsignedBigInteger('user_id')->nullable();
            $table->string('type')->default('Flat Tire'); // Flat Tire, EV / Battery, Overheating, Engine / Mechanical
            $table->string('status')->default('accepted'); // accepted, en_route, arrived, resolved
            $table->string('priority')->default('High Urgency'); // Critical Priority, High Urgency, Patrol en route
            $table->decimal('latitude', 10, 7)->default(6.5824);
            $table->decimal('longitude', 10, 7)->default(80.0543);
            $table->string('km_marker')->default('Southern Expressway, KM 74.2');
            $table->string('vehicle_model')->default('Toyota Prius (Hybrid)');
            $table->string('vehicle_plate')->default('CAB-8492');
            $table->text('description')->nullable();
            $table->string('reported_by')->default('Kaveen Perera');
            $table->string('assigned_mechanic')->default('Nalin Silva');
            $table->string('mechanic_unit')->default('Unit #04');
            $table->string('sla_target')->default('8-12 mins');
            $table->boolean('is_archived')->default(false);
            $table->timestamps();
        });

        Schema::create('emergency_incident_events', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('incident_id');
            $table->string('status_from')->nullable();
            $table->string('status_to');
            $table->text('note')->nullable();
            $table->timestamps();
        });

        Schema::create('emergency_incident_messages', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('incident_id');
            $table->string('sender_name');
            $table->string('sender_role'); // commuter, mechanic, dispatcher
            $table->text('message');
            $table->timestamps();
        });

        Schema::create('emergency_technician_notes', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('incident_id');
            $table->string('technician_name')->default('Nalin Silva');
            $table->text('note');
            $table->timestamps();
        });

        Schema::create('emergency_diagnostic_codes', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('incident_id');
            $table->string('code')->default('P0A80');
            $table->string('description')->default('Hybrid Battery Pack Degradation Detected');
            $table->string('system')->default('Powertrain / Inverter');
            $table->string('severity')->default('Moderate');
            $table->timestamps();
        });

        Schema::create('emergency_route_shares', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('ride_id')->nullable();
            $table->string('share_code')->unique();
            $table->boolean('is_active')->default(true);
            $table->timestamps();
        });

        Schema::create('emergency_notifications', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('incident_id')->nullable();
            $table->string('recipient_role')->default('passenger'); // passenger, fleet_admin, mechanic
            $table->string('recipient_name')->default('Ride Partners');
            $table->string('title');
            $table->text('message');
            $table->boolean('is_read')->default(false);
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('emergency_notifications');
        Schema::dropIfExists('emergency_route_shares');
        Schema::dropIfExists('emergency_diagnostic_codes');
        Schema::dropIfExists('emergency_technician_notes');
        Schema::dropIfExists('emergency_incident_messages');
        Schema::dropIfExists('emergency_incident_events');
        Schema::dropIfExists('emergency_incidents');
        Schema::dropIfExists('emergency_active_rides');
    }
};
