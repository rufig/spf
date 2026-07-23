#!/usr/bin/env node
// serve.js -- tiny static server for the spf64 highlight demo.
// Sends COOP/COEP headers: spf-min.wasm imports a SHARED memory, and browsers
// only allow SharedArrayBuffer on cross-origin-isolated pages.
//   node serve.js [port]     (default 8642)
'use strict';
const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = +(process.argv[2] || 8642);
const ROOT = __dirname;
const MIME = { '.html': 'text/html; charset=utf-8', '.js': 'text/javascript', '.wasm': 'application/wasm', '.css': 'text/css' };

http.createServer((req, res) => {
  let p = decodeURIComponent(req.url.split('?')[0]);
  if (p === '/') p = '/demo.html';
  const file = path.join(ROOT, path.normalize(p));
  if (!file.startsWith(ROOT) || !fs.existsSync(file) || !fs.statSync(file).isFile()) {
    res.writeHead(404); res.end('not found'); return;
  }
  res.writeHead(200, {
    'Content-Type': MIME[path.extname(file)] || 'application/octet-stream',
    'Cross-Origin-Opener-Policy': 'same-origin',
    'Cross-Origin-Embedder-Policy': 'require-corp',
    'Cache-Control': 'no-cache',
  });
  fs.createReadStream(file).pipe(res);
}).listen(PORT, () => console.log('spf64 highlight demo: http://localhost:' + PORT + '/'));
