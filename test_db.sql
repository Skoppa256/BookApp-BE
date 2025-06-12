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
Berdasarkan judul buku
SELECT * FROM cari_buku('Harry', NULL, NULL);

-- Berdasarkan nama penulis
SELECT * FROM cari_buku(NULL, 'Jane Austen', NULL);

-- Berdasarkan kategori
SELECT * FROM cari_buku(NULL, NULL, 'Fiction');

-- Procedure penjualan_buku (stok cukup)
CALL penjualan_buku('PJ0000006', 'Tunai', 'PL000003', 'PG000002', 'BK000002', 10);

-- Procedure penjualan_buku (stok tidak cukup)
CALL penjualan_buku('PJ0000007', 'Tunai', 'PL000003', 'PG000002', 'BK000002', 100);

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
