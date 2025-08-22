-- Langkah 1: Membersihkan kolom finansial di tabel users
-- Mengubah kolom dari TEXT menjadi NUMERIC setelah menghapus simbol '$'
ALTER TABLE users
    ALTER COLUMN per_capita_income TYPE NUMERIC USING CAST(REPLACE(per_capita_income, '$', '') AS NUMERIC),
    ALTER COLUMN yearly_income TYPE NUMERIC USING CAST(REPLACE(yearly_income, '$', '') AS NUMERIC),
    ALTER COLUMN total_debt TYPE NUMERIC USING CAST(REPLACE(total_debt, '$', '') AS NUMERIC);

-- Langkah 2: Membersihkan kolom finansial di tabel cards
ALTER TABLE cards
    ALTER COLUMN credit_limit TYPE NUMERIC USING CAST(REPLACE(credit_limit, '$', '') AS NUMERIC);

-- Langkah 3: Membersihkan dan mengubah tipe data di tabel transactions
-- Mengubah kolom amount menjadi NUMERIC dan kolom date menjadi TIMESTAMP
ALTER TABLE transactions
    ALTER COLUMN amount TYPE NUMERIC USING CAST(REPLACE(amount, '$', '') AS NUMERIC),
    ALTER COLUMN date TYPE TIMESTAMP USING TO_TIMESTAMP(date, 'YYYY-MM-DD HH24:MI:SS');
