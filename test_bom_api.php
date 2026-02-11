<?php
/**
 * Test BOM API endpoints
 * Run: php test_bom_api.php
 */

require __DIR__ . '/server/vendor/autoload.php';

// Bootstrap Laravel
$app = require_once __DIR__ . '/server/bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

echo "Testing BOM API...\n\n";

// Test 1: Get unit types
echo "1. Testing GET /api/unit-types\n";
try {
    $controller = new \App\Http\Controllers\BomController();
    $response = $controller->getUnitTypes();
    $data = json_decode($response->getContent(), true);
    
    if ($data['success']) {
        echo "   ✅ Unit types fetched: " . count($data['data']) . " types\n";
        echo "   Types: " . implode(', ', array_slice($data['data'], 0, 10)) . "\n";
    } else {
        echo "   ❌ Failed: " . $data['message'] . "\n";
    }
} catch (Exception $e) {
    echo "   ❌ Error: " . $e->getMessage() . "\n";
}

echo "\n2. Testing POST /api/boms (Create BOM)\n";
try {
    // Create a test BOM
    $testData = [
        'product_id' => 2048, // Gold Drop Sunflower Oil
        'bom_version' => 'TEST-v1.0',
        'status' => 'DRAFT',
        'remarks' => 'Test BOM created via API',
        'raw_materials' => [
            [
                'raw_material_id' => 2050,
                'quantity_per_unit' => 1.5,
                'unit_type' => 'KG',
                'wastage_percent' => 2.5,
            ],
            [
                'raw_material_id' => 2051,
                'quantity_per_unit' => 0.5,
                'unit_type' => 'LTR',
                'wastage_percent' => 1.0,
            ],
        ],
    ];

    $request = \Illuminate\Http\Request::create(
        '/api/boms',
        'POST',
        $testData
    );

    $controller = new \App\Http\Controllers\BomController();
    $response = $controller->store($request);
    $data = json_decode($response->getContent(), true);
    
    if ($data['success']) {
        echo "   ✅ BOM created successfully\n";
        echo "   BOM ID: " . $data['data']['bom_id'] . "\n";
        echo "   Version: " . $data['data']['bom_version'] . "\n";
        echo "   Status: " . $data['data']['status'] . "\n";
        
        $bomId = $data['data']['bom_id'];
        
        // Test 3: Get BOM details
        echo "\n3. Testing GET /api/boms/{id}\n";
        $response = $controller->show($bomId);
        $data = json_decode($response->getContent(), true);
        
        if ($data['success']) {
            echo "   ✅ BOM fetched successfully\n";
            echo "   Product: " . $data['data']['bom']->product_name . "\n";
            echo "   Items: " . count($data['data']['items']) . " raw materials\n";
        }
        
        // Cleanup: Delete test BOM
        echo "\n4. Cleaning up test data...\n";
        \Illuminate\Support\Facades\DB::table('bom_items')->where('bom_id', $bomId)->delete();
        \Illuminate\Support\Facades\DB::table('bom_master')->where('bom_id', $bomId)->delete();
        echo "   ✅ Test BOM deleted\n";
        
    } else {
        echo "   ❌ Failed: " . $data['message'] . "\n";
        if (isset($data['errors'])) {
            print_r($data['errors']);
        }
    }
} catch (Exception $e) {
    echo "   ❌ Error: " . $e->getMessage() . "\n";
}

echo "\n✅ All tests completed!\n";
