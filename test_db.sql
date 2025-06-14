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

-- Function rekomendasi_pembelian
SELECT * FROM rekomendasi_pembelian(25)

-- Procedure pembelian_buku
CALL pembelian_buku(
	'SP000001',
	'PG000001',
	ARRAY['BK000002', 'BK000001'],
	ARRAY[100, 100],
	ARRAY[400000.00, 175000.00],
	ARRAY[40000.00, 35000.00]
);

-- Function cari_buku
SELECT * FROM cari_buku('Harry', NULL, NULL);

-- Procedure penjualan_buku (stok cukup)
CALL penjualan_buku(
	'Tunai',
	'08111222333',
	'PG000002',
	ARRAY['BK000002', 'BK000001'],
	ARRAY[1,1]
);

-- Procedure penjualan_buku (stok tidak cukup)
CALL penjualan_buku('PJ0000007', 'Tunai', 'PL000003', 'PG000002', 'BK000002', 100);

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
    'BK000006', '9780143111580', 'tes buku',
    'KT002', 'PB0002', 'PN0002',
    2023, 300, 70000.00, 50
);

-- Procedure insert membership
CALL sp_insert_membership(
  'PL000006',              -- pelanggan_id (CHAR(8))Add commentMore actions
  'Gold',                  -- tipe (VARCHAR)
  '08123456789',           -- no_telp (VARCHAR)
  'Jl. Merdeka 123',       -- alamat (VARCHAR)
  TIMESTAMP '2025-06-13 10:00:00',  -- tanggal_pembuatan
  TIMESTAMP '2026-06-13 10:00:00'   -- tanggal_kadaluwarsa
);

-- Procedure update membership
CALL sp_update_membership(
  'PL000001',              -- pelanggan_id (CHAR(8))
  'Platinum',              -- tipe (VARCHAR)
  '08123456789',           -- no_telp (VARCHAR)
  'Jl. Merdeka Baru 456',  -- alamat (VARCHAR)
  TIMESTAMP '2027-06-13 10:00:00'   -- tanggal_kadaluwarsa
);
