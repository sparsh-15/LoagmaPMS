<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     * Removes finished_product_id and quantity_to_produce from issue_to_production.
     * Issue to Production now only handles raw materials.
     */
    public function up(): void
    {
        $constraintName = $this->getForeignKeyName();
        $tried = false;

        foreach (array_filter([$constraintName, 'fk_issue_finished_product', 'issue_to_production_finished_product_id_foreign']) as $name) {
            try {
                DB::statement("ALTER TABLE issue_to_production DROP FOREIGN KEY `{$name}`");
                $tried = true;
                break;
            } catch (\Throwable) {
                continue;
            }
        }

        $this->dropIndexIfExists('idx_issue_finished_product');

        if ($this->columnExists('issue_to_production', 'finished_product_id')) {
            Schema::table('issue_to_production', function (Blueprint $table) {
                $table->dropColumn(['finished_product_id', 'quantity_to_produce']);
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('issue_to_production', function (Blueprint $table) {
            $table->unsignedBigInteger('finished_product_id')->nullable()->after('issue_id');
            $table->decimal('quantity_to_produce', 10, 3)->default(0)->after('finished_product_id');

            $table->foreign('finished_product_id', 'fk_issue_finished_product')
                ->references('product_id')
                ->on('product');
        });

        Schema::table('issue_to_production', function (Blueprint $table) {
            $table->index('finished_product_id', 'idx_issue_finished_product');
        });
    }

    private function getForeignKeyName(): ?string
    {
        $result = DB::selectOne(
            "SELECT CONSTRAINT_NAME FROM information_schema.KEY_COLUMN_USAGE
             WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'issue_to_production'
             AND COLUMN_NAME = 'finished_product_id' AND REFERENCED_TABLE_NAME IS NOT NULL
             LIMIT 1"
        );

        if (!$result) {
            return null;
        }
        $name = $result->CONSTRAINT_NAME ?? $result->constraint_name ?? null;
        return is_string($name) ? $name : null;
    }

    private function dropIndexIfExists(string $indexName): void
    {
        try {
            DB::statement("ALTER TABLE issue_to_production DROP INDEX `{$indexName}`");
        } catch (\Throwable $e) {
            if (!str_contains($e->getMessage(), '1091') && !str_contains($e->getMessage(), 'check that it exists')) {
                throw $e;
            }
        }
    }

    private function columnExists(string $table, string $column): bool
    {
        $result = DB::selectOne(
            "SELECT 1 FROM information_schema.COLUMNS
             WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND COLUMN_NAME = ?
             LIMIT 1",
            [$table, $column]
        );
        return $result !== null;
    }
};
