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
        Schema::create('stock_voucher', function (Blueprint $table) {
            $table->id();
            $table->enum('voucher_type', ['IN', 'OUT'])->default('IN');
            $table->enum('status', ['DRAFT', 'POSTED'])->default('DRAFT');
            $table->date('voucher_date')->nullable();
            $table->text('remarks')->nullable();
            $table->datetime('posted_at')->nullable();
            $table->timestamps();
        });

        Schema::create('stock_voucher_items', function (Blueprint $table) {
            $table->id();
            $table->unsignedBigInteger('voucher_id');
            $table->unsignedBigInteger('product_id');
            $table->decimal('quantity', 10, 3);
            $table->string('unit_type', 20);
            $table->timestamps();

            $table->foreign('voucher_id')
                ->references('id')
                ->on('stock_voucher')
                ->onDelete('cascade');
            $table->foreign('product_id')
                ->references('product_id')
                ->on('product');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('stock_voucher_items');
        Schema::dropIfExists('stock_voucher');
    }
};
