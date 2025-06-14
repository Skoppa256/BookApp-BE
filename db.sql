CREATE TABLE Pegawai(
	pegawai_id CHAR(8) PRIMARY KEY,
	nama VARCHAR(100) NOT NULL,
	email VARCHAR(30) NOT NULL UNIQUE,
	jenis_kelamin CHAR(1) NOT NULL,
	no_telp VARCHAR(20) NOT NULL,
	tanggal_lahir DATE NOT NULL
);

CREATE TABLE Pelanggan(
	pelanggan_id CHAR(8) PRIMARY KEY,
	nama VARCHAR(100) NOT NULL
);

CREATE TABLE Membership(
	membership_id CHAR(8) PRIMARY KEY,
	pelanggan_id CHAR(8) NOT NULL,
	tipe VARCHAR(20) NOT NULL,
	no_telp VARCHAR(20) NOT NULL,
	alamat VARCHAR(150) NOT NULL,
	tanggal_pembuatan TIMESTAMP NOT NULL,
	tanggal_kadaluwarsa TIMESTAMP NOT NULL,
	FOREIGN KEY (pelanggan_id) REFERENCES Pelanggan(pelanggan_id)
		ON UPDATE CASCADE
		ON DELETE CASCADE
);

CREATE TABLE Penjualan(
	penjualan_id CHAR(10) PRIMARY KEY,
	pelanggan_id CHAR(8) NOT NULL,
	pegawai_id CHAR(8) NOT NULL,
	tanggal_penjualan TIMESTAMP NOT NULL,
	metode_pembayaran VARCHAR(20) NOT NULL,
	diskon INT,
	FOREIGN KEY (pelanggan_id) REFERENCES Pelanggan(pelanggan_id)
		ON UPDATE CASCADE
		ON DELETE SET NULL,
	FOREIGN KEY (pegawai_id) REFERENCES Pegawai(pegawai_id)
		ON UPDATE CASCADE
		ON DELETE SET NULL
);

CREATE TABLE Supplier(
	supplier_id CHAR(8) PRIMARY KEY,
	nama VARCHAR(100) NOT NULL,
	no_telp VARCHAR(20) NOT NULL,
	alamat VARCHAR(150) NOT NULL
);

CREATE TABLE Pembelian(
	pembelian_id CHAR(10) PRIMARY KEY,
	tanggal_pembelian TIMESTAMP NOT NULL,
	supplier_id CHAR(8) NOT NULL,
	pegawai_id CHAR(8) NOT NULL,
	FOREIGN KEY (supplier_id) REFERENCES Supplier(supplier_id)
		ON UPDATE CASCADE
		ON DELETE SET NULL,
	FOREIGN KEY (pegawai_id) REFERENCES Pegawai(pegawai_id)
		ON UPDATE CASCADE
		ON DELETE SET NULL
);

CREATE TABLE Penulis(
	penulis_id CHAR(6) PRIMARY KEY,
	nama_penulis VARCHAR(100) NOT NULL
);

CREATE TABLE Penerbit(
	penerbit_id CHAR(6) PRIMARY KEY,
	nama VARCHAR(50) NOT NULL,
	alamat VARCHAR(150) NOT NULL,
	email VARCHAR(30) NOT NULL UNIQUE,
	no_telp VARCHAR(20) NOT NULL
);

CREATE TABLE Kategori(
	kategori_id CHAR(5) PRIMARY KEY,
	nama VARCHAR(50) NOT NULL,
	deskripsi VARCHAR(150)
);

CREATE TABLE Buku(
	buku_id CHAR(8) PRIMARY KEY,
	penerbit_id CHAR(6) NOT NULL,
	kategori_id CHAR(5) NOT NULL,
	isbn CHAR(13) NOT NULL UNIQUE,
	judul VARCHAR(100) NOT NULL,
	tahun_terbit INT NOT NULL,
	jumlah_halaman INT NOT NULL,
	harga_beli DECIMAL(10, 2) NOT NULL,
	harga_jual DECIMAL(10, 2) NOT NULL,
	jumlah_stok INT NOT NULL,
	FOREIGN KEY (penerbit_id) REFERENCES Penerbit(penerbit_id)
		ON UPDATE CASCADE
		ON DELETE SET NULL,
	FOREIGN KEY (kategori_id) REFERENCES Kategori(kategori_id)
		ON UPDATE CASCADE
		ON DELETE SET NULL
);

CREATE TABLE Detail_Penjualan(
	buku_id CHAR(8),
	penjualan_id CHAR(10),
	kuantitas INT NOT NULL,
	subtotal DECIMAL(10, 2) NOT NULL,
	PRIMARY KEY (buku_id, penjualan_id),
	FOREIGN KEY (buku_id) REFERENCES Buku(buku_id)
		ON UPDATE CASCADE
		ON DELETE CASCADE,
	FOREIGN KEY (penjualan_id) REFERENCES Penjualan(penjualan_id)
		ON UPDATE CASCADE
		ON DELETE CASCADE
);

