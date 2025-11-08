const express = require('express');
const os = require('os');

const app = express();
const PORT = process.env.PORT || 3000;
const COLOR = process.env.APP_COLOR || 'blue';
const VERSION = process.env.APP_VERSION || '1.0.0';
const ENV = process.env.APP_ENV || 'blue';

app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    env: ENV,
    color: COLOR,
    version: VERSION,
    host: os.hostname(),
    timestamp: new Date().toISOString()
  });
});

app.get('/', (req, res) => {
  res.send(`
    <html>
      <head>
        <title>Blue-Green Demo</title>
        <style>
          body { font-family: Arial, sans-serif; background: #0f172a; color: #e2e8f0; margin: 0; }
          main { min-height: 100vh; display: flex; flex-direction: column; justify-content: center; align-items: center; }
          .card { background: rgba(15, 23, 42, 0.9); padding: 2rem 3rem; border-radius: 0.5rem; box-shadow: 0 20px 35px rgba(15, 23, 42, 0.5); }
          .pill { padding: 0.35rem 0.75rem; border-radius: 999px; background: ${COLOR === 'green' ? '#22c55e' : '#3b82f6'}; color: #0f172a; font-weight: 600; }
          table { width: 100%; margin-top: 1rem; border-collapse: collapse; }
          td { padding: 0.5rem 0; border-bottom: 1px solid rgba(148, 163, 184, 0.2); }
          td:first-child { color: #94a3b8; text-transform: uppercase; font-size: 0.8rem; }
        </style>
      </head>
      <body>
        <main>
          <div class="card">
            <div class="pill">${ENV.toUpperCase()} (${COLOR})</div>
            <h1>Blue-Green Deployment Demo</h1>
            <p>Seamless deployments without downtime.</p>
            <table>
              <tr><td>Version</td><td>${VERSION}</td></tr>
              <tr><td>Host</td><td>${os.hostname()}</td></tr>
              <tr><td>Timestamp</td><td>${new Date().toLocaleString()}</td></tr>
            </table>
          </div>
        </main>
      </body>
    </html>
  `);
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT} for ${ENV} environment`);
});
