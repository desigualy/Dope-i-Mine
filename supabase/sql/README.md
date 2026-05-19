# Phase 3 SQL Contract Tests

Run these only against a disposable local database or a staging Supabase project after migrations are applied.

```bash
psql "$SUPABASE_DB_URL" -v ON_ERROR_STOP=1 -f supabase/sql/phase3_caregiver_rls_contract_tests.sql
psql "$SUPABASE_DB_URL" -v ON_ERROR_STOP=1 -f supabase/sql/phase3_body_double_rls_contract_tests.sql
```

The scripts check schema/RLS contracts. They do not seed production data and they wrap checks in a transaction that rolls back.