CREATE TABLE Detail_Pembelian(
	buku_id CHAR(8),
	pembelian_id CHAR(10),
	kuantitas INT NOT NULL,
	subtotal DECIMAL(10, 2) NOT NULL,
	PRIMARY KEY (buku_id, pembelian_id),
	FOREIGN KEY (buku_id) REFERENCES Buku(buku_id)
		ON UPDATE CASCADE
		ON DELETE CASCADE,
	FOREIGN KEY (pembelian_id) REFERENCES Pembelian(pembelian_id)
		ON UPDATE CASCADE
		ON DELETE CASCADE
);

CREATE TABLE Buku_Penulis(
	buku_id CHAR(8),
	penulis_id CHAR(6),
	PRIMARY KEY (buku_id, penulis_id),
	FOREIGN KEY (buku_id) REFERENCES Buku(buku_id)
		ON UPDATE CASCADE
		ON DELETE CASCADE,
	FOREIGN KEY (penulis_id) REFERENCES Penulis(penulis_id)
		ON UPDATE CASCADE
		ON DELETE CASCADE
);

------------------------------------------------------------------------------ AUTO ID -------------------------------------------------------------------------------------------

-- Automatic ID
-- Tabel untuk menyimpan urutan ID terakhir
CREATE TABLE urutan_id (
    nama_tabel VARCHAR(50) PRIMARY KEY,
    nomor_terakhir INT NOT NULL
);

-- Isi awal untuk urutan ID
INSERT INTO urutan_id VALUES 
('Pegawai', 0),
('Pelanggan', 0),
('Membership', 0),
('Supplier', 0),
('Penulis', 0),
('Penerbit', 0),
('Kategori', 0),
('Buku', 0),
('Pembelian', 0),
('Penjualan', 0);

-- Fungsi untuk membuat ID otomatis
CREATE OR REPLACE FUNCTION buat_id_otomatis(prefix TEXT, tbl TEXT, lebar INT)
RETURNS TEXT AS $$
DECLARE
    nomor_baru INT;
    nomor_terformat TEXT;
BEGIN
    UPDATE urutan_id
    SET nomor_terakhir = nomor_terakhir + 1
    WHERE nama_tabel = tbl
    RETURNING nomor_terakhir INTO nomor_baru;

    nomor_terformat := LPAD(nomor_baru::TEXT, lebar, '0');
    RETURN prefix || nomor_terformat;
END;
$$ LANGUAGE plpgsql;

-- Pegawai Auto ID
CREATE OR REPLACE FUNCTION before_insert_pegawai()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.pegawai_id IS NULL THEN
        NEW.pegawai_id := buat_id_otomatis('PG', 'Pegawai', 6);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_pegawai_id
BEFORE INSERT ON Pegawai
FOR EACH ROW
EXECUTE FUNCTION before_insert_pegawai();

-- Pelanggan Auto ID
CREATE OR REPLACE FUNCTION before_insert_pelanggan()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.pelanggan_id IS NULL THEN
        NEW.pelanggan_id := buat_id_otomatis('PL', 'Pelanggan', 6);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_pelanggan_id
BEFORE INSERT ON Pelanggan
FOR EACH ROW
EXECUTE FUNCTION before_insert_pelanggan();

-- Membership Auto ID
CREATE OR REPLACE FUNCTION before_insert_membership()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.membership_id IS NULL THEN
        NEW.membership_id := buat_id_otomatis('MB', 'Membership', 6);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_membership_id
BEFORE INSERT ON Membership
FOR EACH ROW
EXECUTE FUNCTION before_insert_membership();

-- Supplier Auto ID
CREATE OR REPLACE FUNCTION before_insert_supplier()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.supplier_id IS NULL THEN
        NEW.supplier_id := buat_id_otomatis('SP', 'Supplier', 6);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_supplier_id
BEFORE INSERT ON Supplier
FOR EACH ROW
EXECUTE FUNCTION before_insert_supplier();

-- Penulis Auto ID
CREATE OR REPLACE FUNCTION before_insert_penulis()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.penulis_id IS NULL THEN
        NEW.penulis_id := buat_id_otomatis('PN', 'Penulis', 4);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_penulis_id
BEFORE INSERT ON Penulis
FOR EACH ROW
EXECUTE FUNCTION before_insert_penulis();

-- Penerbit Auto ID
CREATE OR REPLACE FUNCTION before_insert_penerbit()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.penerbit_id IS NULL THEN
        NEW.penerbit_id := buat_id_otomatis('PB', 'Penerbit', 4);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_penerbit_id
BEFORE INSERT ON Penerbit
FOR EACH ROW
EXECUTE FUNCTION before_insert_penerbit();

-- Kategori Auto ID
CREATE OR REPLACE FUNCTION before_insert_kategori()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.kategori_id IS NULL THEN
        NEW.kategori_id := buat_id_otomatis('KT', 'Kategori', 3);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_kategori_id
