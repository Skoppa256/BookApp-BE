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
  'Supplier',
  'Penulis',
  'Penerbit',
  'Kategori',
  'Buku',
  'Pembelian',
  'Penjualan',
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

// Login Pegawai
app.post('/login', async (req, res) => {
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
app.get('/rekomendasi-pembelian', async (req, res) => {
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
// GET /cari-buku?judul=Harry&penulis=&kategori=
app.get('/cari-buku', async (req, res) => {
  const { judul, penulis, kategori, isbn, tahun_terbit } = req.query;
  try {
    const result = await pool.query(
      'SELECT * FROM cari_buku($1, $2, $3, $4, $5)',
      [
        judul || null,
        penulis || null,
        kategori || null,
        isbn || null,
        tahun_terbit || null,
      ]
    );
    res.json({ data: result.rows });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Pembelian Buku
app.post('/pembelian-buku', async (req, res) => {
  const {
    supplier_id,
    pegawai_id,
    buku_ids,
    kuantitas,
    subtotals,
    harga_belis,
  } = req.body;

  if (
    !supplier_id ||
    !pegawai_id ||
    !Array.isArray(buku_ids) ||
    !Array.isArray(kuantitas) ||
    !Array.isArray(subtotals) ||
    !Array.isArray(harga_belis)
  ) {
    return res
      .status(400)
      .json({ error: 'Semua field dan array harus diisi dengan benar.' });
  }

  if (
    ![kuantitas.length, subtotals.length, harga_belis.length].every(
      (len) => len === buku_ids.length
    )
  ) {
    return res
      .status(400)
      .json({ error: 'Semua array harus memiliki panjang yang sama.' });
  }

  try {
    await pool.query(
      'CALL pembelian_buku($1, $2, $3::CHAR(8)[], $4::INT[], $5::DECIMAL(10,2)[], $6::DECIMAL(10,2)[])',
      [supplier_id, pegawai_id, buku_ids, kuantitas, subtotals, harga_belis]
    );
    res.status(201).json({ data: 'Pembelian berhasil disimpan.' });
  } catch (err) {
    console.error('Error executing pembelian_buku:', err);
    res.status(500).json({ error: err.message });
  }
});

// Get Pelanggan by No Telp
app.get('/pelanggan', async (req, res) => {
  const { no_telp } = req.query;
  if (!no_telp) {
    return res.status(400).json({ error: 'Nomor telepon harus diisi.' });
  }
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

// Start server
app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});

// Proses penjualan buku
//penjualan buku
app.post('/penjualan', async (req, res) => {
  const {
    penjualan_id,
    metode_pembayaran,
    pelanggan_id,
    pegawai_id,
    buku_ids,
    kuantitas,
  } = req.body;

  if (
    !penjualan_id ||
    !metode_pembayaran ||
    !pelanggan_id ||
    !pegawai_id ||
    !Array.isArray(buku_ids) ||
    !Array.isArray(kuantitas)
  ) {
    return res.status(400).json({ error: 'Semua field dan array harus diisi dengan benar.' });
  }

  if (buku_ids.length !== kuantitas.length) {
    return res.status(400).json({ error: 'Jumlah item di array tidak konsisten.' });
  }

  try {
    await pool.query(
      'CALL penjualan_buku($1, $2, $3, $4, $5::CHAR(8)[], $6::INT[])',
      [penjualan_id, metode_pembayaran, pelanggan_id, pegawai_id, buku_ids, kuantitas]
    );
    res.status(201).json({ message: 'Penjualan berhasil disimpan.' });
  } catch (err) {
    console.error('Error during penjualan:', err);
    res.status(500).json({ error: err.message });
  }
});


//

// insert new membership
app.post('/membership/insert', async (req, res) => {
  const {
    pelanggan_id,
    tipe,
    no_telp,
    alamat,
    tanggal_pembuatan,
    tanggal_kadaluwarsa
  } = req.body;

  try {
    await pool.query(
      'CALL sp_insert_membership($1, $2, $3, $4, $5, $6)',
      [pelanggan_id, tipe, no_telp, alamat, tanggal_pembuatan, tanggal_kadaluwarsa]
    );
    res.status(201).json({ data: 'Membership berhasil ditambahkan.' });
  } catch (err) {
    console.error('Error in sp_insert_membership:', err);
    res.status(500).json({ error: err.message });
  }
});


// Manajemen membership
// Update membership
app.put('/membership/update', async (req, res) => {
  const {
    pelanggan_id,
    tipe,
    no_telp,
    alamat,
    tanggal_kadaluwarsa
  } = req.body;

  try {
    await pool.query(
      'CALL sp_update_membership($1, $2, $3, $4, $5)',
      [pelanggan_id, tipe, no_telp, alamat, tanggal_kadaluwarsa]
    );
    res.status(200).json({ data: 'Membership berhasil diperbarui.' });
  } catch (err) {
    console.error('Error in sp_update_membership:', err);
    res.status(500).json({ error: err.message });
  }
});
