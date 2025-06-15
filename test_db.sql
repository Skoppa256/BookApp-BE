SELECT * FROM Pegawai
SELECT * FROM Pelanggan
SELECT * FROM Membership
SELECT * FROM Supplier
SELECT * FROM Penulis
SELECT * FROM Penerbit
SELECT * FROM Kategori
SELECT * FROM Buku
SELECT * FROM Pembelian
SELECT * FROM Penjualan
SELECT * FROM Detail_Penjualan
SELECT * FROM Detail_Pembelian
SELECT * FROM Buku_Penulis
SELECT * FROM urutan_id

-- Daftar Pembelian
SELECT p.pembelian_id, DATE(p.tanggal_pembelian) AS tanggal_pembelian, peg.nama AS nama_pegawai, s.nama AS nama_supplier, det.kuantitas, det.total
FROM (SELECT pembelian_id, SUM(subtotal) AS total, SUM(kuantitas) AS kuantitas
	FROM detail_pembelian
	GROUP BY pembelian_id) det 
JOIN pembelian p ON (p.pembelian_id = det.pembelian_id)
JOIN pegawai peg ON (p.pegawai_id = peg.pegawai_id)
JOIN supplier s ON (p.supplier_id = s.supplier_id)

SELECT pembelian_id, SUM(subtotal)
FROM detail_pembelian
GROUP BY pembelian_id

-- Daftar Penjualan
SELECT p.penjualan_id, DATE(p.tanggal_penjualan) AS tanggal_penjualan, p.metode_pembayaran, p.diskon , pel.nama AS nama_pelanggan, peg.nama AS nama_pegawai, det.kuantitas, det.total
FROM (SELECT penjualan_id, SUM(subtotal) AS total, SUM(kuantitas) AS kuantitas
	FROM detail_penjualan
	GROUP BY penjualan_id) det 
JOIN penjualan p ON (p.penjualan_id = det.penjualan_id)
JOIN pegawai peg ON (p.pegawai_id = peg.pegawai_id)
JOIN pelanggan pel ON (p.pelanggan_id = pel.pelanggan_id)

-- Detail Pembelian
SELECT p.pembelian_id, p.tanggal_pembelian, s.nama AS nama_supplier, peg.nama AS nama_pegawai
FROM pembelian p
JOIN supplier s ON (p.supplier_id = s.supplier_id)
JOIN pegawai peg ON (peg.pegawai_id = p.pegawai_id)
WHERE pembelian_id = 'PB0000012'

SELECT 
    b.judul, 
	STRING_AGG(pen.nama_penulis, ', ') AS penulis,
    p.nama AS nama_penerbit, 
    k.nama AS nama_kategori, 
    b.isbn, 
    b.tahun_terbit, 
    b.jumlah_halaman, 
    b.harga_beli, 
    b.harga_jual, 
    det.kuantitas, 
    det.subtotal
FROM detail_pembelian det
JOIN buku b ON b.buku_id = det.buku_id
JOIN penerbit p ON p.penerbit_id = b.penerbit_id
JOIN kategori k ON k.kategori_id = b.kategori_id
JOIN buku_penulis bp ON bp.buku_id = b.buku_id
JOIN penulis pen ON pen.penulis_id = bp.penulis_id
WHERE det.pembelian_id = 'PB0000012'
GROUP BY 
    b.judul, p.nama, k.nama, b.isbn, b.tahun_terbit, 
    b.jumlah_halaman, b.harga_beli, b.harga_jual, 
    det.kuantitas, det.subtotal

SELECT SUM(subtotal) AS total
FROM detail_pembelian
WHERE pembelian_id = 'PB0000012'

-- Detail Penjualan
SELECT p.penjualan_id, p.tanggal_penjualan, pel.nama AS nama_pelanggan, peg.nama AS nama_pegawai
FROM penjualan p
JOIN pelanggan pel ON (p.pelanggan_id = pel.pelanggan_id)
JOIN pegawai peg ON (peg.pegawai_id = p.pegawai_id)
WHERE penjualan_id = 'PJ0000008'

SELECT 
    b.judul, 
	STRING_AGG(pen.nama_penulis, ', ') AS penulis,
    p.nama AS nama_penerbit, 
    k.nama AS nama_kategori, 
    b.isbn, 
    b.tahun_terbit, 
    b.jumlah_halaman, 
    b.harga_beli, 
    b.harga_jual, 
    det.kuantitas, 
    det.subtotal