BEFORE INSERT ON Kategori
FOR EACH ROW
EXECUTE FUNCTION before_insert_kategori();

-- Buku Auto ID
CREATE OR REPLACE FUNCTION before_insert_buku()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.buku_id IS NULL THEN
        NEW.buku_id := buat_id_otomatis('BK', 'Buku', 6);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_buku_id
BEFORE INSERT ON Buku
FOR EACH ROW
EXECUTE FUNCTION before_insert_buku();

-- Pembelian Auto ID
CREATE OR REPLACE FUNCTION before_insert_pembelian()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.pembelian_id IS NULL THEN
        NEW.pembelian_id := buat_id_otomatis('PB', 'Pembelian', 7);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_pembelian_id
BEFORE INSERT ON Pembelian
FOR EACH ROW
EXECUTE FUNCTION before_insert_pembelian();

-- Penjualan Auto ID
CREATE OR REPLACE FUNCTION before_insert_penjualan()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.penjualan_id IS NULL THEN
        NEW.penjualan_id := buat_id_otomatis('PJ', 'Penjualan', 7);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_penjualan_id
BEFORE INSERT ON Penjualan
FOR EACH ROW
EXECUTE FUNCTION before_insert_penjualan();



------------------------------------------------------------------------------ ACTIVITY -------------------------------------------------------------------------------------------

-- 2.2.1 Proses Pembelian dari Supplier

-- Mengidentifikasi buku yang perlu dibeli (stok sedikit)
CREATE OR REPLACE FUNCTION rekomendasi_pembelian(threshold INT)
RETURNS TABLE(
	buku_id CHAR(8),
	judul VARCHAR(100),
	jumlah_stok INT,
	nama_supplier VARCHAR(100)
) 
AS $$
BEGIN
	RETURN QUERY
	SELECT 
		b.buku_id,
		b.judul,
		b.jumlah_stok,
		s.nama
	FROM Buku b 
	JOIN Detail_Pembelian d ON b.buku_id = d.buku_id
	JOIN Pembelian p ON d.pembelian_id = p.pembelian_id
	JOIN Supplier s ON s.supplier_id = p.supplier_id
	WHERE b.jumlah_stok < threshold
	GROUP BY b.buku_id, b.judul, b.jumlah_stok, s.nama
	ORDER BY b.jumlah_stok ASC;
END;
$$
LANGUAGE plpgsql;

-- Proses Pembelian
CREATE OR REPLACE PROCEDURE pembelian_buku(
	IN p_supplier_id CHAR(8),
	IN p_pegawai_id CHAR(8),
	IN p_buku_ids CHAR(8)[],
	IN p_kuantitas INT[],
	IN p_subtotals DECIMAL(10, 2)[],
	IN p_harga_belis DECIMAL(10, 2)[]
)
LANGUAGE plpgsql
AS $$
DECLARE
	i INT;
	array_len INT := array_length(p_buku_ids, 1);
	new_pembelian_id CHAR(10);
BEGIN
	IF NOT EXISTS (SELECT 1 FROM Supplier WHERE supplier_id = p_supplier_id) THEN
		RAISE EXCEPTION 'Supplier ID % tidak ditemukan', p_supplier_id;
	END IF;

	IF NOT EXISTS (SELECT 1 FROM Pegawai WHERE pegawai_id = p_pegawai_id) THEN
		RAISE EXCEPTION 'Pegawai ID % tidak ditemukan', p_pegawai_id;
	END IF;

	IF array_len IS NULL OR array_len = 0 THEN
		RAISE EXCEPTION 'Array buku tidak boleh kosong';
	END IF;

	-- Insert header and get pembelian_id
	INSERT INTO Pembelian(tanggal_pembelian, supplier_id, pegawai_id)
	VALUES (NOW(), p_supplier_id, p_pegawai_id)
	RETURNING pembelian_id INTO new_pembelian_id;

	-- Loop through each buku
	FOR i IN 1..array_len LOOP
		IF NOT EXISTS (SELECT 1 FROM Buku WHERE buku_id = p_buku_ids[i]) THEN
			RAISE EXCEPTION 'Buku ID % tidak ditemukan', p_buku_ids[i];
		END IF;

		IF p_kuantitas[i] <= 0 THEN
			RAISE EXCEPTION 'Kuantitas harus > 0 untuk buku %', p_buku_ids[i];
		END IF;

		IF p_subtotals[i] <= 0 THEN
			RAISE EXCEPTION 'Subtotal harus > 0 untuk buku %', p_buku_ids[i];
		END IF;

		IF p_harga_belis[i] <= 0 THEN
			RAISE EXCEPTION 'Harga beli harus > 0 untuk buku %', p_buku_ids[i];
		END IF;

		-- Insert detail pembelian
		INSERT INTO Detail_Pembelian(pembelian_id, buku_id, kuantitas, subtotal)
		VALUES(new_pembelian_id, p_buku_ids[i], p_kuantitas[i], p_subtotals[i]);

		-- Update harga beli buku
		UPDATE Buku
		SET harga_beli = p_harga_belis[i]
		WHERE buku_id = p_buku_ids[i];
	END LOOP;
