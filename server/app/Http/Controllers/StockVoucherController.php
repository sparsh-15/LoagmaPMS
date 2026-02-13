<?php

namespace App\Http\Controllers;

use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;

class StockVoucherController extends Controller
{
    public function index(): JsonResponse
    {
        try {
            $vouchers = DB::table('stock_voucher')
                ->select('id', 'voucher_type', 'status', 'voucher_date', 'remarks', 'posted_at', 'created_at', 'updated_at')
                ->orderBy('created_at', 'desc')
                ->get();

            $result = $vouchers->map(function ($voucher) {
                $items = DB::table('stock_voucher_items as svi')
                    ->join('product as p', 'svi.product_id', '=', 'p.product_id')
                    ->where('svi.voucher_id', $voucher->id)
                    ->select('p.name')
                    ->limit(3)
                    ->pluck('name');
                $count = DB::table('stock_voucher_items')
                    ->where('voucher_id', $voucher->id)
                    ->count();
                $voucher->items_count = $count;
                $voucher->items_preview = $items->implode(', ');
                return $voucher;
            });

            return response()->json([
                'success' => true,
                'data' => $result
            ]);
        } catch (\Exception $e) {
            Log::error('Stock voucher list failed', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch vouchers',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function show($id): JsonResponse
    {
        try {
            $voucher = DB::table('stock_voucher')
                ->where('id', $id)
                ->first();

            if (!$voucher) {
                return response()->json([
                    'success' => false,
                    'message' => 'Voucher not found'
                ], 404);
            }

            $items = DB::table('stock_voucher_items as svi')
                ->join('product as p', 'svi.product_id', '=', 'p.product_id')
                ->where('svi.voucher_id', $id)
                ->select('svi.id as item_id', 'svi.product_id', 'p.name as product_name', 'svi.quantity', 'svi.unit_type')
                ->get();

            return response()->json([
                'success' => true,
                'data' => [
                    'voucher' => $voucher,
                    'items' => $items
                ]
            ]);
        } catch (\Exception $e) {
            Log::error('Stock voucher fetch failed', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'message' => 'Failed to fetch voucher',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function store(Request $request): JsonResponse
    {
        try {
            $validator = Validator::make($request->all(), [
                'voucher_type' => 'required|in:IN,OUT',
                'status' => 'required|in:DRAFT,POSTED',
                'voucher_date' => 'nullable|date',
                'remarks' => 'nullable|string',
                'items' => 'required|array|min:1',
                'items.*.product_id' => 'required|integer|exists:product,product_id',
                'items.*.quantity' => 'required|numeric|min:0.001',
                'items.*.unit_type' => 'required|string|max:20',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validation failed',
                    'errors' => $validator->errors()
                ], 422);
            }

            DB::beginTransaction();

            $voucherId = DB::table('stock_voucher')->insertGetId([
                'voucher_type' => $request->voucher_type,
                'status' => $request->status,
                'voucher_date' => $request->voucher_date ?: now()->format('Y-m-d'),
                'remarks' => $request->remarks,
                'posted_at' => $request->status === 'POSTED' ? now() : null,
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            foreach ($request->items as $item) {
                DB::table('stock_voucher_items')->insert([
                    'voucher_id' => $voucherId,
                    'product_id' => $item['product_id'],
                    'quantity' => $item['quantity'],
                    'unit_type' => $item['unit_type'],
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Stock voucher created successfully',
                'data' => ['voucher_id' => $voucherId, 'status' => $request->status]
            ], 201);
        } catch (\Exception $e) {
            DB::rollBack();
            Log::error('Stock voucher creation failed', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'message' => 'Failed to create voucher',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    public function update(Request $request, $id): JsonResponse
    {
        try {
            $validator = Validator::make($request->all(), [
                'voucher_type' => 'required|in:IN,OUT',
                'status' => 'required|in:DRAFT,POSTED',
                'voucher_date' => 'nullable|date',
                'remarks' => 'nullable|string',
                'items' => 'required|array|min:1',
                'items.*.product_id' => 'required|integer|exists:product,product_id',
                'items.*.quantity' => 'required|numeric|min:0.001',
                'items.*.unit_type' => 'required|string|max:20',
            ]);

            if ($validator->fails()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validation failed',
                    'errors' => $validator->errors()
                ], 422);
            }

            $existing = DB::table('stock_voucher')->where('id', $id)->first();
            if (!$existing) {
                return response()->json([
                    'success' => false,
                    'message' => 'Voucher not found'
                ], 404);
            }

            DB::beginTransaction();

            DB::table('stock_voucher')
                ->where('id', $id)
                ->update([
                    'voucher_type' => $request->voucher_type,
                    'status' => $request->status,
                    'voucher_date' => $request->voucher_date ?: $existing->voucher_date,
                    'remarks' => $request->remarks,
                    'posted_at' => $request->status === 'POSTED' && !$existing->posted_at
                        ? now()
                        : $existing->posted_at,
                    'updated_at' => now(),
                ]);

            DB::table('stock_voucher_items')->where('voucher_id', $id)->delete();

            foreach ($request->items as $item) {
                DB::table('stock_voucher_items')->insert([
                    'voucher_id' => $id,
                    'product_id' => $item['product_id'],
                    'quantity' => $item['quantity'],
                    'unit_type' => $item['unit_type'],
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Stock voucher updated successfully',
                'data' => ['voucher_id' => (int) $id, 'status' => $request->status]
            ]);
        } catch (\Exception $e) {
            DB::rollBack();
            Log::error('Stock voucher update failed', ['error' => $e->getMessage()]);
            return response()->json([
                'success' => false,
                'message' => 'Failed to update voucher',
                'error' => $e->getMessage()
            ], 500);
        }
    }
}
