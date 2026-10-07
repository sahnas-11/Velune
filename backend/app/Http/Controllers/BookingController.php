<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\BookingRideDemo;
use App\Models\Booking;
use App\Models\BookingTrip;
use App\Models\BookingTripEvent;
use App\Models\BookingTripShare;
use App\Models\BookingFareSettlement;
use App\Models\BookingFareSplit;
use App\Models\BookingRating;
use App\Models\BookingReceipt;
use App\Services\FareCalculator;
use Illuminate\Support\Str;

class BookingController extends Controller
{
    // === Bookings ===
    public function getBookings()
    {
        return response()->json([
            'success' => true,
            'data' => Booking::all()
        ]);
    }

    public function createBooking(Request $request)
    {
        $validated = $request->validate([
            'seats_booked' => 'nullable|integer|min:1',
            'payment_method' => 'nullable|string',
            'pickup_time' => 'nullable|string',
            'dropoff_time' => 'nullable|string',
        ]);

        $booking = Booking::create([
            'user_id' => $request->user()?->id ?? 1,
            'ride_id' => 1,
            'seats_booked' => $validated['seats_booked'] ?? 1,
            'payment_method' => $validated['payment_method'] ?? 'Commercial Bank Corp (..4082)',
            'total_fare' => 800.00,
            'status' => 'confirmed',
            'pickup_time' => $validated['pickup_time'] ?? '06:15 AM',
            'dropoff_time' => $validated['dropoff_time'] ?? '07:45 AM',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Carpool booking confirmed successfully',
            'data' => $booking
        ], 201);
    }

    public function updateBooking(Request $request, $id)
    {
        $booking = Booking::findOrFail($id);
        $booking->update($request->only(['seats_booked', 'payment_method', 'status']));

        return response()->json([
            'success' => true,
            'message' => 'Booking updated successfully',
            'data' => $booking
        ]);
    }

    public function cancelBooking($id)
    {
        $booking = Booking::findOrFail($id);
        $booking->update(['status' => 'cancelled']);

        return response()->json([
            'success' => true,
            'message' => 'Booking cancelled successfully',
            'data' => $booking
        ]);
    }

    // === Trip & Driver Tracking ===
    public function getDriverLocation($id)
    {
        $trip = BookingTrip::findOrFail($id);
        // Simulate dynamic movement
        $jitterLat = (mt_rand(-20, 20) / 100000.0);
        $jitterLng = (mt_rand(-20, 20) / 100000.0);

        return response()->json([
            'success' => true,
            'data' => [
                'trip_id' => $trip->id,
                'status' => $trip->status,
                'latitude' => $trip->driver_lat + $jitterLat,
                'longitude' => $trip->driver_lng + $jitterLng,
                'eta_minutes' => max(1, $trip->eta_minutes),
                'grace_seconds' => $trip->grace_seconds,
                'distance_km' => $trip->distance_km,
                'driver_name' => 'Kasun Silva',
                'vehicle' => 'Toyota Prius Hybrid CAB-4288',
                'phone' => '+94 77 ••• •288',
            ]
        ]);
    }

    public function boardTrip($id)
    {
        $trip = BookingTrip::findOrFail($id);
        $trip->update(['status' => 'boarded']);

        return response()->json([
            'success' => true,
            'message' => 'Boarding confirmed. Commute ride started!',
            'data' => $trip
        ]);
    }

    public function createShare($id)
    {
        $share = BookingTripShare::updateOrCreate(
            ['trip_id' => $id],
            ['share_token' => 'velune.lk/live/' . Str::random(8), 'is_active' => true]
        );

        return response()->json([
            'success' => true,
            'message' => 'Live trip tracking link created',
            'share_url' => 'https://' . $share->share_token,
            'data' => $share
        ]);
    }

    public function revokeShare($id)
    {
        $share = BookingTripShare::where('trip_id', $id)->first();
        if ($share) {
            $share->update(['is_active' => false]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Live trip tracking link revoked',
        ]);
    }

