const http = require('http');
const fs = require('fs');
const path = require('path');

const port = 8080;
const webDir = path.join(__dirname, 'web');

const mimeTypes = {
  '.html': 'text/html',
  '.js': 'text/javascript',
  '.css': 'text/css',
  '.json': 'application/json',
  '.png': 'image/png',
  '.jpg': 'image/jpg',
  '.gif': 'image/gif',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon'
};

const server = http.createServer((req, res) => {
  let filePath = path.join(webDir, req.url === '/' ? 'test-firebase.html' : req.url);
  
  const extname = path.extname(filePath);
  const contentType = mimeTypes[extname] || 'text/plain';
  
  fs.readFile(filePath, (error, content) => {
    if (error) {
      if (error.code === 'ENOENT') {
        // File not found, try test-firebase.html
        fs.readFile(path.join(webDir, 'test-firebase.html'), (err, fallbackContent) => {
          if (err) {
            res.writeHead(500, { 'Content-Type': 'text/plain' });
            res.end('Server Error');
          } else {
            res.writeHead(200, { 'Content-Type': 'text/html' });
            res.end(fallbackContent, 'utf-8');
          }
        });
      } else {
        res.writeHead(500, { 'Content-Type': 'text/plain' });
        res.end('Server Error');
      }
    } else {
      res.writeHead(200, { 'Content-Type': contentType });
      res.end(content, 'utf-8');
    }
  });
});

server.listen(port, () => {
  console.log(`🚀 Firebase Web Test Server running at http://localhost:${port}`);
  console.log(`📱 Open http://localhost:${port}/test-firebase.html to test Firebase`);
  console.log(`🔥 Your Firebase configuration is ready!`);
});

// Handle server shutdown
process.on('SIGINT', () => {
  console.log('\n👋 Server shutting down...');
  server.close(() => {
    console.log('✅ Server closed');
    process.exit(0);
  });
});
