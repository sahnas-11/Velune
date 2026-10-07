<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\EmergencyActiveRide;
use App\Models\EmergencyIncident;
use App\Models\EmergencyIncidentEvent;
use App\Models\EmergencyIncidentMessage;
use App\Models\EmergencyTechnicianNote;
use App\Models\EmergencyDiagnosticCode;
use App\Models\EmergencyRouteShare;
use App\Models\EmergencyNotification;
use Illuminate\Support\Str;

class EmergencyController extends Controller
{
    // === Active Commuter Ride ===
    public function getActiveRide()
    {
        $ride = EmergencyActiveRide::firstOrCreate(['id' => 1], [
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

        return response()->json([
            'success' => true,
            'data' => $ride
        ]);
    }

    public function shareActiveRide()
    {
        $code = 'EXP-' . strtoupper(Str::random(6));
        $share = EmergencyRouteShare::create([
            'ride_id' => 1,
            'share_code' => $code,
            'is_active' => true,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Route tracking link generated and broadcast to trusted emergency contacts',
            'share_code' => $code,
            'data' => $share
        ]);
    }

    public function stopShareActiveRide()
    {
        EmergencyRouteShare::where('ride_id', 1)->update(['is_active' => false]);

        return response()->json([
            'success' => true,
            'message' => 'Live route tracking broadcast stopped',
        ]);
    }

    // === Commuter Incident Flow ===
    public function createIncident(Request $request)
    {
        $validated = $request->validate([
            'type' => 'required|string',
            'description' => 'nullable|string',
            'latitude' => 'nullable|numeric',
            'longitude' => 'nullable|numeric',
            'km_marker' => 'nullable|string',
            'vehicle_plate' => 'nullable|string',
        ]);

        $incNumber = 'EM-' . mt_rand(8000, 9999);
        $incident = EmergencyIncident::create([
            'incident_number' => $incNumber,
            'user_id' => $request->user()?->id ?? 1,
            'type' => $validated['type'],
            'status' => 'accepted',
            'priority' => 'High Urgency',
            'latitude' => $validated['latitude'] ?? 6.5824,
            'longitude' => $validated['longitude'] ?? 80.0543,
            'km_marker' => $validated['km_marker'] ?? 'Southern Expressway, KM 74.2',
            'vehicle_model' => 'Toyota Prius (Hybrid)',
            'vehicle_plate' => $validated['vehicle_plate'] ?? 'CAB-8492',
            'description' => $validated['description'] ?? 'Breakdown reported on expressway',
            'reported_by' => 'Kaveen Perera',
            'assigned_mechanic' => 'Nalin Silva',
            'mechanic_unit' => 'Unit #04',
            'sla_target' => '8-12 mins',
        ]);

        EmergencyIncidentEvent::create([
            'incident_id' => $incident->id,
            'status_from' => 'reported',
            'status_to' => 'accepted',
            'note' => 'Incident created and dispatched to Unit #04',
        ]);

        // Auto notifications
        EmergencyNotification::create([
            'incident_id' => $incident->id,
            'recipient_role' => 'passenger',
            'recipient_name' => 'Ride Partners (3)',
            'title' => 'Assistance Dispatched',
            'message' => 'Roadside mechanic Unit #04 assigned. Estimated ETA 8-12 mins.',
        ]);

        EmergencyNotification::create([
            'incident_id' => $incident->id,
            'recipient_role' => 'fleet_admin',
            'recipient_name' => 'Fleet Control Room',
            'title' => 'Expressway Incident Logged',
            'message' => 'Incident ' . $incNumber . ' at KM 74.2 logged with High Urgency.',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Emergency breakdown request logged and certified mechanic dispatched',
            'data' => $incident
        ], 201);
    }

    public function getIncident($id)
    {
        $incident = EmergencyIncident::with(['events', 'messages', 'technicianNotes', 'diagnosticCodes', 'notifications'])->findOrFail($id);
        return response()->json([
            'success' => true,
            'data' => $incident
        ]);
    }

    public function getIncidentStatus($id)
    {
        $incident = EmergencyIncident::findOrFail($id);
        return response()->json([
            'success' => true,
            'data' => [
                'incident_id' => $incident->id,
                'incident_number' => $incident->incident_number,
                'status' => $incident->status,
                'eta_mins' => $incident->status === 'en_route' ? 8 : ($incident->status === 'arrived' ? 0 : 12),
                'assigned_mechanic' => $incident->assigned_mechanic,
                'mechanic_unit' => $incident->mechanic_unit,
                'mechanic_phone' => '+94 71 ••• •824',
                'distance_km' => 6.8,
            ]
        ]);
    }

    public function updateIncident(Request $request, $id)
    {
        $incident = EmergencyIncident::findOrFail($id);
        $incident->update($request->only(['type', 'description', 'priority', 'km_marker']));

        return response()->json([
            'success' => true,
            'message' => 'Incident details updated',
            'data' => $incident
        ]);
    }

    public function cancelIncident($id)
    {
        $incident = EmergencyIncident::findOrFail($id);
        $incident->update(['status' => 'cancelled']);

        EmergencyIncidentEvent::create([
            'incident_id' => $incident->id,
            'status_from' => $incident->status,
            'status_to' => 'cancelled',
            'note' => 'Commuter cancelled assistance request',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Assistance request cancelled',
            'data' => $incident
        ]);
    }

    public function sendMessage(Request $request, $id)
    {
        $validated = $request->validate([
            'message' => 'required|string',
            'sender_name' => 'nullable|string',
            'sender_role' => 'nullable|string',
        ]);

        $msg = EmergencyIncidentMessage::create([
            'incident_id' => $id,
            'sender_name' => $validated['sender_name'] ?? 'Kaveen Perera',
            'sender_role' => $validated['sender_role'] ?? 'commuter',
            'message' => $validated['message'],
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Message sent to roadside mechanic',
            'data' => $msg
        ], 201);
    }

    // === Mechanic Queue & Operations ===
    public function getMechanicQueue(Request $request)
    {
        $query = EmergencyIncident::where('is_archived', false);

        if ($request->filled('priority')) {
            $query->where('priority', $request->priority);
        }
        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        $incidents = $query->orderBy('created_at', 'desc')->get();

        return response()->json([
            'success' => true,
            'active_count' => $incidents->where('status', '!=', 'resolved')->count(),
            'avg_response_minutes' => 6.2,
            'data' => $incidents
        ]);
    }

    public function acceptIncident($id)
    {
        $incident = EmergencyIncident::findOrFail($id);
        $incident->update([
            'status' => 'accepted',
            'assigned_mechanic' => 'Nalin Silva',
        ]);

        EmergencyIncidentEvent::create([
            'incident_id' => $incident->id,
            'status_from' => 'pending',
            'status_to' => 'accepted',
            'note' => 'Mechanic Nalin Silva accepted the job',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Emergency job accepted',
            'data' => $incident
        ]);
    }

    public function declineIncident($id)
    {
        $incident = EmergencyIncident::findOrFail($id);
        $incident->update([
            'assigned_mechanic' => 'Unassigned',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Request declined and returned to dispatch pool',
            'data' => $incident
        ]);
    }

    public function updatePriority(Request $request, $id)
    {
        $validated = $request->validate([
            'priority' => 'required|string',
        ]);

        $incident = EmergencyIncident::findOrFail($id);
        $incident->update(['priority' => $validated['priority']]);

        return response()->json([
            'success' => true,
            'message' => 'Incident priority updated to ' . $validated['priority'],
            'data' => $incident
        ]);
    }

    public function updateStatus(Request $request, $id)
    {
        $validated = $request->validate([
            'status' => 'required|in:accepted,en_route,arrived,resolved',
        ]);

        $incident = EmergencyIncident::findOrFail($id);
        $oldStatus = $incident->status;
        $newStatus = $validated['status'];

        $incident->update(['status' => $newStatus]);

        EmergencyIncidentEvent::create([
            'incident_id' => $incident->id,
            'status_from' => $oldStatus,
            'status_to' => $newStatus,
            'note' => 'Status updated to ' . $newStatus,
        ]);

        if ($newStatus === 'resolved') {
            EmergencyNotification::create([
                'incident_id' => $incident->id,
                'recipient_role' => 'passenger',
                'recipient_name' => 'Ride Partners',
                'title' => 'Vehicle Cleared & Resolved',
                'message' => 'Mechanic completed roadside repairs. Safe to proceed.',
            ]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Incident status progressed to ' . $newStatus,
            'data' => $incident
        ]);
    }

    // === Technician Notes & Diagnostic Codes ===
    public function addNote(Request $request, $id)
    {
        $validated = $request->validate([
            'note' => 'required|string',
            'technician_name' => 'nullable|string',
        ]);

        $note = EmergencyTechnicianNote::create([
            'incident_id' => $id,
            'technician_name' => $validated['technician_name'] ?? 'Nalin Silva',
            'note' => $validated['note'],
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Technician note attached to incident file',
            'data' => $note
        ], 201);
    }

    public function deleteNote($id, $noteId)
    {
        $note = EmergencyTechnicianNote::where('incident_id', $id)->where('id', $noteId)->firstOrFail();
        $note->delete();

        return response()->json([
            'success' => true,
            'message' => 'Technician note removed',
        ]);
    }

    public function addDiagnostic(Request $request, $id)
    {
        $validated = $request->validate([
            'code' => 'required|string',
            'description' => 'required|string',
            'system' => 'nullable|string',
            'severity' => 'nullable|string',
        ]);

        $diag = EmergencyDiagnosticCode::create([
            'incident_id' => $id,
            'code' => $validated['code'],
            'description' => $validated['description'],
            'system' => $validated['system'] ?? 'Powertrain',
            'severity' => $validated['severity'] ?? 'Moderate',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'OBD Diagnostic code attached to triage history',
            'data' => $diag
        ], 201);
    }

    public function deleteDiagnostic($id, $diagId)
    {
        $diag = EmergencyDiagnosticCode::where('incident_id', $id)->where('id', $diagId)->firstOrFail();
        $diag->delete();

        return response()->json([
            'success' => true,
            'message' => 'Diagnostic code deleted',
        ]);
    }

    public function archiveIncident($id)
    {
        $incident = EmergencyIncident::findOrFail($id);
        $incident->update(['is_archived' => true]);

        return response()->json([
            'success' => true,
            'message' => 'Incident archived from active queue',
        ]);
    }
}