END;
$$;

-- Update stok setelah Pembelian
CREATE OR REPLACE FUNCTION tambah_stok()
RETURNS TRIGGER AS $$
BEGIN
	UPDATE Buku
	SET jumlah_stok = jumlah_stok + NEW.kuantitas
	WHERE buku_id = NEW.buku_id;

	RETURN NEW;
END;
$$ 
LANGUAGE plpgsql;

CREATE TRIGGER trg_tambah_stok
AFTER INSERT ON Detail_Pembelian
FOR EACH ROW
EXECUTE FUNCTION tambah_stok();

-- 2.2.2 Proses Penjualan ke Pelanggan

-- Pencarian buku 
CREATE OR REPLACE FUNCTION cari_buku(
    p_judul VARCHAR(100) DEFAULT NULL,
    p_nama_penulis VARCHAR(100) DEFAULT NULL,
    p_kategori VARCHAR(100) DEFAULT NULL,
    p_isbn CHAR(13) DEFAULT NULL,
    p_tahun_terbit INT DEFAULT NULL
)
RETURNS TABLE (
    buku_id CHAR(8),
    judul VARCHAR(100),
    nama_penulis VARCHAR(100),
    kategori VARCHAR(50),
    isbn CHAR(13),
    tahun_terbit INT,
    jumlah_halaman INT,
    harga_jual DECIMAL(10, 2),
    jumlah_stok INT
)
AS $$
BEGIN
    RETURN QUERY
    SELECT
        b.buku_id,
        b.judul,
        p.nama_penulis,
        k.nama AS kategori,
        b.isbn,
        b.tahun_terbit,
        b.jumlah_halaman,
        b.harga_jual,
        b.jumlah_stok
    FROM Buku b
    JOIN Buku_Penulis bp ON bp.buku_id = b.buku_id
    JOIN Penulis p ON p.penulis_id = bp.penulis_id
    JOIN Kategori k ON k.kategori_id = b.kategori_id
    WHERE
        (p_judul IS NULL OR LOWER(b.judul) LIKE LOWER('%' || p_judul || '%')) AND
        (p_nama_penulis IS NULL OR LOWER(p.nama_penulis) LIKE LOWER('%' || p_nama_penulis || '%')) AND
        (p_kategori IS NULL OR LOWER(k.nama) LIKE LOWER('%' || p_kategori || '%')) AND
        (p_isbn IS NULL OR b.isbn = p_isbn) AND
        (p_tahun_terbit IS NULL OR b.tahun_terbit = p_tahun_terbit)
    ORDER BY b.judul;
END;
$$ LANGUAGE plpgsql;


-- Proses Penjualan
-- CREATE OR REPLACE PROCEDURE penjualan_buku(
-- 	IN p_penjualan_id CHAR(10),
-- 	IN p_metode_pembayaran VARCHAR(20),
-- 	IN p_pelanggan_id CHAR(8),
-- 	IN p_pegawai_id CHAR(8),
-- 	IN p_buku_id CHAR(8),
-- 	IN p_kuantitas INT
-- )
-- LANGUAGE plpgsql
-- AS $$
-- DECLARE
-- 	v_harga_jual DECIMAL(10, 2);
-- 	v_subtotal DECIMAL(10, 2);
-- 	v_diskon INT;
-- 	v_tipe_membership VARCHAR(20);
-- BEGIN
-- 	IF NOT EXISTS (SELECT 1 FROM Pelanggan WHERE pelanggan_id = p_pelanggan_id) THEN
-- 		RAISE EXCEPTION 'Pelanggan ID % tidak ditemukan', p_pelanggan_id;
-- 	END IF;

-- 	IF NOT EXISTS (SELECT 1 FROM Pegawai WHERE pegawai_id = p_pegawai_id) THEN
-- 		RAISE EXCEPTION 'Pegawai ID % tidak ditemukan', p_pegawai_id;
-- 	END IF;

-- 	IF NOT EXISTS (SELECT 1 FROM Buku WHERE buku_id = p_buku_id) THEN
-- 		RAISE EXCEPTION 'Buku ID % tidak ditemukan', p_buku_id;
-- 	END IF;

-- 	IF EXISTS (SELECT 1 FROM Penjualan WHERE penjualan_id = p_penjualan_id) THEN
-- 		RAISE EXCEPTION 'Penjualan ID % sudah ada.', p_penjualan_id;
-- 	END IF;
	
-- 	IF p_kuantitas <= 0 THEN
-- 		RAISE EXCEPTION 'Kuantitas harus lebih dari 0';
-- 	END IF;

