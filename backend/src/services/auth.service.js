const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { poolPromise, sql } = require('../config/db');
const { sendOtpEmail } = require('./email.service');

/* =========================
   HELPERS
========================= */

const isValidEmail = (email) =>
  /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);

const isStrongPassword = (password) =>
  password.length >= 8 &&
  /[A-Za-z]/.test(password) &&
  /\d/.test(password);

const generateOtp = () =>
  Math.floor(100000 + Math.random() * 900000).toString();

/* =========================
   LOGIN
========================= */

exports.login = async ({ email, password }) => {
  if (!email || !password) {
    throw { status: 400, message: 'Email and password are required' };
  }

  const pool = await poolPromise;

  const result = await pool
    .request()
    .input('email', sql.NVarChar, email)
    .query(
      'SELECT id, email, password_hash FROM users WHERE email = @email'
    );

  if (result.recordset.length === 0) {
    throw { status: 401, message: 'Invalid credentials' };
  }

  const user = result.recordset[0];
  const passwordMatch = await bcrypt.compare(
    password,
    user.password_hash
  );

  if (!passwordMatch) {
    throw { status: 401, message: 'Invalid credentials' };
  }

  const token = jwt.sign(
    { id: user.id, email: user.email },
    process.env.JWT_SECRET,
    { expiresIn: '1h' }
  );

  return {
    token,
    user: {
      id: user.id,
      email: user.email,
    },
  };
};

/* =========================
   SIGN UP
========================= */

exports.signup = async ({ email, password }) => {
  if (!email || !password) {
    throw { status: 400, message: 'Email and password are required' };
  }

  if (!isValidEmail(email)) {
    throw { status: 400, message: 'Invalid email format' };
  }

  if (!isStrongPassword(password)) {
    throw {
      status: 400,
      message:
        'Password must be at least 8 characters and include letters and numbers',
    };
  }

  const pool = await poolPromise;

  const existingUser = await pool
    .request()
    .input('email', sql.NVarChar, email)
    .query('SELECT id FROM users WHERE email = @email');

  if (existingUser.recordset.length > 0) {
    throw { status: 409, message: 'Email already exists' };
  }

  const passwordHash = await bcrypt.hash(password, 10);

  await pool
    .request()
    .input('email', sql.NVarChar, email)
    .input('password_hash', sql.NVarChar, passwordHash)
    .query(`
      INSERT INTO users (email, password_hash)
      VALUES (@email, @password_hash)
    `);

  return { message: 'User registered successfully' };
};

/* =========================
   FORGOT PASSWORD
========================= */
exports.forgotPassword = async (email) => {
  if (!email) {
    throw { status: 400, message: 'Email is required' };
  }

  const pool = await poolPromise;

  const userResult = await pool
    .request()
    .input('email', sql.NVarChar, email)
    .query('SELECT id FROM users WHERE email = @email');

  if (userResult.recordset.length === 0) {
    throw { status: 404, message: 'Email not found' };
  }

  const userId = userResult.recordset[0].id;

  // Delete old OTPs
  await pool
    .request()
    .input('user_id', sql.Int, userId)
    .query('DELETE FROM password_resets WHERE user_id = @user_id');

  const otp = generateOtp();

  await pool
    .request()
    .input('user_id', sql.Int, userId)
    .input('otp', sql.NVarChar, otp)
    .query(`
      INSERT INTO password_resets (user_id, otp, expires_at)
      VALUES (@user_id, @otp, DATEADD(MINUTE, 15, GETDATE()))
    `);

  // ✅ SEND REAL EMAIL
  await sendOtpEmail(email, otp);
};


/* =========================
   RESET PASSWORD
========================= */

exports.resetPassword = async ({ email, otp, newPassword }) => {
  if (!email || !otp || !newPassword) {
    throw { status: 400, message: 'All fields are required' };
  }

  if (!isStrongPassword(newPassword)) {
    throw {
      status: 400,
      message:
        'Password must be at least 8 characters and include letters and numbers',
    };
  }

  const pool = await poolPromise;

  const result = await pool
    .request()
    .input('email', sql.NVarChar, email)
    .input('otp', sql.NVarChar, otp)
    .query(`
      SELECT pr.id, u.id AS user_id
      FROM password_resets pr
      JOIN users u ON pr.user_id = u.id
      WHERE u.email = @email
        AND pr.otp = @otp
        AND pr.expires_at > GETDATE()
    `);

  if (result.recordset.length === 0) {
    throw { status: 400, message: 'Invalid or expired OTP' };
  }

  const userId = result.recordset[0].user_id;
  const resetId = result.recordset[0].id;

  const passwordHash = await bcrypt.hash(newPassword, 10);

  await pool
    .request()
    .input('user_id', sql.Int, userId)
    .input('password_hash', sql.NVarChar, passwordHash)
    .query(`
      UPDATE users
      SET password_hash = @password_hash
      WHERE id = @user_id
    `);

  await pool
    .request()
    .input('id', sql.Int, resetId)
    .query('DELETE FROM password_resets WHERE id = @id');
};
