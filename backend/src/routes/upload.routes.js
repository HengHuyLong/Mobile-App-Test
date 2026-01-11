const express = require('express');
const router = express.Router();
const upload = require('../middlewares/upload.middleware');
const authMiddleware = require('../middlewares/auth.middleware');

router.post(
  '/upload-image',
  authMiddleware,
  upload.single('image'),
  (req, res) => {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'No image uploaded',
      });
    }

    res.json({
      success: true,
      image_url: `upload/images/${req.file.filename}`,
    });
  }
);

module.exports = router;
