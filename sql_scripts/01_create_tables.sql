-- Tabel 1: users
-- Menyimpan informasi demografis dan finansial pengguna.
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
    per_capita_income TEXT, -- Diimpor sebagai teks untuk menangani simbol '$'
    yearly_income TEXT,     -- Diimpor sebagai teks untuk menangani simbol '$'
    total_debt TEXT,        -- Diimpor sebagai teks untuk menangani simbol '$'
    credit_score INT,
    num_credit_cards INT
);

-- Tabel 2: cards
-- Menyimpan informasi detail kartu yang terhubung dengan pengguna.
CREATE TABLE cards (
    id INT PRIMARY KEY,
    client_id INT REFERENCES users(id), -- Foreign key ke tabel users
    card_brand VARCHAR(50),
    card_type VARCHAR(50),
    card_number VARCHAR(20),
    expires VARCHAR(7),
    cvv INT,
    has_chip VARCHAR(3),
    num_cards_issued INT,
    credit_limit TEXT, -- Diimpor sebagai teks untuk menangani simbol '$'
    acct_open_date VARCHAR(10),
    year_pin_last_changed INT,
    card_on_dark_web VARCHAR(3)
);

-- Tabel 3: transactions
-- Menyimpan semua data transaksi yang dilakukan oleh pengguna menggunakan kartu.
CREATE TABLE transactions (
    id INT PRIMARY KEY,
    date TEXT, -- Diimpor sebagai teks untuk diubah nanti
    client_id INT REFERENCES users(id), -- Foreign key ke tabel users
    card_id INT REFERENCES cards(id),   -- Foreign key ke tabel cards
    amount TEXT, -- Diimpor sebagai teks untuk menangani simbol '$'
    use_chip VARCHAR(50),
    merchant_id INT,
    merchant_city VARCHAR(100),
    merchant_state VARCHAR(10),
    zip VARCHAR(20),
    mcc INT,
    errors TEXT
);