-- 	IF (SELECT jumlah_stok FROM Buku WHERE buku_id = p_buku_id) < p_kuantitas THEN
-- 		RAISE EXCEPTION 'Stok buku % tidak cukup untuk penjualan', p_buku_id;
-- 	END IF;

-- 	SELECT harga_jual INTO v_harga_jual FROM Buku WHERE buku_id = p_buku_id;

-- 	SELECT tipe INTO v_tipe_membership 
-- 	FROM Membership
-- 	WHERE pelanggan_id = p_pelanggan_id AND tanggal_kadaluwarsa > NOW()
-- 	ORDER BY tanggal_kadaluwarsa DESC
-- 	LIMIT 1;

-- 	IF v_tipe_membership = 'Bronze' THEN
-- 		v_diskon := 5;
-- 	ELSIF v_tipe_membership = 'Silver' THEN
-- 		v_diskon := 7.5;
-- 	ELSIF v_tipe_membership = 'Gold' THEN
-- 		v_diskon := 10;
-- 	END IF;

-- 	v_subtotal := (v_harga_jual * p_kuantitas) * (1 - v_diskon / 100);
	
-- 	INSERT INTO Penjualan(penjualan_id, tanggal_penjualan, metode_pembayaran, diskon, pelanggan_id, pegawai_id)
-- 	VALUES (p_penjualan_id, NOW(), p_metode_pembayaran, v_diskon, p_pelanggan_id, p_pegawai_id);

-- 	INSERT INTO Detail_Penjualan(penjualan_id, buku_id, kuantitas, subtotal)
-- 	VALUES(p_penjualan_id, p_buku_id, p_kuantitas, v_subtotal);
-- END;
-- $$;

CREATE OR REPLACE PROCEDURE penjualan_buku(
    IN p_metode_pembayaran VARCHAR(20),
    IN p_pelanggan_no_telp VARCHAR(20),
    IN p_pegawai_id CHAR(8),
    IN p_buku_ids CHAR(8)[],
    IN p_kuantitas INT[]
)
LANGUAGE plpgsql
AS $$
DECLARE
    i INT;
    array_len INT := array_length(p_buku_ids, 1);
	v_pelanggan_id CHAR(8);
    v_harga_jual DECIMAL(10, 2);
    v_subtotal DECIMAL(10, 2);
    v_diskon INT := 0;
    v_tipe_membership VARCHAR(20);
	new_penjualan_id CHAR(10);
BEGIN
    -- Validasi dasar
    IF NOT EXISTS (SELECT 1 FROM Membership WHERE no_telp = p_pelanggan_no_telp) THEN
        RAISE EXCEPTION 'Pelanggan tidak ditemukan';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Pegawai WHERE pegawai_id = p_pegawai_id) THEN
        RAISE EXCEPTION 'Pegawai ID % tidak ditemukan', p_pegawai_id;
    END IF;

    IF array_len IS NULL OR array_len = 0 THEN
        RAISE EXCEPTION 'Array buku tidak boleh kosong';
    END IF;

	SELECT pelanggan_id INTO v_pelanggan_id
	FROM Membership
	WHERE no_telp = p_pelanggan_no_telp;

    -- Dapatkan tipe membership dan diskon
    SELECT tipe INTO v_tipe_membership
    FROM Membership
    WHERE pelanggan_id = v_pelanggan_id AND tanggal_kadaluwarsa > NOW()
    ORDER BY tanggal_kadaluwarsa DESC
    LIMIT 1;

    IF v_tipe_membership = 'Bronze' THEN
        v_diskon := 5;
    ELSIF v_tipe_membership = 'Silver' THEN
        v_diskon := 7;
    ELSIF v_tipe_membership = 'Gold' THEN
        v_diskon := 10;
    END IF;

    -- Masukkan header penjualan
    INSERT INTO Penjualan(tanggal_penjualan, metode_pembayaran, diskon, pelanggan_id, pegawai_id)
    VALUES (NOW(), p_metode_pembayaran, v_diskon, v_pelanggan_id, p_pegawai_id)
	RETURNING penjualan_id INTO new_penjualan_id;

    -- Loop untuk setiap buku
    FOR i IN 1..array_len LOOP
        IF NOT EXISTS (SELECT 1 FROM Buku WHERE buku_id = p_buku_ids[i]) THEN
            RAISE EXCEPTION 'Buku ID % tidak ditemukan', p_buku_ids[i];
        END IF;

        IF p_kuantitas[i] <= 0 THEN
            RAISE EXCEPTION 'Kuantitas harus > 0 untuk buku %', p_buku_ids[i];
        END IF;

        IF (SELECT jumlah_stok FROM Buku WHERE buku_id = p_buku_ids[i]) < p_kuantitas[i] THEN
            RAISE EXCEPTION 'Stok buku % tidak cukup', p_buku_ids[i];
        END IF;

        -- Ambil harga jual dan hitung subtotal diskon
        SELECT harga_jual INTO v_harga_jual FROM Buku WHERE buku_id = p_buku_ids[i];

        v_subtotal := (v_harga_jual * p_kuantitas[i]) * (1 - v_diskon / 100.0);

        -- Masukkan detail penjualan
        INSERT INTO Detail_Penjualan(penjualan_id, buku_id, kuantitas, subtotal)
        VALUES (new_penjualan_id, p_buku_ids[i], p_kuantitas[i], v_subtotal);
    END LOOP;
