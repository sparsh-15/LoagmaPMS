-- Migration: Remove finished product from Issue to Production (auto-detect FK name)
-- Run this if the standard migration fails with "Cannot drop column: needed in a foreign key constraint"

-- Step 1: Drop foreign key using dynamic SQL (finds the actual constraint name)
SET @constraint_name = (
    SELECT CONSTRAINT_NAME
    FROM information_schema.KEY_COLUMN_USAGE
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = 'issue_to_production'
      AND COLUMN_NAME = 'finished_product_id'
      AND REFERENCED_TABLE_NAME IS NOT NULL
    LIMIT 1
);

SET @sql = CONCAT('ALTER TABLE issue_to_production DROP FOREIGN KEY ', @constraint_name);
PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- Step 2: Drop index if exists (MySQL 8.0+)
-- Skip this if you get an error; the index may already be removed with the FK
ALTER TABLE issue_to_production DROP INDEX IF EXISTS idx_issue_finished_product;

-- Step 3: Remove columns
ALTER TABLE issue_to_production
    DROP COLUMN finished_product_id,
    DROP COLUMN quantity_to_produce;
