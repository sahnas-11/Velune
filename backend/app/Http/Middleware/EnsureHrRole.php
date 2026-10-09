<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureHrRole
{
    /**
     * Handle an incoming request.
     */
    public function handle(Request $request, Closure $next): Response
    {
        if (!$request->user() || $request->user()->role !== 'hr_manager') {
            return response()->json([
                'message' => 'Forbidden. Corporate HR role required.',
            ], 403);
        }

        return $next($request);
    }
}
