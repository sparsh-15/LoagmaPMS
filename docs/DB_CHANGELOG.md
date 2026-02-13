# Database Changelog

## 2025-02-13 – Issue to Production: Raw Materials Only

### Summary
Issue to Production no longer links to a finished product. It only tracks raw materials being issued to production. Receive from Production continues to handle finished goods.

### Migration
**File:** `server/database/migrations/2025_02_13_000000_remove_finished_product_from_issue_to_production.php`

**Run:**
```bash
cd server && php artisan migrate
```

### Changes

| Table | Action |
|-------|--------|
| `issue_to_production` | Drop column `finished_product_id` |
| `issue_to_production` | Drop column `quantity_to_produce` |
| `issue_to_production` | Drop foreign key `fk_issue_finished_product` (or auto-detected name) |
| `issue_to_production` | Drop index `idx_issue_finished_product` |

### Rollback
```bash
php artisan migrate:rollback
```
Restores `finished_product_id` and `quantity_to_produce` (nullable/default values for rollback safety).

### Manual SQL (if migration fails)
If Laravel migration fails, run the v2 script:
```bash
mysql -u root -p loagma_new < docs/issue_to_production_migration_remove_finished_v2.sql
```

---

## 2025-02-13 – Receive from Production: Multiple Items

### Summary
Receive from Production now supports adding multiple finished products per receive record (same pattern as Issue to Production).

### Migration
**File:** `server/database/migrations/2025_02_13_000001_create_receive_from_production_tables.php`

**Run:**
```bash
cd server && php artisan migrate
```

### New Tables

| Table | Description |
|-------|-------------|
| `receive_from_production` | Master record (status, remarks, received_at) |
| `receive_from_production_items` | Line items (finished_product_id, quantity, unit_type) |

---

## 2025-02-13 – Stock Voucher

### Summary
Stock voucher module for recording stock IN and stock OUT with multiple items.

### Migration
**File:** `server/database/migrations/2025_02_13_000002_create_stock_voucher_tables.php`

**Run:**
```bash
cd server && php artisan migrate
```

### New Tables

| Table | Description |
|-------|-------------|
| `stock_voucher` | Master (voucher_type IN/OUT, status, voucher_date, remarks) |
| `stock_voucher_items` | Line items (product_id, quantity, unit_type) |
