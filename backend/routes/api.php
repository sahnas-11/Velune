<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\BookingController;
use App\Http\Controllers\EmergencyController;
use App\Http\Controllers\HrCorporateController;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\DiscoveryRidesController;

Route::get('/user', function (Request $request) {
    return $request->user();
})->middleware('auth:sanctum');

// ==========================================
// === Auth & Corporate Verification (Module 1) ===
// ==========================================
Route::prefix('auth')->group(function () {
    Route::post('/request-otp', [AuthController::class, 'requestOtp']);
    Route::post('/verify-otp', [AuthController::class, 'verifyOtp']);
    Route::post('/resend-otp', [AuthController::class, 'resendOtp']);
    Route::post('/government-id', [AuthController::class, 'submitGovernmentId']);
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/forgot-password', [AuthController::class, 'forgotPassword']);
    Route::post('/login', [AuthController::class, 'login']);
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);
});

Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);

// ==========================================
// === Commuter Ride Discovery (Module 1) ===
// ==========================================
Route::get('/locations', [DiscoveryRidesController::class, 'getLocations']);
Route::get('/home', [DiscoveryRidesController::class, 'getHomeFeed']);
Route::get('/rides/search', [DiscoveryRidesController::class, 'searchRides']);
Route::get('/rides/{id}', [DiscoveryRidesController::class, 'getRideDetails']);
Route::post('/rides/{id}/bookmark', [DiscoveryRidesController::class, 'bookmarkRide']);
Route::delete('/rides/{id}/bookmark', [DiscoveryRidesController::class, 'unbookmarkRide']);
Route::post('/rides/{id}/report', [DiscoveryRidesController::class, 'reportRide']);
Route::put('/rides/{id}/report', [DiscoveryRidesController::class, 'updateReport']);
Route::delete('/rides/{id}/report', [DiscoveryRidesController::class, 'deleteReport']);

Route::get('/saved-searches', [DiscoveryRidesController::class, 'getSavedSearches']);
Route::post('/saved-searches', [DiscoveryRidesController::class, 'createSavedSearch']);
Route::put('/saved-searches/{id}', [DiscoveryRidesController::class, 'updateSavedSearch']);
Route::delete('/saved-searches/{id}', [DiscoveryRidesController::class, 'deleteSavedSearch']);

Route::get('/saved-routes', [DiscoveryRidesController::class, 'getSavedRoutes']);
Route::post('/saved-routes', [DiscoveryRidesController::class, 'createSavedRoute']);
Route::delete('/saved-routes/{id}', [DiscoveryRidesController::class, 'deleteSavedRoute']);

Route::delete('/notices/{id}', [DiscoveryRidesController::class, 'dismissNotice']);
Route::put('/notifications/read', [DiscoveryRidesController::class, 'markNotificationsRead']);

// ==========================================
// === Booking, Live Tracking & Fare Module ===
// ==========================================
Route::prefix('booking')->group(function () {
    Route::get('/bookings', [BookingController::class, 'getBookings']);
    Route::post('/bookings', [BookingController::class, 'createBooking']);
    Route::put('/bookings/{id}', [BookingController::class, 'updateBooking']);
    Route::delete('/bookings/{id}', [BookingController::class, 'cancelBooking']);

    Route::get('/trips/{id}/driver-location', [BookingController::class, 'getDriverLocation']);
    Route::put('/trips/{id}/board', [BookingController::class, 'boardTrip']);
    Route::post('/trips/{id}/share', [BookingController::class, 'createShare']);
    Route::delete('/trips/{id}/share', [BookingController::class, 'revokeShare']);
    Route::post('/trips/{id}/delay-reports', [BookingController::class, 'createDelayReport']);
    Route::delete('/trips/{id}/delay-reports/{eventId}', [BookingController::class, 'deleteDelayReport']);
    Route::get('/trips/{id}/telemetry', [BookingController::class, 'getTelemetry']);

    Route::get('/settlements/{id}', [BookingController::class, 'getSettlement']);
    Route::put('/settlements/{id}', [BookingController::class, 'updateSettlement']);
    Route::post('/settlements/{id}/approve', [BookingController::class, 'approveSettlement']);

    Route::get('/receipts/{id}', [BookingController::class, 'getReceipt']);
    Route::post('/receipts/{id}/rating', [BookingController::class, 'saveRating']);
    Route::put('/receipts/{id}/rating', [BookingController::class, 'saveRating']);
    Route::post('/receipts/{id}/export', [BookingController::class, 'exportReceipt']);
});

