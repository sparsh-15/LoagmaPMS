<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('receive_from_production', function (Blueprint $table) {
            $table->id();
            $table->enum('status', ['DRAFT', 'RECEIVED'])->default('DRAFT');
            $table->text('remarks')->nullable();
            $table->datetime('received_at')->nullable();
            $table->timestamps();
        });

        Schema::create('receive_from_production_items', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('receive_id');
            $table->unsignedBigInteger('finished_product_id');
            $table->decimal('quantity', 10, 3);
            $table->string('unit_type', 20);
            $table->timestamps();

            $table->foreign('receive_id')
                ->references('id')
                ->on('receive_from_production')
                ->onDelete('cascade');
            $table->foreign('finished_product_id')
                ->references('product_id')
                ->on('product');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('receive_from_production_items');
        Schema::dropIfExists('receive_from_production');
    }
};
