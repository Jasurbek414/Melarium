const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const path = require('path');

const app = express();

app.use('/api', createProxyMiddleware({
  target: 'http://localhost:8090',
  changeOrigin: true,
}));

app.use(express.static(path.join(__dirname, 'dist')));

// SPA fallback - Express 5 compatible
app.use(function(req, res) {
  res.sendFile(path.join(__dirname, 'dist', 'index.html'));
});

app.listen(3010, function() {
  console.log('Melarium frontend on port 3010');
});