    public function createDelayReport(Request $request, $id)
    {
        $validated = $request->validate([
            'reason' => 'required|string',
            'delay_minutes' => 'nullable|integer',
        ]);

        $event = BookingTripEvent::create([
            'trip_id' => $id,
            'event_type' => 'delay_report',
            'reason' => $validated['reason'],
            'delay_minutes' => $validated['delay_minutes'] ?? 5,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Delay report dispatched to dispatch fleet',
            'data' => $event
        ], 201);
    }

    public function deleteDelayReport($id, $eventId)
    {
        $event = BookingTripEvent::where('trip_id', $id)->where('id', $eventId)->firstOrFail();
        $event->delete();

        return response()->json([
            'success' => true,
            'message' => 'Delay report withdrawn',
        ]);
    }

    public function getTelemetry($id)
    {
        $trip = BookingTrip::findOrFail($id);
        return response()->json([
            'success' => true,
            'data' => [
                'speed_kmh' => 78,
                'remaining_km' => 14.2,
                'remaining_mins' => 12,
                'accrued_fare_lkr' => 480,
                'fare_cap_lkr' => 800,
                'co2_avoided_kg' => $trip->co2_avoided_kg,
                'traffic_status' => 'Expressway Corridor: Moderate Flow',
            ]
        ]);
    }

    // === Settlement & Subsidy ===
    public function getSettlement($id)
    {
        $settlement = BookingFareSettlement::with('splits')->findOrFail($id);
        return response()->json([
            'success' => true,
            'data' => $settlement
        ]);
    }

    public function updateSettlement(Request $request, $id)
    {
        $settlement = BookingFareSettlement::findOrFail($id);
        $partial = $request->boolean('partial_calibrated');
        $dropoff = $request->input('dropoff_km', 10.5);

        if ($partial) {
            // Recalibrate using FareCalculator
            $calc = FareCalculator::calculate(2400.0, 4800.0, 600.0, 75.0, [
                ['name' => 'Amanda C. (You)', 'distance' => (float)$dropoff, 'is_current_user' => true],
                ['name' => 'Naveen K.', 'distance' => 10.2, 'is_current_user' => false],
                ['name' => 'Kirthan S.', 'distance' => 10.2, 'is_current_user' => false],
            ]);
            $settlement->update([
                'partial_calibrated' => true,
                'personal_share' => $calc['personal_share'],
            ]);
        } else {
            $settlement->update([
                'partial_calibrated' => false,
                'personal_share' => 800.00,
            ]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Journey calibrated and fare re-calculated',
            'data' => $settlement->fresh(['splits'])
        ]);
    }

    public function approveSettlement($id)
    {
        $settlement = BookingFareSettlement::findOrFail($id);
        $settlement->update(['is_approved' => true]);

        return response()->json([
            'success' => true,
            'message' => 'Corporate split fare approved and auto-debited',
            'data' => $settlement
        ]);
    }

    // === Receipts & Ratings ===
    public function getReceipt($id)
    {
        $receipt = BookingReceipt::findOrFail($id);
        return response()->json([
            'success' => true,
            'data' => $receipt
        ]);
    }

    public function saveRating(Request $request, $id)
    {
        $validated = $request->validate([
            'stars' => 'required|integer|min:1|max:5',
            'feedback_tags' => 'nullable|array',
            'comment' => 'nullable|string',
        ]);

        $rating = BookingRating::updateOrCreate(
            ['trip_id' => $id],
            [
                'stars' => $validated['stars'],
                'feedback_tags' => $validated['feedback_tags'] ?? ['Clean Car', 'On Time', 'Smooth Driving'],
                'comment' => $validated['comment'] ?? '',
            ]
        );

        return response()->json([
            'success' => true,
            'message' => 'Rating submitted successfully',
            'data' => $rating
        ]);
    }

    public function exportReceipt($id)
    {
        $receipt = BookingReceipt::findOrFail($id);
        $receipt->update(['workday_exported' => true]);

        return response()->json([
            'success' => true,
            'message' => 'Receipt exported and marked ready for Workday ERP filing',
            'data' => $receipt
        ]);
    }
}
