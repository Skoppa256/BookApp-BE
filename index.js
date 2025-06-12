require('dotenv').config();
const express = require('express');
const bodyParser = require('body-parser');
const { Pool } = require('pg');

const app = express();
const port = process.env.PORT || 3000;

// PostgreSQL pool setup using environment variables
const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT,
});

app.use(bodyParser.json());

// CRUD API endpoints...

app.get('/ping', (req, res)=>{
    res.send('Hello')
})

// GET all pegawai
app.get('/pegawai', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM Pegawai');
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET all pelanggan
app.get('/pelanggan', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM Pelanggan');
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET all membership
app.get('/membership', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM Membership');
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET all supplier
app.get('/supplier', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM Supplier');
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET all penulis
app.get('/penulis', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM Penulis');
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET all penerbit
app.get('/penerbit', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM Penerbit');
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET all kategori
app.get('/kategori', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM Kategori');
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET all buku
app.get('/buku', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM Buku');
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET all pembelian
app.get('/pembelian', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM Pembelian');
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET all penjualan
app.get('/penjualan', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM Penjualan');
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET all detail_penjualan
app.get('/detail_penjualan', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM Detail_Penjualan');
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET all detail_pembelian
app.get('/detail_pembelian', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM Detail_Pembelian');
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// GET all buku_penulis
app.get('/buku_penulis', async (req, res) => {
    try {
        const result = await pool.query('SELECT * FROM Buku_Penulis');
        res.json(result.rows);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Rekomendasi Pembelian
// GET /rekomendasi-pembelian?max_stock=25
app.get('/rekomendasi-pembelian', async (req, res) => {
    const { max_stock } = req.query;
    try {
        const result = await pool.query('SELECT * FROM rekomendasi_pembelian($1)', [max_stock]);
        res.json(result.rows);
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
            [judul || null, penulis || null, kategori || null, isbn || null, tahun_terbit || null]
        );
        res.json(result.rows);
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
      harga_belis
    } = req.body;
  
    // Validation
    if (
      !supplier_id || !pegawai_id ||
      !Array.isArray(buku_ids) ||
      !Array.isArray(kuantitas) ||
      !Array.isArray(subtotals) ||
      !Array.isArray(harga_belis)
    ) {
      return res.status(400).json({ error: 'Semua field dan array harus diisi dengan benar.' });
    }
  
    if (
      ![kuantitas.length, subtotals.length, harga_belis.length].every(len => len === buku_ids.length)
    ) {
      return res.status(400).json({ error: 'Semua array harus memiliki panjang yang sama.' });
    }
  
    try {
      await pool.query(
        'CALL pembelian_buku($1, $2, $3::CHAR(8)[], $4::INT[], $5::DECIMAL(10,2)[], $6::DECIMAL(10,2)[])',
        [
          supplier_id,
          pegawai_id,
          buku_ids,
          kuantitas,
          subtotals,
          harga_belis
        ]
      );
  
      res.status(201).json({ message: 'Pembelian berhasil disimpan.' });
    } catch (err) {
      console.error('Error executing pembelian_buku:', err);
      res.status(500).json({ error: err.message });
    }
  });
  



// // GET all users
// app.get('/users', async (req, res) => {
//   try {
//     const result = await pool.query('SELECT * FROM users ORDER BY id ASC');
//     res.json(result.rows);
//   } catch (err) {
//     res.status(500).json({ error: err.message });
//   }
// });

// // GET user by ID
// app.get('/users/:id', async (req, res) => {
//   const id = parseInt(req.params.id);
//   try {
//     const result = await pool.query('SELECT * FROM users WHERE id = $1', [id]);
//     if (result.rows.length === 0) return res.status(404).json({ message: 'User not found' });
//     res.json(result.rows[0]);
//   } catch (err) {
//     res.status(500).json({ error: err.message });
//   }
// });

// // CREATE user
// app.post('/users', async (req, res) => {
//   const { name, email } = req.body;
//   try {
//     const result = await pool.query(
//       'INSERT INTO users (name, email) VALUES ($1, $2) RETURNING *',
//       [name, email]
//     );
//     res.status(201).json(result.rows[0]);
//   } catch (err) {
//     res.status(500).json({ error: err.message });
//   }
// });

// // UPDATE user
// app.put('/users/:id', async (req, res) => {
//   const id = parseInt(req.params.id);
//   const { name, email } = req.body;
//   try {
//     const result = await pool.query(
//       'UPDATE users SET name = $1, email = $2 WHERE id = $3 RETURNING *',
//       [name, email, id]
//     );
//     if (result.rows.length === 0) return res.status(404).json({ message: 'User not found' });
//     res.json(result.rows[0]);
//   } catch (err) {
//     res.status(500).json({ error: err.message });
//   }
// });

// // DELETE user
// app.delete('/users/:id', async (req, res) => {
//   const id = parseInt(req.params.id);
//   try {
//     const result = await pool.query('DELETE FROM users WHERE id = $1 RETURNING *', [id]);
//     if (result.rows.length === 0) return res.status(404).json({ message: 'User not found' });
//     res.json({ message: 'User deleted', user: result.rows[0] });
//   } catch (err) {
//     res.status(500).json({ error: err.message });
//   }
// });

// Start server
app.listen(port, () => {
  console.log(`Server running at http://localhost:${port}`);
});
