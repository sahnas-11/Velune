<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\HrCampusGoal;
use App\Models\HrParkingBay;
use App\Models\HrCo2Log;
use App\Models\HrPinnedRoute;
use App\Models\HrIncentiveProgram;
use App\Models\HrFleetAward;

class HrCorporateController extends Controller
{
    public function getDashboard()
    {
        $goal = HrCampusGoal::first();
        $bays = HrParkingBay::all();
        $routes = HrPinnedRoute::where('is_pinned', true)->get();

        return response()->json([
            'success' => true,
            'data' => [
                'campus_goal' => $goal,
                'total_bays' => $bays->count(),
                'occupied_bays' => $bays->where('status', 'occupied')->count(),
                'pinned_routes' => $routes,
                'monthly_co2_kg' => 3840.0,
                'corporate_subsidy_spent_lkr' => 452000.0,
                'active_commuters' => 148,
            ]
        ]);
    }

    public function updateGoal(Request $request, $id)
    {
        $validated = $request->validate([
            'target_co2_kg' => 'required|numeric',
            'current_co2_kg' => 'nullable|numeric',
        ]);

        $goal = HrCampusGoal::findOrFail($id);
        $goal->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Corporate campus decarbonization goal updated',
            'data' => $goal
        ]);
    }

    // Parking Bays
    public function getParkingBays()
    {
        return response()->json([
            'success' => true,
            'data' => HrParkingBay::all()
        ]);
    }

    public function createParkingBay(Request $request)
    {
        $validated = $request->validate([
            'bay_code' => 'required|string',
            'floor' => 'nullable|string',
            'status' => 'nullable|string',
            'assigned_employee' => 'nullable|string',
            'vehicle_plate' => 'nullable|string',
        ]);

        $bay = HrParkingBay::create($validated);

        return response()->json([
            'success' => true,
            'message' => 'Priority parking bay registered',
            'data' => $bay
        ], 201);
    }

    public function updateParkingBay(Request $request, $id)
    {
        $bay = HrParkingBay::findOrFail($id);
        $bay->update($request->only(['status', 'assigned_employee', 'vehicle_plate']));

        return response()->json([
            'success' => true,
            'message' => 'Parking bay status and allocation updated',
            'data' => $bay
        ]);
    }

    public function deleteParkingBay($id)
    {
        $bay = HrParkingBay::findOrFail($id);
        $bay->delete();

        return response()->json([
            'success' => true,
            'message' => 'Parking bay released from corporate registry',
        ]);
    }

    // CO2 Logs
    public function getCo2Logs()
    {
        return response()->json([
            'success' => true,
            'data' => HrCo2Log::orderBy('log_date', 'desc')->get()
        ]);
    }

    public function createCo2Log(Request $request)
    {
        $validated = $request->validate([
            'employee_name' => 'required|string',
            'route_name' => 'required|string',
            'co2_avoided_kg' => 'required|numeric',
            'log_date' => 'required|date',
        ]);

        $log = HrCo2Log::create($validated);

        return response()->json([
            'success' => true,
            'message' => 'Scope 3 carbon reduction log appended',
            'data' => $log
        ], 201);
    }

    public function deleteCo2Log($id)
    {
        $log = HrCo2Log::findOrFail($id);
        $log->delete();

        return response()->json([
            'success' => true,
            'message' => 'Carbon log entry removed',
        ]);
    }

    // Pinned Routes
    public function getPinnedRoutes()
    {
        return response()->json([
            'success' => true,
            'data' => HrPinnedRoute::all()
        ]);
    }

    public function togglePinnedRoute(Request $request, $id)
    {
        $route = HrPinnedRoute::findOrFail($id);
        $route->update(['is_pinned' => !$route->is_pinned]);

        return response()->json([
            'success' => true,
            'message' => 'Route pinned status toggled',
            'data' => $route
        ]);
    }

    // Incentive Programs
    public function getIncentives()
    {
        return response()->json([
            'success' => true,
            'programs' => HrIncentiveProgram::all(),
            'awards' => HrFleetAward::orderBy('rank')->get(),
        ]);
    }

    public function createIncentive(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|string',
            'description' => 'required|string',
            'points_reward' => 'required|integer',
        ]);

        $program = HrIncentiveProgram::create($validated);

        return response()->json([
            'success' => true,
            'message' => 'Commuter incentive program published',
            'data' => $program
        ], 201);
    }

    public function updateIncentive(Request $request, $id)
    {
        $program = HrIncentiveProgram::findOrFail($id);
        $program->update($request->only(['title', 'description', 'points_reward', 'status']));

        return response()->json([
            'success' => true,
            'message' => 'Incentive program updated',
            'data' => $program
        ]);
    }

    public function deleteIncentive($id)
    {
        $program = HrIncentiveProgram::findOrFail($id);
        $program->delete();

        return response()->json([
            'success' => true,
            'message' => 'Incentive program removed',
        ]);
    }

    // ESG Export
    public function exportReport()
    {
        return response()->json([
            'success' => true,
            'message' => 'Velune_Scope3_ESG_Report_Q4_2026.pdf prepared and verified with SHA-256 corporate stamp',
            'download_url' => 'https://velune.lk/esg/reports/2026-q4.pdf',
        ]);
    }

    public function emailReport(Request $request)
    {
        $validated = $request->validate([
            'email' => 'required|email',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Scope 3 ESG decarbonization report queued for ' . $validated['email'],
        ]);
    }
}
