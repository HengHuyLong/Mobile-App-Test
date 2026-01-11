const { sql, poolPromise } = require('../config/db');

/**
 * ==========================
 * GET /products
 * (already implemented)
 * ==========================
 */
exports.getProducts = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const search = req.query.search?.trim() || null;
    const categoryId = req.query.category_id
      ? parseInt(req.query.category_id)
      : null;

    const sortBy = req.query.sort_by === 'price' ? 'price' : 'name';
    const sortOrder = req.query.sort_order === 'desc' ? 'desc' : 'asc';
    const offset = (page - 1) * limit;

    const pool = await poolPromise;

    let dataQuery = `
      SELECT
        p.id,
        p.name,
        p.description,
        p.price,
        p.image_url,
        p.category_id,
        c.name AS category_name,
        p.created_at
      FROM dbo.products p
      INNER JOIN dbo.categories c ON p.category_id = c.id
      WHERE 1 = 1
    `;

    if (search) {
      dataQuery += `
        AND p.name COLLATE Khmer_100_CI_AI LIKE N'%' + @search + N'%'
      `;
    }

    if (categoryId) {
      dataQuery += `
        AND p.category_id = @category_id
      `;
    }

    dataQuery += `
      ORDER BY ${
        sortBy === 'name'
          ? `p.name COLLATE Khmer_100_CI_AI ${sortOrder}`
          : `p.price ${sortOrder}`
      },
      p.created_at DESC
      OFFSET @offset ROWS
      FETCH NEXT @limit ROWS ONLY;
    `;

    const dataRequest = pool.request();
    dataRequest.input('offset', sql.Int, offset);
    dataRequest.input('limit', sql.Int, limit);

    if (search) {
      dataRequest.input('search', sql.NVarChar, search);
    }
    if (categoryId) {
      dataRequest.input('category_id', sql.Int, categoryId);
    }

    const dataResult = await dataRequest.query(dataQuery);

    let countQuery = `
      SELECT COUNT(*) AS total
      FROM dbo.products p
      WHERE 1 = 1
    `;

    if (search) {
      countQuery += `
        AND p.name COLLATE Khmer_100_CI_AI LIKE N'%' + @search + N'%'
      `;
    }
    if (categoryId) {
      countQuery += `
        AND p.category_id = @category_id
      `;
    }

    const countRequest = pool.request();
    if (search) {
      countRequest.input('search', sql.NVarChar, search);
    }
    if (categoryId) {
      countRequest.input('category_id', sql.Int, categoryId);
    }

    const countResult = await countRequest.query(countQuery);
    const total = countResult.recordset[0].total;

    res.status(200).json({
      success: true,
      data: dataResult.recordset,
      pagination: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    });
  } catch (error) {
    console.error('Get products error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch products',
    });
  }
};

/**
 * ==========================
 * POST /products
 * ==========================
 */
exports.createProduct = async (req, res) => {
  try {
    const { name, description, price, image_url, category_id } = req.body;

    if (!name || !price || !category_id) {
      return res.status(400).json({
        success: false,
        message: 'Name, price, and category are required',
      });
    }

    const pool = await poolPromise;
    const request = pool.request();

    request.input('name', sql.NVarChar, name);
    request.input('description', sql.NVarChar, description || null);
    request.input('price', sql.Decimal(18, 2), price);
    request.input('image_url', sql.NVarChar, image_url || null);
    request.input('category_id', sql.Int, category_id);

    await request.query(`
      INSERT INTO dbo.products
        (name, description, price, image_url, category_id)
      VALUES
        (@name, @description, @price, @image_url, @category_id);
    `);

    res.status(201).json({
      success: true,
      message: 'Product created successfully',
    });
  } catch (error) {
    console.error('Create product error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create product',
    });
  }
};

/**
 * ==========================
 * PUT /products/:id
 * ==========================
 */
exports.updateProduct = async (req, res) => {
  try {
    const { id } = req.params;
    const { name, description, price, image_url, category_id } = req.body;

    if (!id || isNaN(id)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid product ID',
      });
    }

    const pool = await poolPromise;

    // Check existence
    const check = await pool
      .request()
      .input('id', sql.Int, id)
      .query('SELECT id FROM dbo.products WHERE id = @id');

    if (check.recordset.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Product not found',
      });
    }

    const request = pool.request();
    request.input('id', sql.Int, id);
    request.input('name', sql.NVarChar, name);
    request.input('description', sql.NVarChar, description || null);
    request.input('price', sql.Decimal(18, 2), price);
    request.input('image_url', sql.NVarChar, image_url || null);
    request.input('category_id', sql.Int, category_id);

    await request.query(`
      UPDATE dbo.products
      SET
        name = @name,
        description = @description,
        price = @price,
        image_url = @image_url,
        category_id = @category_id
      WHERE id = @id
    `);

    res.status(200).json({
      success: true,
      message: 'Product updated successfully',
    });
  } catch (error) {
    console.error('Update product error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update product',
    });
  }
};

/**
 * ==========================
 * DELETE /products/:id
 * ==========================
 */
exports.deleteProduct = async (req, res) => {
  try {
    const { id } = req.params;

    if (!id || isNaN(id)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid product ID',
      });
    }

    const pool = await poolPromise;

    const result = await pool
      .request()
      .input('id', sql.Int, id)
      .query('DELETE FROM dbo.products WHERE id = @id');

    if (result.rowsAffected[0] === 0) {
      return res.status(404).json({
        success: false,
        message: 'Product not found',
      });
    }

    res.status(200).json({
      success: true,
      message: 'Product deleted successfully',
    });
  } catch (error) {
    console.error('Delete product error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete product',
    });
  }
};