FROM detail_penjualan det
JOIN buku b ON b.buku_id = det.buku_id
JOIN penerbit p ON p.penerbit_id = b.penerbit_id
JOIN kategori k ON k.kategori_id = b.kategori_id
JOIN buku_penulis bp ON bp.buku_id = b.buku_id
JOIN penulis pen ON pen.penulis_id = bp.penulis_id
WHERE det.penjualan_id = 'PJ0000008'
GROUP BY 
    b.judul, p.nama, k.nama, b.isbn, b.tahun_terbit, 
    b.jumlah_halaman, b.harga_beli, b.harga_jual, 
    det.kuantitas, det.subtotal
	
SELECT SUM(subtotal) AS total
FROM detail_penjualan
WHERE penjualan_id = 'PJ0000008'

-- Detail Pegawai
SELECT p.*
FROM Pegawai p
WHERE p.pegawai_id = 'PG000001'

SELECT p.pembelian_id, DATE(p.tanggal_pembelian) AS tanggal_pembelian, peg.nama AS nama_pegawai, s.nama AS nama_supplier, det.kuantitas, det.total
FROM (SELECT pembelian_id, SUM(subtotal) AS total, SUM(kuantitas) AS kuantitas
	FROM detail_pembelian
	GROUP BY pembelian_id) det 
JOIN pembelian p ON (p.pembelian_id = det.pembelian_id)
JOIN pegawai peg ON (p.pegawai_id = peg.pegawai_id)
JOIN supplier s ON (p.supplier_id = s.supplier_id)
WHERE p.pegawai_id = 'PG000001'

SELECT SUM(kuantitas) AS kuantitas, SUM(total) AS total
FROM (SELECT pembelian_id, SUM(subtotal) AS total, SUM(kuantitas) AS kuantitas
	FROM detail_pembelian
	GROUP BY pembelian_id) det 
JOIN pembelian p ON (p.pembelian_id = det.pembelian_id)
WHERE p.pegawai_id = 'PG000001'

SELECT p.penjualan_id, DATE(p.tanggal_penjualan) AS tanggal_penjualan, p.metode_pembayaran, p.diskon , pel.nama AS nama_pelanggan, peg.nama AS nama_pegawai, det.kuantitas, det.total
FROM (SELECT penjualan_id, SUM(subtotal) AS total, SUM(kuantitas) AS kuantitas
	FROM detail_penjualan
	GROUP BY penjualan_id) det 
JOIN penjualan p ON (p.penjualan_id = det.penjualan_id)
JOIN pegawai peg ON (p.pegawai_id = peg.pegawai_id)
JOIN pelanggan pel ON (p.pelanggan_id = pel.pelanggan_id)
WHERE p.pegawai_id = 'PG000001'

SELECT SUM(kuantitas) AS kuantitas, SUM(total) AS total
FROM (SELECT penjualan_id, SUM(subtotal) AS total, SUM(kuantitas) AS kuantitas
	FROM detail_penjualan
	GROUP BY penjualan_id) det 
JOIN penjualan p ON (p.penjualan_id = det.penjualan_id)
WHERE p.pegawai_id = 'PG000001'

-- Detail Pelanggan
SELECT p.nama, m.tipe, m.no_telp, m.alamat, m.tanggal_pembuatan, m.tanggal_kadaluwarsa
FROM pelanggan p
JOIN membership m ON (p.pelanggan_id = m.pelanggan_id)
WHERE p.pelanggan_id = 'PL000001'

SELECT p.penjualan_id, DATE(p.tanggal_penjualan) AS tanggal_penjualan, p.metode_pembayaran, p.diskon , pel.nama AS nama_pelanggan, peg.nama AS nama_pegawai, det.kuantitas, det.total
FROM (SELECT penjualan_id, SUM(subtotal) AS total, SUM(kuantitas) AS kuantitas
	FROM detail_penjualan
	GROUP BY penjualan_id) det 
JOIN penjualan p ON (p.penjualan_id = det.penjualan_id)
JOIN pegawai peg ON (p.pegawai_id = peg.pegawai_id)
JOIN pelanggan pel ON (p.pelanggan_id = pel.pelanggan_id)
WHERE p.pelanggan_id = 'PL000001'

