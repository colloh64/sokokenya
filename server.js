const express = require('express');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// Serve static files from the repository root
app.use(express.static(path.join(__dirname)));

// Simple healthcheck
app.get('/health', (req, res) => res.json({ status: 'ok' }));

app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});
