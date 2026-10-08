<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\DiscoveryLocation;
use App\Models\DiscoveryRide;
use App\Models\DiscoverySavedSearch;
use App\Models\DiscoverySavedRoute;
use App\Models\DiscoveryBookmark;
use App\Models\DiscoveryRideReport;
use App\Models\DiscoveryNotice;
use App\Models\DiscoveryNotification;
use Carbon\Carbon;

class DiscoveryRidesController extends Controller
{
    /**
     * Seeded locations for autocomplete
     */
    public function getLocations()
    {
        return response()->json([
            'success' => true,
            'data' => DiscoveryLocation::all(),
        ]);
    }

    /**
     * Commuter Home Feed (HF-03)
     */
    public function getHomeFeed(Request $request)
    {
        $upcomingRide = DiscoveryRide::where('id', 1)->first();
        $notices = DiscoveryNotice::whereNull('dismissed_at')->get();
        $unreadCount = DiscoveryNotification::whereNull('read_at')->count();
        $savedRoutes = DiscoverySavedRoute::all();

        return response()->json([
            'success' => true,
            'data' => [
                'user' => [
                    'name' => 'Jay',
                    'first_name' => 'Jay',
                    'role' => 'commuter',
                ],
                'upcoming_ride' => $upcomingRide ? [
                    'id' => $upcomingRide->id,
                    'status' => 'Confirmed',
                    'departure_time' => 'Tomorrow 8:00 AM',
                    'from' => 'Matara',
                    'to' => 'Colombo Corporate HQ',
                    'pickup_spot' => 'Pickup at 8:00 AM',
                    'estimated_arrival' => 'Est. arrival: 9:30 AM',
                    'route_tag' => 'Direct Express',
                    'driver_name' => $upcomingRide->driver_name,
                    'driver_rating' => $upcomingRide->driver_rating,
                    'seats_reserved' => 1,
                    'fare_estimate' => 'Rs. 450',
                ] : null,
                'notices' => $notices,
                'unread_notifications' => $unreadCount,
                'saved_routes' => $savedRoutes,
            ]
        ]);
    }

    /**
     * Search available rides (HF-04, HF-05)
     */
    public function searchRides(Request $request)
    {
        $query = DiscoveryRide::query();

        if ($request->filled('from')) {
            $from = $request->from;
            $query->where('from_location', 'like', "%{$from}%");
        }

        if ($request->filled('to')) {
            $to = $request->to;
            $query->where('to_location', 'like', "%{$to}%");
        }

        if ($request->boolean('verified_only')) {
            $query->where('verified_only', true);
        }

        // Sorting
        $sort = $request->input('sort', 'time');
        if ($sort === 'price') {
            $query->orderBy('price', 'asc');
        } elseif ($sort === 'rating') {
            $query->orderBy('driver_rating', 'desc');
        } else {
            $query->orderBy('departure_time', 'asc');
        }

        $rides = $query->get();

        return response()->json([
            'success' => true,
            'count' => $rides->count(),
            'search_summary' => 'Matara -> Colombo • 18 Sep',
            'data' => $rides,
        ]);
    }

    /**
     * Ride Details (HF-06)
     */
    public function getRideDetails($id)
    {
        $ride = DiscoveryRide::findOrFail($id);
        $isBookmarked = DiscoveryBookmark::where('ride_id', $id)->exists();

        return response()->json([
            'success' => true,
            'data' => array_merge($ride->toArray(), [
                'is_bookmarked' => $isBookmarked,
                'driver_phone_masked' => '+94 77 ••• •288',
                'booking_route' => "/booking/confirm/{$ride->id}",
            ]),
        ]);
    }

    // === Saved Searches CRUD ===
    public function getSavedSearches()
    {
        return response()->json([
            'success' => true,
            'data' => DiscoverySavedSearch::all(),
        ]);
    }

