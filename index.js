require('dotenv').config();
const express = require('express');
const bodyParser = require('body-parser');
const { Pool } = require('pg');
const cors = require('cors');

const app = express();
const port = process.env.PORT || 3000;

app.use(express.json());

const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT,
});

app.use(cors());
app.use(bodyParser.json());

app.get('/ping', (req, res) => {
  res.json({ data: 'Hello' });
});

const tables = [
  'Pegawai',
  'Membership',
  'Penulis',
  'Penerbit',
  'Detail_Penjualan',
  'Detail_Pembelian',
  'Buku_Penulis',
];

tables.forEach((table) => {
  const route = `/${table.toLowerCase().replace(/_/g, '-')}`;
  app.get(route, async (req, res) => {
    try {
      const result = await pool.query(`SELECT * FROM ${table}`);
      res.json({ data: result.rows });
    } catch (err) {
      res.status(500).json({ error: err.message });
    }
  });
});

// Daftar Pembelian
app.get('/api/pembelian', async (req, res) => {
  try {
    const result = await pool.query(`
            SELECT p.pembelian_id, DATE(p.tanggal_pembelian) AS tanggal_pembelian, peg.nama AS nama_pegawai, s.nama AS nama_supplier, det.kuantitas, det.total
            FROM (SELECT pembelian_id, SUM(subtotal) AS total, SUM(kuantitas) AS kuantitas
                FROM detail_pembelian
                GROUP BY pembelian_id) det 
            JOIN pembelian p ON (p.pembelian_id = det.pembelian_id)
            JOIN pegawai peg ON (p.pegawai_id = peg.pegawai_id)
            JOIN supplier s ON (p.supplier_id = s.supplier_id)
            ORDER BY p.tanggal_pembelian DESC`);
    res.json({ data: result.rows });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Daftar Penjualan
app.get('/api/penjualan', async (req, res) => {
  try {
    const result = await pool.query(`
            SELECT p.penjualan_id, DATE(p.tanggal_penjualan) AS tanggal_penjualan, p.metode_pembayaran, p.diskon , pel.nama AS nama_pelanggan, peg.nama AS nama_pegawai, det.kuantitas, det.total
            FROM (SELECT penjualan_id, SUM(subtotal) AS total, SUM(kuantitas) AS kuantitas
                FROM detail_penjualan
                GROUP BY penjualan_id) det 
            JOIN penjualan p ON (p.penjualan_id = det.penjualan_id)
            JOIN pegawai peg ON (p.pegawai_id = peg.pegawai_id)
            JOIN pelanggan pel ON (p.pelanggan_id = pel.pelanggan_id)
            ORDER BY p.tanggal_penjualan DESC`);
    res.json({ data: result.rows });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Detail Pembelian by ID
app.get('/api/pembelian/:id', async (req, res) => {
  const { id } = req.params;

  try {
    const detail = await pool.query(
      `
        SELECT p.pembelian_id, p.tanggal_pembelian, s.nama AS nama_supplier, peg.nama AS nama_pegawai
        FROM pembelian p
        JOIN supplier s ON (p.supplier_id = s.supplier_id)
        JOIN pegawai peg ON (peg.pegawai_id = p.pegawai_id)
        WHERE pembelian_id = $1
        `,
      [id]
    );

    const buku = await pool.query(
      `
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
        WHERE det.pembelian_id = $1
        GROUP BY 
            b.judul, p.nama, k.nama, b.isbn, b.tahun_terbit, 
            b.jumlah_halaman, b.harga_beli, b.harga_jual, 
            det.kuantitas, det.subtotal
      `,
      [id]
    );

    const totalResult = await pool.query(
      `
        SELECT SUM(subtotal) AS total
        FROM detail_pembelian
        WHERE pembelian_id = $1
      `,
      [id]
    );

    res.json({
      ...detail.rows[0],
      total: totalResult.rows[0].total || 0,
      buku: buku.rows,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Detail Penjualan by ID
app.get('/api/penjualan/:penjualan_id', async (req, res) => {
  const { penjualan_id } = req.params;

  try {
    const detail = await pool.query(
      `
        SELECT p.penjualan_id, p.tanggal_penjualan, p.metode_pembayaran, p.diskon, pel.nama AS nama_pelanggan, peg.nama AS nama_pegawai
        FROM penjualan p
        JOIN pelanggan pel ON (p.pelanggan_id = pel.pelanggan_id)
        JOIN pegawai peg ON (peg.pegawai_id = p.pegawai_id)
        WHERE penjualan_id = $1
        `,
      [penjualan_id]
    );

    const buku = await pool.query(
      `
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
        WHERE det.penjualan_id = $1
        GROUP BY 
            b.judul, p.nama, k.nama, b.isbn, b.tahun_terbit, 
            b.jumlah_halaman, b.harga_beli, b.harga_jual, 
            det.kuantitas, det.subtotal
      `,
      [penjualan_id]
    );

    const totalResult = await pool.query(
      `
        SELECT SUM(subtotal) AS total
        FROM detail_penjualan
        WHERE penjualan_id = $1
      `,
      [penjualan_id]
    );

    res.json({
      ...detail.rows[0],
      total: totalResult.rows[0].total || 0,
      buku: buku.rows,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Detail Pegawai by ID
app.get('/api/pegawai/:pegawai_id', async (req, res) => {
  const { pegawai_id } = req.params;

  try {
    const detailPegawai = await pool.query(
      `SELECT p.* FROM Pegawai p WHERE p.pegawai_id = $1`,
      [pegawai_id]
    );

    const daftarPembelian = await pool.query(
      `
        SELECT p.pembelian_id, DATE(p.tanggal_pembelian) AS tanggal_pembelian, peg.nama AS nama_pegawai, s.nama AS nama_supplier, det.kuantitas, det.total
        FROM (SELECT pembelian_id, SUM(subtotal) AS total, SUM(kuantitas) AS kuantitas
            FROM detail_pembelian
            GROUP BY pembelian_id) det 
        JOIN pembelian p ON (p.pembelian_id = det.pembelian_id)
        JOIN pegawai peg ON (p.pegawai_id = peg.pegawai_id)
        JOIN supplier s ON (p.supplier_id = s.supplier_id)
        WHERE p.pegawai_id = $1
        ORDER BY p.tanggal_pembelian DESC
      `,
      [pegawai_id]
    );

    const rekapPembelian = await pool.query(
      `
        SELECT SUM(kuantitas) AS kuantitas, SUM(total) AS total
        FROM (SELECT pembelian_id, SUM(subtotal) AS total, SUM(kuantitas) AS kuantitas
            FROM detail_pembelian
            GROUP BY pembelian_id) det 
        JOIN pembelian p ON (p.pembelian_id = det.pembelian_id)
        WHERE p.pegawai_id = $1
      `,
      [pegawai_id]
    );

    const daftarPenjualan = await pool.query(
      `
        SELECT p.penjualan_id, DATE(p.tanggal_penjualan) AS tanggal_penjualan, p.metode_pembayaran, p.diskon , pel.nama AS nama_pelanggan, peg.nama AS nama_pegawai, det.kuantitas, det.total
        FROM (SELECT penjualan_id, SUM(subtotal) AS total, SUM(kuantitas) AS kuantitas
            FROM detail_penjualan
            GROUP BY penjualan_id) det 
        JOIN penjualan p ON (p.penjualan_id = det.penjualan_id)
        JOIN pegawai peg ON (p.pegawai_id = peg.pegawai_id)
        JOIN pelanggan pel ON (p.pelanggan_id = pel.pelanggan_id)
        WHERE p.pegawai_id = $1
        ORDER BY p.tanggal_penjualan DESC
      `,
      [pegawai_id]
    );

    const rekapPenjualan = await pool.query(
      `
        SELECT SUM(kuantitas) AS kuantitas, SUM(total) AS total
        FROM (SELECT penjualan_id, SUM(subtotal) AS total, SUM(kuantitas) AS kuantitas
            FROM detail_penjualan
            GROUP BY penjualan_id) det 
        JOIN penjualan p ON (p.penjualan_id = det.penjualan_id)
        WHERE p.pegawai_id = $1
      `,
      [pegawai_id]
    );

    res.json({
      detail: detailPegawai.rows,
      pembelian: daftarPembelian.rows,
      kuantitas_pembelian: rekapPembelian.rows[0].kuantitas,
      total_pembelian: rekapPembelian.rows[0].total,
      penjualan: daftarPenjualan.rows,
      kuantitas_penjualan: rekapPenjualan.rows[0].kuantitas,
      total_penjualan: rekapPenjualan.rows[0].total,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Detail Pelanggan by ID
app.get('/api/pelanggan/:pelanggan_id', async (req, res) => {
  const { pelanggan_id } = req.params;

  try {
    const detailPelanggan = await pool.query(
      `
        SELECT p.nama, m.tipe, m.no_telp, m.alamat, m.tanggal_pembuatan, m.tanggal_kadaluwarsa
        FROM pelanggan p
        JOIN membership m ON (p.pelanggan_id = m.pelanggan_id)
        WHERE p.pelanggan_id = $1
        `,
      [pelanggan_id]
    );

    const daftarPenjualan = await pool.query(
      `
        SELECT p.penjualan_id, DATE(p.tanggal_penjualan) AS tanggal_penjualan, p.metode_pembayaran, p.diskon , pel.nama AS nama_pelanggan, peg.nama AS nama_pegawai, det.kuantitas, det.total
        FROM (SELECT penjualan_id, SUM(subtotal) AS total, SUM(kuantitas) AS kuantitas
            FROM detail_penjualan
            GROUP BY penjualan_id) det 
        JOIN penjualan p ON (p.penjualan_id = det.penjualan_id)
        JOIN pegawai peg ON (p.pegawai_id = peg.pegawai_id)
        JOIN pelanggan pel ON (p.pelanggan_id = pel.pelanggan_id)
        WHERE p.pelanggan_id = $1
        ORDER BY p.tanggal_penjualan DESC
      `,
      [pelanggan_id]
    );

    const rekapPenjualan = await pool.query(
      `
        SELECT SUM(kuantitas) AS kuantitas, SUM(total) AS total
        FROM (SELECT penjualan_id, SUM(subtotal) AS total, SUM(kuantitas) AS kuantitas
            FROM detail_penjualan
            GROUP BY penjualan_id) det 
        JOIN penjualan p ON (p.penjualan_id = det.penjualan_id)
        WHERE p.pelanggan_id = $1
      `,
      [pelanggan_id]
    );

    res.json({
      detail: detailPelanggan.rows,
      penjualan: daftarPenjualan.rows,
      kuantitas_penjualan: rekapPenjualan.rows[0].kuantitas,
      total_penjualan: rekapPenjualan.rows[0].total,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Detail Buku by ID
app.get('/api/buku/:buku_id', async (req, res) => {
  const { buku_id } = req.params;

  try {
    const detailBuku = await pool.query(
      `
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
        WHERE b.buku_id = $1
        GROUP BY 
            b.judul, p.nama, k.nama, b.isbn, b.tahun_terbit, 
            b.jumlah_halaman, b.harga_beli, b.harga_jual
        `,
      [buku_id]
    );

    const daftarPenjualan = await pool.query(
      `
        SELECT p.penjualan_id, pel.nama AS nama_pelanggan, peg.nama AS nama_pegawai, p.tanggal_penjualan, det.kuantitas, det.subtotal
        FROM detail_penjualan det
        JOIN penjualan p ON (det.penjualan_id = p.penjualan_id)
        JOIN pegawai peg ON (p.pegawai_id = peg.pegawai_id)
        JOIN pelanggan pel ON (p.pelanggan_id = pel.pelanggan_id)
        WHERE buku_id = $1
        ORDER BY p.tanggal_penjualan DESC
      `,
      [buku_id]
    );

    const daftarPembelian = await pool.query(
      `
        SELECT p.pembelian_id, sup.nama AS nama_supplier, peg.nama AS nama_pegawai, p.tanggal_pembelian, det.kuantitas, det.subtotal
        FROM detail_pembelian det
        JOIN pembelian p ON (det.pembelian_id = p.pembelian_id)
        JOIN pegawai peg ON (p.pegawai_id = peg.pegawai_id)
        JOIN supplier sup ON (p.supplier_id = sup.supplier_id)
        WHERE buku_id = $1
        ORDER BY p.tanggal_pembelian DESC
      `,
      [buku_id]
    );

    res.json({
      detail: detailBuku.rows,
      penjualan: daftarPenjualan.rows,
      pembelian: daftarPembelian.rows,
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Login Pegawai
app.post('/api/login', async (req, res) => {
  const { email, no_telp } = req.body;
  if (!email || !no_telp) {
    return res
      .status(400)
      .json({ error: 'Email dan nomor telepon harus diisi.' });
  }

  try {
    const result = await pool.query(
      'SELECT * FROM pegawai WHERE email = $1 AND no_telp = $2',
      [email, no_telp]
    );
    if (result.rows.length === 0) {
      return res.status(401).json({ error: 'Email atau nomor telepon salah.' });
    }
    res.json({ data: result.rows[0] });
  } catch (err) {
    console.error('Error during login:', err);
    res
      .status(500)
      .json({ error: err.message || 'Terjadi kesalahan pada server.' });
  }
});

// Rekomendasi Pembelian
app.get('/api/rekomendasi-pembelian', async (req, res) => {
  const { max_stock } = req.query;
  try {
    const result = await pool.query('SELECT * FROM rekomendasi_pembelian($1)', [
      max_stock,
    ]);
    res.json({ data: result.rows });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Cari Buku
// GET /cari-buku?kategori=Harry
app.get('/api/cari-buku', async (req, res) => {
  const { keyword, kategori, tahun_terbit } = req.query;

  try {
    const result = await pool.query(
      `SELECT * FROM cari_buku($1::TEXT, $2::VARCHAR, $3::INT)`,
      [
        keyword || null,
        kategori || null,
        tahun_terbit ? parseInt(tahun_terbit) : null,
      ]
    );
    res.json({ data: result.rows });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Pembelian Buku
app.post('/api/pembelian-buku', async (req, res) => {
  const { supplier_id, pegawai_id, buku_ids, kuantitas, harga_belis } =
    req.body;

  if (
    !supplier_id ||
    !pegawai_id ||
    !Array.isArray(buku_ids) ||
    !Array.isArray(kuantitas) ||
    !Array.isArray(harga_belis)
  ) {
    return res
      .status(400)
      .json({ error: 'Semua field dan array harus diisi dengan benar.' });
  }

  if (
    ![kuantitas.length, harga_belis.length].every(
      (len) => len === buku_ids.length
    )
  ) {
    return res
      .status(400)
      .json({ error: 'Semua array harus memiliki panjang yang sama.' });
  }

  try {
    await pool.query(
      'CALL pembelian_buku($1, $2, $3::CHAR(8)[], $4::INT[], $5::DECIMAL(10,2)[])',
      [supplier_id, pegawai_id, buku_ids, kuantitas, harga_belis]
    );
    res.status(201).json({ data: 'Pembelian berhasil disimpan.' });
  } catch (err) {
    console.error('Error executing pembelian_buku:', err);
    res.status(500).json({ error: err.message });
  }
});

// Get Pelanggan by No Telp
app.get('/api/pelanggan/phone/:no_telp', async (req, res) => {
  const { no_telp } = req.params;
  try {
    const result = await pool.query(
      'SELECT * FROM pelanggan p JOIN membership m ON m.pelanggan_id = p.pelanggan_id WHERE m.no_telp = $1',
      [no_telp]
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Pelanggan tidak ditemukan.' });
    }
    res.json({ data: result.rows[0] });
  } catch (err) {
    console.error('Error fetching pelanggan:', err);
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/suppliers/:supplier_id/books', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT DISTINCT(b.buku_id), b.judul FROM Buku b JOIN Detail_Pembelian dpb ON b.buku_id = dpb.buku_id JOIN Pembelian pb ON pb.pembelian_id = dpb.pembelian_id JOIN Supplier s ON pb.supplier_id = s.supplier_id WHERE s.supplier_id = $1',
      [req.params.supplier_id]
    );
    res.json({ data: result.rows });
  } catch (err) {
    console.error('Error fetching supplier books:', err);
    res.status(500).json({ error: err.message });
  }
});

// Proses penjualan buku
//penjualan buku
app.post('/api/penjualan-buku', async (req, res) => {
  const {
    metode_pembayaran,
    no_telp_pelanggan,
    pegawai_id,
    buku_ids,
    kuantitas,
  } = req.body;

  if (
    !metode_pembayaran ||
    !no_telp_pelanggan ||
    !pegawai_id ||
    !Array.isArray(buku_ids) ||
    !Array.isArray(kuantitas)
  ) {
    return res
      .status(400)
      .json({ error: 'Semua field dan array harus diisi dengan benar.' });
  }

  if (buku_ids.length !== kuantitas.length) {
    return res
      .status(400)
      .json({ error: 'Jumlah item di array tidak konsisten.' });
  }

  try {
    await pool.query(
      'CALL penjualan_buku($1, $2, $3, $4::CHAR(8)[], $5::INT[])',
      [metode_pembayaran, no_telp_pelanggan, pegawai_id, buku_ids, kuantitas]
    );
    res.status(201).json({ message: 'Penjualan berhasil disimpan.' });
  } catch (err) {
    console.error('Error during penjualan:', err);
    res.status(500).json({ error: err.message });
  }
});

//

// insert new membership
app.post('/api/membership/insert', async (req, res) => {
  const {
    nama,
    tipe,
    no_telp,
    alamat,
    tanggal_kadaluwarsa,
  } = req.body;

  try {
    await pool.query('CALL sp_insert_membership($1, $2, $3, $4, $5)', [
      nama,
      tipe,
      no_telp,
      alamat,
      tanggal_kadaluwarsa,
    ]);
    res.status(201).json({ data: 'Membership berhasil ditambahkan.' });
  } catch (err) {
    console.error('Error in sp_insert_membership:', err);
    res.status(500).json({ error: err.message });
  }
});

// Manajemen membership
// Update membership
app.put('/api/membership/update', async (req, res) => {
  const { membership_id, nama, tipe, no_telp, alamat, tanggal_kadaluwarsa } = req.body;

  try {
    await pool.query('CALL sp_update_membership($1, $2, $3, $4, $5, $6)', [
      membership_id,
      nama,
      tipe,
      no_telp,
      alamat,
      tanggal_kadaluwarsa,
    ]);
    res.status(200).json({ data: 'Membership berhasil diperbarui.' });
  } catch (err) {
    console.error('Error in sp_update_membership:', err);
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/supplier', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM supplier');
    res.json({ data: result.rows });
  } catch (err) {
    console.error('Error fetching suppliers:', err);
    res.status(500).json({ error: err.message });
  }
});

app.get('/api/kategori', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM kategori');
    res.json({ data: result.rows });
  } catch (err) {
    console.error('Error fetching kategori:', err);
    res.status(500).json({ error: err.message });
  }
});

// Endpoint: Laporan Buku Terlaris
app.get('/api/laporan/terlaris', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM laporan_buku_terlaris');
    res.json({ data: result.rows });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Gagal mengambil data buku terlaris' });
  }
});

// Endpoint: Tren Penjualan per Kategori
app.get('/api/laporan/tren-kategori', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM tren_penjualan_kategori');
    res.json({ data: result.rows });
  } catch (err) {
    console.error(err);
    res
      .status(500)
      .json({ error: 'Gagal mengambil tren penjualan per kategori' });
  }
});

// Endpoint: Laporan Keuangan Bulanan
app.get('/api/laporan/keuangan-bulanan', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM laporan_keuangan_bulanan');
    res.json({ data: result.rows });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Gagal mengambil laporan keuangan bulanan' });
  }
});


// Tambah Buku
app.post('/api/tambah_buku', async (req, res) => {
    const {
      kategori_id,
      isbn,
      judul,
      tahun_terbit,
      jumlah_halaman,
  
      pegawai_id,
      kuantitas,
      harga_beli,
  
      penerbit_id,
      penulis_id,
  
      tul_nama_penulis,
      pen_nama,
      pen_alamat,
      pen_email,
      pen_no_telp,
  
      s_nama,
      s_no_telp,
      s_alamat,
  
      supplier_id
    } = req.body;
  
    // Basic validation
    if (
      !kategori_id || !isbn || !judul || !tahun_terbit || !jumlah_halaman ||
      !pegawai_id || !kuantitas || !harga_beli
    ) {
      return res.status(400).json({ error: 'Data buku, pegawai, kuantitas, dan harga beli wajib diisi.' });
    }
  
    try {
      const query = `
        CALL tambah_buku_baru(
          $1, $2, $3, $4, $5,
          $6, $7, $8,
          $9, $10,
          $11, $12, $13, $14, $15,
          $16, $17, $18,
          $19
        )
      `;
  
      const values = [
        kategori_id,
        isbn,
        judul,
        tahun_terbit,
        jumlah_halaman,
  
        pegawai_id,
        kuantitas,
        harga_beli,
  
        penerbit_id,
        penulis_id,
  
        tul_nama_penulis,
        pen_nama,
        pen_alamat,
        pen_email,
        pen_no_telp,
  
        s_nama,
        s_no_telp,
        s_alamat,
  
        supplier_id
      ];
  
      await pool.query(query, values);
  
      res.status(201).json({ message: 'Buku baru berhasil ditambahkan beserta pembelian awal.' });
    } catch (err) {
      console.error('Error in tambah_buku_baru:', err);
      res.status(500).json({ error: 'Gagal menambahkan buku.', detail: err.message });
    }
});


// Start server
app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