END;
$$;



-- Trigger function to subtract stock 
CREATE OR REPLACE FUNCTION kurangi_stok()
RETURNS TRIGGER AS $$
BEGIN
	UPDATE Buku
	SET jumlah_stok = jumlah_stok - NEW.kuantitas
	WHERE buku_id = NEW.buku_id;

	RETURN NEW;
END;
$$ 
LANGUAGE plpgsql;

CREATE TRIGGER trg_kurangi_stok
AFTER INSERT ON Detail_Penjualan
FOR EACH ROW
EXECUTE FUNCTION kurangi_stok();

-- 2.2.3 Manajemen Membership

-- for insert new membership
CREATE OR REPLACE PROCEDURE sp_insert_membership(
   IN p_pelanggan_id CHAR(8),
   IN p_tipe VARCHAR(20),
   IN p_no_telp VARCHAR(20),
   IN p_alamat VARCHAR(150),
   IN p_tanggal_pembuatan TIMESTAMP,
   IN p_tanggal_kadaluwarsa TIMESTAMP
)
LANGUAGE plpgsql
AS $$
DECLARE
   membership_count INT;
BEGIN
   -- Validasi tanggal
   IF p_tanggal_kadaluwarsa <= p_tanggal_pembuatan THEN
       RAISE EXCEPTION 'Tanggal kadaluwarsa harus lebih besar dari tanggal pembuatan.';
   END IF;

   -- Cek apakah pelanggan sudah punya membership
   SELECT COUNT(*) INTO membership_count
   FROM Membership
   WHERE pelanggan_id = p_pelanggan_id;

   IF membership_count > 0 THEN
       RAISE EXCEPTION 'Membership untuk pelanggan ID % sudah ada.', p_pelanggan_id;
   END IF;

   -- INSERT data baru
   INSERT INTO Membership (
       pelanggan_id, tipe, no_telp, alamat,
       tanggal_pembuatan, tanggal_kadaluwarsa
   ) VALUES (
       p_pelanggan_id, p_tipe, p_no_telp, p_alamat,
       p_tanggal_pembuatan, p_tanggal_kadaluwarsa
   );
END;
$$;

-- for update existing membership
CREATE OR REPLACE PROCEDURE sp_update_membership(
   IN p_pelanggan_id CHAR(8),
   IN p_tipe VARCHAR(20),
   IN p_no_telp VARCHAR(20),
   IN p_alamat VARCHAR(150),
   IN p_tanggal_kadaluwarsa TIMESTAMP
)
LANGUAGE plpgsql
AS $$
DECLARE
   membership_count INT;
BEGIN
   -- Cek apakah membership ada
   SELECT COUNT(*) INTO membership_count
   FROM Membership
   WHERE pelanggan_id = p_pelanggan_id;

   IF membership_count = 0 THEN
       RAISE EXCEPTION 'Membership untuk pelanggan ID % tidak ditemukan.', p_pelanggan_id;
   END IF;

   -- UPDATE data existing 
   UPDATE Membership
   SET
       tipe = p_tipe,
       no_telp = p_no_telp,
       alamat = p_alamat,
       tanggal_kadaluwarsa = p_tanggal_kadaluwarsa
   WHERE pelanggan_id = p_pelanggan_id;
END;
$$;


-- 2.2.4 Analisis Bisnis dan laporan

-- Laporan Buku Terlaris
CREATE OR REPLACE VIEW laporan_buku_terlaris AS
SELECT 	
	b.buku_id,
	b.judul,
	SUM(dp.kuantitas)
FROM Buku b
JOIN Detail_Penjualan dp ON dp.buku_id = b.buku_id
GROUP BY b.buku_id, b.judul
ORDER BY SUM(dp.kuantitas) DESC;

-- Tren Penjualan per Kategori
CREATE OR REPLACE VIEW tren_penjualan_kategori AS
SELECT
	k.nama,
	DATE_TRUNC('month', p.tanggal_penjualan) AS bulan,
	SUM(dp.kuantitas) AS total_terjual
FROM Detail_Penjualan dp
JOIN Buku b ON b.buku_id = dp.buku_id
JOIN Kategori k ON b.kategori_id = k.kategori_id
JOIN Penjualan p ON p.penjualan_id = dp.penjualan_id
GROUP BY k.nama, DATE_TRUNC('month', p.tanggal_penjualan)
ORDER BY SUM(dp.kuantitas) DESC;