    public function createSavedSearch(Request $request)
    {
        $validated = $request->validate([
            'from_location' => 'required|string',
            'to_location' => 'required|string',
            'preferred_time' => 'nullable|string',
        ]);

        $search = DiscoverySavedSearch::create([
            'user_id' => $request->user()?->id ?? 1,
            'from_location' => $validated['from_location'],
            'to_location' => $validated['to_location'],
            'preferred_time' => $validated['preferred_time'] ?? '08:00 AM',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Commute search preferences saved',
            'data' => $search,
        ], 201);
    }

    public function updateSavedSearch(Request $request, $id)
    {
        $search = DiscoverySavedSearch::findOrFail($id);
        $search->update($request->only(['from_location', 'to_location', 'preferred_time']));

        return response()->json([
            'success' => true,
            'message' => 'Saved search updated',
            'data' => $search,
        ]);
    }

    public function deleteSavedSearch($id)
    {
        $search = DiscoverySavedSearch::findOrFail($id);
        $search->delete();

        return response()->json([
            'success' => true,
            'message' => 'Saved search removed',
        ]);
    }

    // === Saved Routes CRUD ===
    public function getSavedRoutes()
    {
        return response()->json([
            'success' => true,
            'data' => DiscoverySavedRoute::all(),
        ]);
    }

    public function createSavedRoute(Request $request)
    {
        $validated = $request->validate([
            'title' => 'nullable|string',
            'from_location' => 'required|string',
            'to_location' => 'required|string',
        ]);

        $route = DiscoverySavedRoute::create([
            'user_id' => $request->user()?->id ?? 1,
            'title' => $validated['title'] ?? 'Daily Expressway Commute',
            'from_location' => $validated['from_location'],
            'to_location' => $validated['to_location'],
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Route pinned to favourite commutes',
            'data' => $route,
        ], 201);
    }

    public function deleteSavedRoute($id)
    {
        $route = DiscoverySavedRoute::findOrFail($id);
        $route->delete();

        return response()->json([
            'success' => true,
            'message' => 'Route unpinned from favourites',
        ]);
    }

    // === Bookmarks CRUD ===
    public function bookmarkRide(Request $request, $id)
    {
        $bookmark = DiscoveryBookmark::firstOrCreate([
            'user_id' => $request->user()?->id ?? 1,
            'ride_id' => $id,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Ride added to bookmarked commutes',
            'data' => $bookmark,
        ]);
    }

    public function unbookmarkRide(Request $request, $id)
    {
        DiscoveryBookmark::where('ride_id', $id)->delete();

        return response()->json([
            'success' => true,
            'message' => 'Ride removed from bookmarks',
        ]);
    }

    // === Ride Reports CRUD ===
    public function reportRide(Request $request, $id)
    {
        $validated = $request->validate([
            'reason' => 'required|string',
            'details' => 'nullable|string',
        ]);

        $report = DiscoveryRideReport::create([
            'user_id' => $request->user()?->id ?? 1,
            'ride_id' => $id,
            'reason' => $validated['reason'],
            'details' => $validated['details'] ?? '',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Report submitted to corporate trust and safety',
            'data' => $report,
        ], 201);
    }

    public function updateReport(Request $request, $id)
    {
        $report = DiscoveryRideReport::where('ride_id', $id)->latest()->firstOrFail();
        $report->update($request->only(['reason', 'details']));

        return response()->json([
            'success' => true,
            'message' => 'Report updated',
            'data' => $report,
        ]);
    }

    public function deleteReport($id)
    {
        DiscoveryRideReport::where('ride_id', $id)->delete();

        return response()->json([
            'success' => true,
            'message' => 'Report withdrawn',
        ]);
    }

    // === Notice Dismissal & Notifications ===
    public function dismissNotice($id)
    {
        $notice = DiscoveryNotice::findOrFail($id);
        $notice->update(['dismissed_at' => Carbon::now()]);

        return response()->json([
            'success' => true,
            'message' => 'Notice dismissed',
        ]);
    }

    public function markNotificationsRead()
    {
        DiscoveryNotification::whereNull('read_at')->update(['read_at' => Carbon::now()]);

        return response()->json([
            'success' => true,
            'message' => 'All notifications marked as read',
        ]);
    }
}
