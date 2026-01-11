const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransport({
  host: process.env.EMAIL_HOST,
  port: process.env.EMAIL_PORT,
  secure: false, // true for 465, false for 587
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

exports.sendOtpEmail = async (toEmail, otp) => {
  await transporter.sendMail({
    from: `"No Reply" <${process.env.EMAIL_USER}>`,
    to: toEmail,
    subject: 'Password Reset OTP',
    html: `
      <h2>Password Reset</h2>
      <p>Your OTP is:</p>
      <h1>${otp}</h1>
      <p>This code will expire in 15 minutes.</p>
    `,
  });
};
