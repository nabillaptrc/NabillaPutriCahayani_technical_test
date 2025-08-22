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