-- Laporan Keuangan Bulanan
CREATE OR REPLACE VIEW laporan_keuangan_bulanan AS
SELECT
    COALESCE(pendapatan.bulan, biaya.bulan) AS bulan,
    COALESCE(pendapatan.total_pendapatan, 0) AS total_pendapatan,
    COALESCE(biaya.total_biaya, 0) AS total_biaya,
    COALESCE(pendapatan.total_pendapatan, 0) - COALESCE(biaya.total_biaya, 0) AS laba_kotor
FROM
    (
        SELECT DATE_TRUNC('month', p.tanggal_penjualan) AS bulan,
               SUM(dp.subtotal) AS total_pendapatan
        FROM Penjualan p
        JOIN Detail_Penjualan dp ON p.penjualan_id = dp.penjualan_id
        GROUP BY bulan
    ) pendapatan
FULL OUTER JOIN
    (
        SELECT DATE_TRUNC('month', pb.tanggal_pembelian) AS bulan,
               SUM(dpb.subtotal) AS total_biaya
        FROM Pembelian pb
        JOIN Detail_Pembelian dpb ON pb.pembelian_id = dpb.pembelian_id
        GROUP BY bulan
    ) biaya
ON pendapatan.bulan = biaya.bulan
ORDER BY bulan;

-- 2.2.5 Integrasi Buku-Penulis-Penerbit-Kategori
CREATE OR REPLACE PROCEDURE tambah_buku_baru(
    IN p_buku_id CHAR(8),
    IN p_isbn CHAR(13),
    IN p_judul VARCHAR(100),
    IN p_kategori_id CHAR(5),
    IN p_penerbit_id CHAR(6),
    IN p_penulis_id CHAR(6),
    IN p_tahun_terbit INT,
    IN p_jumlah_halaman INT,
    IN p_harga_jual DECIMAL(10,2),
    IN p_jumlah_stok INT
)
LANGUAGE plpgsql
AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM Buku WHERE isbn = p_isbn) THEN
        RAISE EXCEPTION 'Buku dengan ISBN % sudah ada.', p_isbn;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Penulis WHERE penulis_id = p_penulis_id) THEN
        RAISE EXCEPTION 'Penulis ID % tidak ditemukan', p_penulis_id;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Penerbit WHERE penerbit_id = p_penerbit_id) THEN
        RAISE EXCEPTION 'Penerbit ID % tidak ditemukan', p_penerbit_id;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM Kategori WHERE kategori_id = p_kategori_id) THEN
        RAISE EXCEPTION 'Kategori ID % tidak ditemukan', p_kategori_id;
    END IF;

    INSERT INTO Buku(buku_id, penerbit_id, kategori_id, isbn, judul, tahun_terbit, jumlah_halaman, harga_beli, harga_jual, jumlah_stok)
    VALUES (p_buku_id, p_penerbit_id, p_kategori_id, p_isbn, p_judul, p_tahun_terbit, p_jumlah_halaman, 0, p_harga_jual, p_jumlah_stok);

    INSERT INTO Buku_Penulis(buku_id, penulis_id)
    VALUES (p_buku_id, p_penulis_id);
END;
$$;

------------------------------------------------------------------------------ INSERT -------------------------------------------------------------------------------------------

-- Pegawai
INSERT INTO Pegawai (nama, email, jenis_kelamin, no_telp, tanggal_lahir) VALUES
('John Smith',  'john@bookstore.com', 'M', '081234567890', '1990-05-12'),
('Emma Johnson','emma@bookstore.com', 'F', '082345678901', '1995-08-20'),
('David Lee',   'david@bookstore.com', 'M', '081223344556', '1988-03-10'),
('Olivia Brown','olivia@bookstore.com','F', '085677889900', '1992-11-25'),
('Michael Davis','michael@bookstore.com','M','087712345678', '1991-07-14');

-- Pelanggan
INSERT INTO Pelanggan (nama) VALUES
('Alice Green'), 
('James White'), 
('Sophia Moore'),
('Liam Taylor'), 
('Emily Clark');

-- Membership
INSERT INTO Membership (pelanggan_id, tipe, no_telp, alamat, tanggal_pembuatan, tanggal_kadaluwarsa) VALUES
('PL000001', 'Gold',   '08111222333', '123 Maple Street', NOW(), NOW() + INTERVAL '1 year'),
('PL000002', 'Silver', '08233445566', '456 Oak Avenue',   NOW(), NOW() + INTERVAL '6 months'),
('PL000003', 'Bronze', '08334455667', '789 Pine Road',    NOW(), NOW() + INTERVAL '3 months'),
('PL000004', 'Silver', '08445566778', '321 Cedar Lane',   NOW(), NOW() + INTERVAL '6 months'),
('PL000005', 'Gold',   '08556677889', '654 Birch Blvd',   NOW(), NOW() + INTERVAL '1 year');

-- Supplier
INSERT INTO Supplier (nama, no_telp, alamat) VALUES
('BrightBooks Co.',    '02133445566', '101 Main Street'),
('Alpha Distributors', '02166778899', '22 Commerce Drive'),
('BookNation Ltd.',    '02188990011', '88 Broadway'),
('Global Books Inc.',  '02112345678', '17 Market Street'),
('PublishX Partners',  '02145678901', '75 Liberty Ave');