SELECT SUM(kuantitas) AS kuantitas, SUM(total) AS total
FROM (SELECT penjualan_id, SUM(subtotal) AS total, SUM(kuantitas) AS kuantitas
	FROM detail_penjualan
	GROUP BY penjualan_id) det 
JOIN penjualan p ON (p.penjualan_id = det.penjualan_id)
WHERE p.pelanggan_id = 'PL000001'

-- Detail Buku
SELECT 
    b.judul,
	STRING_AGG(pen.nama_penulis, ', ') AS penulis,
    p.nama AS nama_penerbit, 
    k.nama AS nama_kategori, 
    b.isbn, 
    b.tahun_terbit, 
    b.jumlah_halaman, 
    b.harga_beli, 
    b.harga_jual
FROM buku b
JOIN penerbit p ON p.penerbit_id = b.penerbit_id
JOIN kategori k ON k.kategori_id = b.kategori_id
JOIN buku_penulis bp ON bp.buku_id = b.buku_id
JOIN penulis pen ON pen.penulis_id = bp.penulis_id
WHERE b.buku_id = 'BK000001'
GROUP BY 
    b.judul, p.nama, k.nama, b.isbn, b.tahun_terbit, 
    b.jumlah_halaman, b.harga_beli, b.harga_jual
	
SELECT p.penjualan_id, pel.nama AS nama_pelanggan, peg.nama AS nama_pegawai, p.tanggal_penjualan, det.kuantitas, det.subtotal
FROM detail_penjualan det
JOIN penjualan p ON (det.penjualan_id = p.penjualan_id)
JOIN pegawai peg ON (p.pegawai_id = peg.pegawai_id)
JOIN pelanggan pel ON (p.pelanggan_id = pel.pelanggan_id)
WHERE buku_id = 'BK000001'

SELECT p.pembelian_id, sup.nama AS nama_supplier, peg.nama AS nama_pegawai, p.tanggal_pembelian, det.kuantitas, det.subtotal
FROM detail_pembelian det
JOIN pembelian p ON (det.pembelian_id = p.pembelian_id)
JOIN pegawai peg ON (p.pegawai_id = peg.pegawai_id)
JOIN supplier sup ON (p.supplier_id = sup.supplier_id)
WHERE buku_id = 'BK000001'

-- Function rekomendasi_pembelian
SELECT * FROM rekomendasi_pembelian(25)

-- Procedure pembelian_buku
CALL pembelian_buku(
	'SP000001',
	'PG000001',
	ARRAY['BK000006'],
	ARRAY[1],
	ARRAY[40000.00]
);

-- Function cari_buku
SELECT * FROM cari_buku('Harry', NULL, NULL);

-- Procedure penjualan_buku (stok cukup)
-- CALL penjualan_buku('PJ0000006', 'Tunai', 'PL000003', 'PG000002', 'BK000002', 10);

CALL penjualan_buku(
  'PJ000009',               -- penjualan_id
  'Kartu',                  -- metode_pembayaran
  'PL000002',               -- pelanggan_id
  'PG000003',               -- pegawai_id
  ARRAY['BK000001', 'BK000003'], -- buku_ids
  ARRAY[2, 1]                    -- kuantitas
);

{
  "penjualan_id": "PJ000009",
  "metode_pembayaran": "Kartu",
  "pelanggan_id": "PL000002",
  "pegawai_id": "PG000003",
  "buku_ids": ["BK000001", "BK000003"],
  "kuantitas": [2, 1]
}


--json:
-- {
--   "penjualan_id": "PJ0000006",
--   "metode_pembayaran": "Tunai",
--   "pelanggan_id": "PL000003",
--   "pegawai_id": "PG000002",
--   "buku_id": "BK000002",
--   "kuantitas": 10
-- }


-- Procedure penjualan_buku (stok tidak cukup)
CALL penjualan_buku('PJ0000007', 'Tunai', 'PL000003', 'PG000002', 'BK000002', 1);

-- json:
-- {
--   "penjualan_id": "PJ0000007",
--   "metode_pembayaran": "Tunai",
--   "pelanggan_id": "PL000003",
--   "pegawai_id": "PG000002",
--   "buku_id": "BK000002",
--   "kuantitas": 100
-- }


