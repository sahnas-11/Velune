<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\EmergencyActiveRide;
use App\Models\EmergencyIncident;
use App\Models\EmergencyIncidentEvent;
use App\Models\EmergencyTechnicianNote;
use App\Models\EmergencyDiagnosticCode;
use App\Models\EmergencyNotification;

class EmergencySeeder extends Seeder
{
    public function run(): void
    {
        EmergencyActiveRide::create([
            'id' => 1,
            'route_name' => 'Southern Expressway Corridor',
            'status' => 'En Route - On Schedule',
            'departure_location' => 'Matara Interchange',
            'destination_location' => 'Colombo World Trade Center',
            'driver_name' => 'Kasun Silva',
            'driver_rating' => 4.8,
            'passenger_count' => 3,
            'speed_kmh' => 82,
            'distance_left_km' => 14.2,
            'eta_time' => '08:42 AM (12 mins)',
        ]);

        $inc1 = EmergencyIncident::create([
            'id' => 1,
            'incident_number' => 'EM-8842',
            'type' => 'Flat Tire',
            'status' => 'accepted',
            'priority' => 'Critical Priority',
            'latitude' => 6.5824,
            'longitude' => 80.0543,
            'km_marker' => 'Southern Expressway, KM 74.2 (Welipenna Area)',
            'vehicle_model' => 'Toyota Axio (White)',
            'vehicle_plate' => 'CAB-8821',
            'description' => 'Rear right tire puncture at high speed. Pulled over to hard shoulder.',
            'reported_by' => 'Kaveen Perera',
            'assigned_mechanic' => 'Nalin Silva',
            'mechanic_unit' => 'Unit #04',
            'sla_target' => '8-12 mins',
        ]);

        $inc2 = EmergencyIncident::create([
            'id' => 2,
            'incident_number' => 'EM-8843',
            'type' => 'Overheating',
            'status' => 'en_route',
            'priority' => 'Roadside Assist',
            'latitude' => 6.7020,
            'longitude' => 80.0120,
            'km_marker' => 'Gelanigama Exit, KM 34.1',
            'vehicle_model' => 'Honda Fit (Hybrid)',
            'vehicle_plate' => 'CAB-4120',
            'description' => 'Coolant warning light illuminated. Parked near exit ramp.',
            'reported_by' => 'Priya Fernando',
            'assigned_mechanic' => 'Nalin Silva',
            'mechanic_unit' => 'Unit #04',
            'sla_target' => '15 mins',
        ]);

        $inc3 = EmergencyIncident::create([
            'id' => 3,
            'incident_number' => 'EM-8844',
            'type' => 'EV / Battery',
            'status' => 'arrived',
            'priority' => 'Patrol en route',
            'latitude' => 6.5120,
            'longitude' => 80.0890,
            'km_marker' => 'Welipenna Rest Stop, KM 46.0',
            'vehicle_model' => 'Nissan Leaf EV',
            'vehicle_plate' => 'CAD-9012',
            'description' => 'Battery depleted before fast charger station.',
            'reported_by' => 'Rohan Jayathilake',
            'assigned_mechanic' => 'Sunil Wickramasinghe',
            'mechanic_unit' => 'Unit #02',
            'sla_target' => 'Resolved Soon',
        ]);

        EmergencyIncidentEvent::create([
            'incident_id' => 1,
            'status_from' => 'reported',
            'status_to' => 'accepted',
            'note' => 'Incident reported and accepted by Fleet Unit #04',
        ]);

        EmergencyTechnicianNote::create([
            'incident_id' => 1,
            'technician_name' => 'Nalin Silva',
            'note' => 'High speed highway dispatch. Heavy impact jack and spare tire ready in van.',
        ]);

        EmergencyDiagnosticCode::create([
            'incident_id' => 1,
            'code' => 'P0A80',
            'description' => 'Hybrid Battery Pack Degradation Detected',
            'system' => 'Powertrain / Inverter',
            'severity' => 'Moderate',
        ]);

        EmergencyNotification::create([
            'incident_id' => 1,
            'recipient_role' => 'passenger',
            'recipient_name' => 'Ride Partners (3)',
            'title' => 'Assistance Dispatched',
            'message' => 'Nalin Silva (Unit #04) en route. ETA 8-12 mins.',
        ]);
    }
}
