const authService = require('../services/auth.service');

exports.login = async (req, res) => {
  try {
    const result = await authService.login(req.body);
    res.json(result);
  } catch (err) {
    res.status(err.status || 401).json({
      message: err.message || 'Invalid credentials',
    });
  }
};

exports.signup = async (req, res) => {
  try {
    const result = await authService.signup(req.body);
    res.status(201).json(result);
  } catch (err) {
    res.status(err.status || 400).json({
      message: err.message || 'Signup failed',
    });
  }
};

exports.forgotPassword = async (req, res) => {
  try {
    await authService.forgotPassword(req.body.email);
    res.json({ message: 'OTP sent to email' });
  } catch (err) {
    res.status(err.status || 400).json({
      message: err.message || 'Failed to process request',
    });
  }
};

exports.resetPassword = async (req, res) => {
  try {
    await authService.resetPassword(req.body);
    res.json({ message: 'Password reset successful' });
  } catch (err) {
    res.status(err.status || 400).json({
      message: err.message || 'Password reset failed',
    });
  }
};
