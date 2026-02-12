require('dotenv').config();
const express = require('express');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Serve a dynamic Supabase config JS file populated from server env
app.get('/supabase/config.js', (req, res) => {
  res.type('application/javascript');
  const url = process.env.SUPABASE_URL || '';
  const anon = process.env.SUPABASE_ANON_KEY || '';
  res.send(`window.SUPABASE_CONFIG = ${JSON.stringify({ url, anonKey: anon })};`);
});

// Serve static files from the repository root
app.use(express.static(path.join(__dirname)));

// Simple healthcheck
app.get('/health', (req, res) => res.json({ status: 'ok' }));

app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});
