const express = require('express');
const cors = require('cors');
require('dotenv').config();

const authRoutes = require('./routes/auth.routes');
const categoryRoutes = require('./routes/category.routes');
const productRoutes = require('./routes/product.routes');
const uploadRoutes = require('./routes/upload.routes');

const app = express();

app.use(cors());
app.use(express.json());

// ✅ SERVE LOCAL IMAGES FIRST
app.use('/upload', express.static('upload'));

// AUTH
app.use('/api/auth', authRoutes);

// CATEGORIES
app.use('/api/categories', categoryRoutes);

// PRODUCTS
app.use('/api/products', productRoutes);

// IMAGE UPLOAD API
app.use('/api', uploadRoutes);

// ROOT
app.get('/', (req, res) => {
  res.send('Backend API is running');
});

module.exports = app;
