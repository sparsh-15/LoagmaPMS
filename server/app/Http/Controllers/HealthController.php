<?php

namespace App\Http\Controllers;

use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;

class HealthController extends Controller
{
    /**
     * Handle the incoming request.
     */
    public function __invoke(): JsonResponse
    {
        $dbStatus = 'unknown';
        $dbError = null;

        try {
            DB::connection()->getPdo();
            $dbStatus = 'up';
        } catch (\Throwable $e) {
            $dbStatus = 'down';
            $dbError = $e->getMessage();
        }

        return response()->json([
            'status' => 'ok',
            'service' => config('app.name', 'LoagmaPMS API'),
            'timestamp' => now()->toIso8601String(),
            'database' => [
                'status' => $dbStatus,
                'connection' => config('database.default'),
                'error' => $dbError,
            ],
        ]);
    }
}

