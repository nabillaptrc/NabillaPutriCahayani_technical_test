-- membuat table user dengan kolom sesuai dengan dataset 'users_data.csv'
CREATE TABLE users (
    id INT PRIMARY KEY,
    current_age INT,
    retirement_age INT,
    birth_year INT,
    birth_month INT,
    gender VARCHAR(10),
    address TEXT,
    latitude NUMERIC(10, 6),
    longitude NUMERIC(10, 6),
    per_capita_income TEXT,
    yearly_income TEXT,
    total_debt TEXT,
    credit_score INT,
    num_credit_cards INT
);

-- membuat table cards dengan kolom sesuai dengan dataset 'cards_data.csv'
CREATE TABLE cards (
    id INT PRIMARY KEY,
    client_id INT REFERENCES users(id),
    card_brand VARCHAR(50),
    card_type VARCHAR(50),
    card_number VARCHAR(20),
    expires VARCHAR(7),
    cvv INT,
    has_chip VARCHAR(3),
    num_cards_issued INT,
    credit_limit TEXT,
    acct_open_date VARCHAR(10),
    year_pin_last_changed INT,
    card_on_dark_web VARCHAR(3)
);

-- membuat table transactions dengan kolom sesuai dengan dataset 'transactions_data.csv'
CREATE TABLE transactions (
    id INT PRIMARY KEY,
    date TEXT,
    client_id INT REFERENCES users(id),
    card_id INT REFERENCES cards(id),
    amount TEXT,
    use_chip VARCHAR(50),
    merchant_id INT,
    merchant_city VARCHAR(100),
    merchant_state VARCHAR(10),
    zip VARCHAR(20),
    mcc INT,
    errors TEXT
);

-- melakukan import data dari csv dengan cara copy isi header dan row dari masing-masing file dataset
-- query dijalankan pada terminal(psql)
\copy users FROM '/Users/nabillaputri/Downloads/users_data.csv' WITH (FORMAT CSV, HEADER);

\copy cards FROM '/Users/nabillaputri/Downloads/cards_data.csv' WITH (FORMAT CSV, HEADER);

\copy transactions FROM '/Users/nabillaputri/Downloads/transactions_data.csv' WITH (FORMAT CSV, HEADER);


-- Membersihkan kolom finansial di tabel users & cards
ALTER TABLE users
    ALTER COLUMN per_capita_income TYPE NUMERIC USING CAST(REPLACE(per_capita_income, '$', '') AS NUMERIC),
    ALTER COLUMN yearly_income TYPE NUMERIC USING CAST(REPLACE(yearly_income, '$', '') AS NUMERIC),
    ALTER COLUMN total_debt TYPE NUMERIC USING CAST(REPLACE(total_debt, '$', '') AS NUMERIC);

ALTER TABLE cards
    ALTER COLUMN credit_limit TYPE NUMERIC USING CAST(REPLACE(credit_limit, '$', '') AS NUMERIC);

-- Membersihkan kolom amount dan mengubah kolom date di tabel transactions
ALTER TABLE transactions
    ALTER COLUMN amount TYPE NUMERIC USING CAST(REPLACE(amount, '$', '') AS NUMERIC),
    ALTER COLUMN date TYPE TIMESTAMP USING TO_TIMESTAMP(date, 'YYYY-MM-DD HH24:MI:SS');

-- further analysis
-- Total nilai transaksi per tahun
SELECT
    EXTRACT(YEAR FROM date) as tahun,
    COUNT(id) as jumlah_transaksi,
    SUM(amount) as total_nilai_transaksi
FROM transactions
GROUP BY tahun
ORDER BY tahun;

-- Jenis transaksi yang paling sering digunakan
SELECT use_chip, COUNT(*) as jumlah_transaksi
FROM transactions
GROUP BY use_chip
ORDER BY jumlah_transaksi DESC;

-- 10 Kota dengan jumlah transaksi terbanyak
SELECT merchant_city, COUNT(id) as jumlah_transaksi
FROM transactions
WHERE merchant_city IS NOT NULL AND merchant_city != ''
GROUP BY merchant_city
ORDER BY jumlah_transaksi DESC
LIMIT 10;

-- mengubah type data amount pada kolom transactions
ALTER TABLE transactions
ALTER COLUMN amount TYPE NUMERIC USING CAST(REPLACE(amount, '$', '') AS NUMERIC);

-- tren transaksi bulanan
SELECT
    DATE_TRUNC('month', date)::DATE as bulan,
    COUNT(id) as jumlah_transaksi,
    SUM(amount) as total_nilai_transaksi
FROM
    transactions
GROUP BY
    bulan
ORDER BY
    bulan;

-- kategori MCC (merchant category code) atau kategori belanja paling populer
SELECT
    mcc,
    COUNT(id) as jumlah_transaksi,
    SUM(amount) as total_nilai_transaksi
FROM
    transactions
GROUP BY
    mcc
ORDER BY
    jumlah_transaksi DESC
LIMIT 15;

-- Distribusi pengguna berdasarkan gender
SELECT gender, COUNT(id) as total_pengguna
FROM users
GROUP BY gender;