-- Penulis
INSERT INTO Penulis (nama_penulis) VALUES
('Mark Twain'), ('Jane Austen'), ('George Orwell'),
('J.K. Rowling'), ('Ernest Hemingway');

-- Penerbit
INSERT INTO Penerbit (nama, alamat, email, no_telp) VALUES
('Penguin Books',    '100 Publisher Lane',  'contact@penguin.com',     '0211234567'),
('HarperCollins',    '200 Ink Street',      'info@harpercollins.com',  '0219876543'),
('Simon & Schuster', '50 Book Plaza',       'hello@simon.com',         '0211122334'),
('Macmillan',        '35 Print Road',       'office@macmillan.com',    '0212233445'),
('Random House',     '25 Binding Blvd',     'admin@randomhouse.com',   '0213344556');

-- Kategori
INSERT INTO Kategori (nama, deskripsi) VALUES
('Fiction',     'Stories and novels'),
('Nonfiction',  'Educational and factual books'),
('Biography',   'Life stories of influential people'),
('Children',    'Books for kids and learning'),
('Comics',      NULL);

-- Buku
INSERT INTO Buku (penerbit_id, kategori_id, isbn, judul, tahun_terbit, jumlah_halaman, harga_beli, harga_jual, jumlah_stok) VALUES
('PB0001', 'KT001', '9780142437179', 'The Adventures of Tom Sawyer',               1876, 274, 35000.00, 50000.00, 0),
('PB0002', 'KT001', '9780141439518', 'Pride and Prejudice',                        1813, 416, 40000.00, 55000.00, 0),
('PB0003', 'KT002', '9780451524935', '1984',                                       1949, 328, 45000.00, 60000.00, 0),
('PB0004', 'KT004', '9780747532743', 'Harry Potter and the Philosopher''s Stone',  1997, 223, 48000.00, 65000.00, 0),
('PB0005', 'KT003', '9780684801223', 'A Moveable Feast',                           1964, 211, 42000.00, 58000.00, 0);

-- Buku_Penulis (already IDs exist via Buku and Penulis)
INSERT INTO Buku_Penulis (buku_id, penulis_id) VALUES
('BK000001', 'PN0001'),
('BK000002', 'PN0002'),
('BK000003', 'PN0003'),
('BK000004', 'PN0004'),
('BK000005', 'PN0005');

-- Pembelian
INSERT INTO Pembelian (tanggal_pembelian, supplier_id, pegawai_id) VALUES
('2024-05-01 10:30:00', 'SP000001', 'PG000001'),
('2024-05-03 14:00:00', 'SP000002', 'PG000002'),
('2024-05-05 09:15:00', 'SP000003', 'PG000003'),
('2024-05-07 11:45:00', 'SP000004', 'PG000004'),
('2024-05-08 13:25:00', 'SP000005', 'PG000005'),
('2024-06-07 10:00:00', 'SP000001', 'PG000001'),
('2024-06-08 11:00:00', 'SP000003', 'PG000002');

-- Detail_Pembelian
INSERT INTO Detail_Pembelian (buku_id, pembelian_id, kuantitas, subtotal) VALUES
-- Use the generated pembelian_id values (e.g., PB0000001 etc.)
('BK000001', 'PB0000001', 10, 350000.00),
('BK000002', 'PB0000002', 5, 200000.00),
('BK000003', 'PB0000003', 8, 360000.00),
('BK000004', 'PB0000004', 12, 576000.00),
('BK000005', 'PB0000005', 6, 252000.00),
('BK000001', 'PB0000006', 10, 350000.00),
('BK000001', 'PB0000007', 5, 175000.00);

-- Penjualan
INSERT INTO Penjualan (pelanggan_id, pegawai_id, tanggal_penjualan, metode_pembayaran, diskon) VALUES
('PL000001', 'PG000001', '2024-06-01 15:30:00', 'Tunai',        10),
('PL000002', 'PG000002', '2024-06-02 12:45:00', 'Kartu Kredit', 7.5),
('PL000003', 'PG000003', '2024-06-03 17:10:00', 'E-Wallet',     5),
('PL000004', 'PG000004', '2024-06-05 14:20:00', 'Transfer Bank',7.5),
('PL000005', 'PG000005', '2024-06-06 11:00:00', 'Tunai',        10);

-- Detail_Penjualan
INSERT INTO Detail_Penjualan (buku_id, penjualan_id, kuantitas, subtotal) VALUES
('BK000001', 'PJ0000001', 2, 90000.00),  
('BK000002', 'PJ0000002', 1, 50875.00), 
('BK000003', 'PJ0000003', 3, 171000.00),
('BK000004', 'PJ0000004', 1, 60125.00), 
('BK000005', 'PJ0000005', 2, 104400.00);