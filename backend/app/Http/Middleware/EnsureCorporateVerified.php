<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureCorporateVerified
{
    /**
     * Handle an incoming request.
     * Enforce authentication and Corporate Verification (Email + National ID) before booking.
     */
    public function handle(Request $request, Closure $next): Response
    {
        $user = $request->user();

        // 1. Reject requests when there is no authenticated user (do not trust payload user_id)
        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthenticated. Valid corporate authentication token required.',
                'error_code' => 'UNAUTHENTICATED',
            ], 401);
        }

        // 2. Reject users whose email_verified_at or id_verified_at is missing
        $emailVerified = !empty($user->email_verified_at);
        $idVerified = !empty($user->id_verified_at);

        if (!$emailVerified || !$idVerified) {
            return response()->json([
                'success' => false,
                'message' => 'Corporate email and Government ID certification are required before booking rides.',
                'error_code' => 'VERIFICATION_REQUIRED',
                'email_verified' => $emailVerified,
                'id_verified' => $idVerified,
            ], 403);
        }

        return $next($request);
    }
}