-- Distribusi pengguna berdasarkan kelompok usia
SELECT
    CASE
        WHEN current_age < 25 THEN 'Di bawah 25'
        WHEN current_age BETWEEN 25 AND 34 THEN '25-34'
        WHEN current_age BETWEEN 35 AND 44 THEN '35-44'
        WHEN current_age BETWEEN 45 AND 54 THEN '45-54'
        ELSE 'Di atas 55'
    END as kelompok_usia,
    COUNT(id) as jumlah_pengguna
FROM users
GROUP BY kelompok_usia
ORDER BY kelompok_usia;

-- kota dengan rata-rata belanja / transaksi paling tinggi
SELECT
    merchant_city,
    merchant_state,
    COUNT(id) as jumlah_transaksi,
    AVG(amount) as rata_rata_nilai_transaksi
FROM
    transactions
WHERE
    merchant_city IS NOT NULL AND merchant_city != ''
GROUP BY
    merchant_city, merchant_state
HAVING
    COUNT(id) > 100 -- Hanya sertakan kota dengan minimal 100 transaksi agar hasilnya signifikan
ORDER BY
    rata_rata_nilai_transaksi DESC
LIMIT 10;

-- Kategori belanja terpopuler berdasarkan suatu kota tertentu
SELECT
    mcc,
    COUNT(id) as jumlah_transaksi
FROM
    transactions
WHERE
    merchant_city = 'New York' 
GROUP BY
    mcc
ORDER BY
    jumlah_transaksi DESC
LIMIT 5;

-- Kategori kartu brand (merk) dan type kartu berdasarkan jumlah transaksi
SELECT
    c.card_brand,
    c.card_type,
    COUNT(t.id) as jumlah_transaksi,
    SUM(t.amount) as total_nilai_transaksi
FROM
    transactions AS t
JOIN
    cards AS c ON t.card_id = c.id
GROUP BY
    c.card_brand, c.card_type
ORDER BY
    jumlah_transaksi DESC;

-- Perbandingan jumlah transaksi berdasarkan gender
SELECT
    u.gender,
    COUNT(t.id) as jumlah_transaksi,
    SUM(t.amount) as total_nilai_transaksi,
    AVG(t.amount) as rata_rata_nilai_transaksi
FROM
    transactions AS t
JOIN
    users AS u ON t.client_id = u.id
GROUP BY
    u.gender;

-- TOP 5 kategori produk berdasarkan gender
WITH RankedMCCs AS (
    SELECT
        u.gender,
        t.mcc,
        COUNT(t.id) as jumlah_transaksi,
        ROW_NUMBER() OVER(PARTITION BY u.gender ORDER BY COUNT(t.id) DESC) as peringkat
    FROM
        transactions AS t
    JOIN
        users AS u ON t.client_id = u.id
    GROUP BY
        u.gender, t.mcc
)
SELECT
    gender,
    mcc,
    jumlah_transaksi
FROM
    RankedMCCs
WHERE
    peringkat <= 5
ORDER BY
    gender, peringkat;

-- Perbandingan Jumlah dan Rata-rata Transaksi per Kelompok Usia
SELECT
    CASE
        WHEN u.current_age < 25 THEN 'Di bawah 25'
        WHEN u.current_age BETWEEN 25 AND 34 THEN '25-34'
        WHEN u.current_age BETWEEN 35 AND 44 THEN '35-44'
        WHEN u.current_age BETWEEN 45 AND 54 THEN '45-54'
        ELSE 'Di atas 55'
    END as kelompok_usia,
    COUNT(t.id) as jumlah_transaksi,
    AVG(t.amount) as rata_rata_nilai_transaksi
FROM
    transactions AS t
JOIN
    users AS u ON t.client_id = u.id
GROUP BY
    kelompok_usia
ORDER BY
    kelompok_usia;

-- Top 5 Kaegori Belanja (MCC) untuk Masing-masing Kelompok Usia
WITH RankedMCCsByAge AS (
    SELECT
        CASE
            WHEN u.current_age < 25 THEN 'Di bawah 25'
            WHEN u.current_age BETWEEN 25 AND 34 THEN '25-34'
            WHEN u.current_age BETWEEN 35 AND 44 THEN '35-44'
            WHEN u.current_age BETWEEN 45 AND 54 THEN '45-54'
            ELSE 'Di atas 55'
        END as kelompok_usia,
        t.mcc,
        COUNT(t.id) as jumlah_transaksi,
        ROW_NUMBER() OVER(PARTITION BY 
            CASE
                WHEN u.current_age < 25 THEN 'Di bawah 25'
                WHEN u.current_age BETWEEN 25 AND 34 THEN '25-34'
                WHEN u.current_age BETWEEN 35 AND 44 THEN '35-44'
                WHEN u.current_age BETWEEN 45 AND 54 THEN '45-54'
                ELSE 'Di atas 55'
            END 
        ORDER BY COUNT(t.id) DESC) as peringkat
    FROM
        transactions AS t
    JOIN
        users AS u ON t.client_id = u.id
    GROUP BY
        kelompok_usia, t.mcc
)
SELECT
    kelompok_usia,
    mcc,
    jumlah_transaksi
FROM
    RankedMCCsByAge
WHERE
    peringkat <= 5
ORDER BY
    kelompok_usia, peringkat;