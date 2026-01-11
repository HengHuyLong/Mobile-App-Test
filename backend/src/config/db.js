require('dotenv').config();
const sql = require('mssql');

const config = {
  server: process.env.DB_HOST,
  port: 1433,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  options: {
    encrypt: false,
    trustServerCertificate: true,
  },
};

const poolPromise = new sql.ConnectionPool(config)
  .connect()
  .then(pool => {
    console.log('Connected to SQL Server');
    return pool;
  })
  .catch(err => {
    console.error('Database Connection Failed!', err);
  });

module.exports = {
  sql,
  poolPromise,
};