-- View laporan_buku_terlaris
SELECT * FROM laporan_buku_terlaris;

-- View tren_penjualan_kategori
SELECT * FROM tren_penjualan_kategori;

-- View laporan_keuangan_bulanan
SELECT * FROM laporan_keuangan_bulanan;

-- Procedure tambah_buku_baru
CALL tambah_buku_baru(
    'KT002', 
	'9780143111584', 
	'tes buku 4',
	2023, 
	300, 
	
	'PG000001', 
	5,
	50000.00,
	
	'PB0001',
	'PN0003',
	
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	NULL,
	
	'SP000002'
);

-- Procedure insert membership
CALL sp_insert_membership(
	'Andre Kim',
  'Gold',                  -- tipe (VARCHAR)
  '08123456733',           -- no_telp (VARCHAR)
  'Jl. Merdeka 123',       -- alamat (VARCHAR)
  TIMESTAMP '2026-06-13 10:00:00'   -- tanggal_kadaluwarsa
);

-- Procedure update membership
CALL sp_update_membership(
  'MB000001',              -- pelanggan_id (CHAR(8))
	'Kim Dan Andre',
  'Platinum',              -- tipe (VARCHAR)
  '08111222333',           -- no_telp (VARCHAR)
  '123 Maple Street',  -- alamat (VARCHAR)
  TIMESTAMP '2100-06-13 10:00:00'   -- tanggal_kadaluwarsa
);

SELECT event_object_table AS table_name,
       trigger_name,
       action_timing,
       event_manipulation,
       action_statement
FROM information_schema.triggers
ORDER BY table_name, trigger_name;

SELECT routine_name,
       routine_type,
       data_type,
       specific_schema
FROM information_schema.routines
WHERE routine_type = 'FUNCTION'
  AND specific_schema NOT IN ('pg_catalog', 'information_schema')
ORDER BY routine_name;

SELECT routine_name,
       specific_schema
FROM information_schema.routines
WHERE routine_type = 'PROCEDURE'
  AND specific_schema NOT IN ('pg_catalog', 'information_schema')
ORDER BY routine_name;

CREATE OR REPLACE FUNCTION cek_jumlah_baris()
RETURNS TABLE(table_name TEXT, row_count BIGINT) AS $$
DECLARE
    table_list TEXT[] := ARRAY[
        'pegawai', 'pelanggan', 'membership', 'supplier',
        'penulis', 'penerbit', 'kategori', 'buku',
        'pembelian', 'penjualan'
    ];
    tbl TEXT;
    count_result BIGINT;
BEGIN
    FOREACH tbl IN ARRAY table_list LOOP
        EXECUTE format('SELECT count(*) FROM %I', tbl) INTO count_result;
        table_name := tbl;
        row_count := count_result;
        RETURN NEXT;
    END LOOP;
END;
$$ LANGUAGE plpgsql;


SELECT * FROM cek_jumlah_baris();

CREATE OR REPLACE PROCEDURE update_nomor_terakhir()
LANGUAGE plpgsql
AS $$
DECLARE
    table_list TEXT[] := ARRAY[
        'pegawai', 'pelanggan', 'membership', 'supplier',
        'penulis', 'penerbit', 'kategori', 'buku',
        'pembelian', 'penjualan'
    ];
    tbl TEXT;
    count_result BIGINT;
BEGIN
    FOREACH tbl IN ARRAY table_list LOOP
        EXECUTE format('SELECT count(*) FROM %I', tbl) INTO count_result;
        UPDATE urutan_id
        SET nomor_terakhir = count_result
        WHERE LOWER(nama_tabel) = tbl;
    END LOOP;
END;
$$;

CALL update_nomor_terakhir();

SELECT * FROM Buku b
JOIN Detail_Pembelian dpb ON b.buku_id = dpb.buku_id
JOIN Pembelian pb ON pb.pembelian_id = dpb.pembelian_id
JOIN Supplier s ON pb.supplier_id = s.supplier_id
WHERE s.supplier_id = 'SP000005'

SELECT * FROM Pembelian p
JOIN Detail_Pembelian dpb ON p.pembelian_id = dpb.pembelian_id
WHERE dpb.pembelian_id = 'PB0000009'

