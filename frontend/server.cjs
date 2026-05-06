const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const path = require('path');

const app = express();

// Proxy /api requests to backend, keeping the /api prefix
app.use('/api', createProxyMiddleware({
  target: 'http://localhost:8090',
  changeOrigin: true,
  pathRewrite: {
    // DO NOT remove /api, keep it for Spring Security to match
    // '^/api': '', 
  },
}));

app.use(express.static(path.join(__dirname, 'dist')));

// SPA fallback
app.use(function(req, res) {
  res.sendFile(path.join(__dirname, 'dist', 'index.html'));
});

app.listen(3010, function() {
  console.log('Melarium frontend on port 3010');
});