// ==========================================
// === Emergency Breakdown & Fleet Dispatch ===
// ==========================================
Route::prefix('emergency')->group(function () {
    Route::get('/active-ride', [EmergencyController::class, 'getActiveRide']);
    Route::post('/active-ride/share', [EmergencyController::class, 'shareActiveRide']);
    Route::delete('/active-ride/share', [EmergencyController::class, 'stopShareActiveRide']);

    Route::get('/incidents', [EmergencyController::class, 'getMechanicQueue']);
    Route::post('/incidents', [EmergencyController::class, 'createIncident']);
    Route::get('/incidents/{id}', [EmergencyController::class, 'getIncident']);
    Route::put('/incidents/{id}', [EmergencyController::class, 'updateIncident']);
    Route::delete('/incidents/{id}', [EmergencyController::class, 'cancelIncident']);
    Route::get('/incidents/{id}/status', [EmergencyController::class, 'getIncidentStatus']);
    Route::post('/incidents/{id}/messages', [EmergencyController::class, 'sendMessage']);

    // Mechanic actions
    Route::put('/incidents/{id}/accept', [EmergencyController::class, 'acceptIncident']);
    Route::put('/incidents/{id}/decline', [EmergencyController::class, 'declineIncident']);
    Route::put('/incidents/{id}/priority', [EmergencyController::class, 'updatePriority']);
    Route::put('/incidents/{id}/status', [EmergencyController::class, 'updateStatus']);
    Route::delete('/incidents/{id}/archive', [EmergencyController::class, 'archiveIncident']);

    // Technician notes & diagnostics
    Route::post('/incidents/{id}/notes', [EmergencyController::class, 'addNote']);
    Route::delete('/incidents/{id}/notes/{noteId}', [EmergencyController::class, 'deleteNote']);
    Route::post('/incidents/{id}/diagnostics', [EmergencyController::class, 'addDiagnostic']);
    Route::delete('/incidents/{id}/diagnostics/{diagId}', [EmergencyController::class, 'deleteDiagnostic']);
});

// ==========================================
// === HR Corporate & System Integration   ===
// ==========================================
Route::prefix('hr')->group(function () {
    Route::get('/dashboard', [HrCorporateController::class, 'getDashboard']);
    Route::put('/goals/{id}', [HrCorporateController::class, 'updateGoal']);

    Route::get('/parking-bays', [HrCorporateController::class, 'getParkingBays']);
    Route::post('/parking-bays', [HrCorporateController::class, 'createParkingBay']);
    Route::put('/parking-bays/{id}', [HrCorporateController::class, 'updateParkingBay']);
    Route::delete('/parking-bays/{id}', [HrCorporateController::class, 'deleteParkingBay']);

    Route::get('/co2-logs', [HrCorporateController::class, 'getCo2Logs']);
    Route::post('/co2-logs', [HrCorporateController::class, 'createCo2Log']);
    Route::delete('/co2-logs/{id}', [HrCorporateController::class, 'deleteCo2Log']);

    Route::get('/pinned-routes', [HrCorporateController::class, 'getPinnedRoutes']);
    Route::post('/pinned-routes/{id}/toggle', [HrCorporateController::class, 'togglePinnedRoute']);

    Route::get('/incentives', [HrCorporateController::class, 'getIncentives']);
    Route::post('/incentives', [HrCorporateController::class, 'createIncentive']);
    Route::put('/incentives/{id}', [HrCorporateController::class, 'updateIncentive']);
    Route::delete('/incentives/{id}', [HrCorporateController::class, 'deleteIncentive']);

    Route::post('/reports/export', [HrCorporateController::class, 'exportReport']);
    Route::post('/reports/email', [HrCorporateController::class, 'emailReport']);
});
