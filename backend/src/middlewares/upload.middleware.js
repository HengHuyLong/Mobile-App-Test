const multer = require('multer');
const path = require('path');

// ============================
// STORAGE
// ============================
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'upload/images');
  },
  filename: (req, file, cb) => {
    const ext =
      path.extname(file.originalname).toLowerCase() || '.jpg';
    const filename = `product_${Date.now()}${ext}`;
    cb(null, filename);
  },
});

// ============================
// FILE FILTER (FINAL FIX)
// ============================
const fileFilter = (req, file, cb) => {
  const allowedExt = /\.(jpg|jpeg|png|webp|heic|heif)$/i;
  const allowedMime = /^image\//i;

  const hasValidExt = allowedExt.test(file.originalname || '');
  const hasValidMime =
    file.mimetype && allowedMime.test(file.mimetype);

  if (hasValidExt || hasValidMime) {
    return cb(null, true);
  }

  return cb(
    new Error('Only image files allowed'),
    false
  );
};

// ============================
// MULTER INSTANCE
// ============================
const upload = multer({
  storage,
  fileFilter,
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB
  },
});

module.exports = upload;
