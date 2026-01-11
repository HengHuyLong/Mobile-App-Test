const { sql, poolPromise } = require('../config/db');

/**
 * GET /categories
 */
exports.getCategories = async (req, res) => {
  try {
    const search = (req.query.search || '').trim();

    const pool = await poolPromise;
    const request = pool.request();

    let query = `
      SELECT
          id,
          name,
          description,
          created_at
      FROM Categories
    `;

    if (search !== '') {
      query += `
        WHERE name COLLATE Khmer_100_CI_AI LIKE N'%' + @search + N'%'
      `;
      request.input('search', sql.NVarChar, search);
    }

    query += ` ORDER BY created_at DESC;`;

    const result = await request.query(query);

    res.status(200).json({
      success: true,
      data: result.recordset
    });

  } catch (error) {
    console.error('Get categories error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch categories'
    });
  }
};


/**
 * POST /categories
 * Prevent duplicate names
 */
exports.createCategory = async (req, res) => {
  try {
    const { name, description } = req.body;

    if (!name || name.trim() === '') {
      return res.status(400).json({
        success: false,
        message: 'Category name is required'
      });
    }

    const pool = await poolPromise;

    // 🔎 Check duplicate
    const checkRequest = pool.request();
    checkRequest.input('name', sql.NVarChar, name.trim());

    const duplicate = await checkRequest.query(`
      SELECT id FROM Categories
      WHERE name COLLATE Khmer_100_CI_AI = @name
    `);

    if (duplicate.recordset.length > 0) {
      return res.status(409).json({
        success: false,
        message: 'Category name already exists'
      });
    }

    // ➕ Insert
    const insertRequest = pool.request();
    insertRequest.input('name', sql.NVarChar, name.trim());
    insertRequest.input('description', sql.NVarChar, description || null);

    await insertRequest.query(`
      INSERT INTO Categories (name, description)
      VALUES (@name, @description);
    `);

    res.status(201).json({
      success: true,
      message: 'Category created successfully'
    });

  } catch (error) {
    console.error('Create category error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create category'
    });
  }
};

/**
 * PUT /categories/:id
 * Prevent duplicate names
 */
exports.updateCategory = async (req, res) => {
  try {
    const { id } = req.params;
    const { name, description } = req.body;

    if (!id || isNaN(id)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid category ID'
      });
    }

    if (!name || name.trim() === '') {
      return res.status(400).json({
        success: false,
        message: 'Category name is required'
      });
    }

    const pool = await poolPromise;

    // 🔎 Check existence
    const existsRequest = pool.request();
    existsRequest.input('id', sql.Int, id);

    const exists = await existsRequest.query(`
      SELECT id FROM Categories WHERE id = @id
    `);

    if (exists.recordset.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Category not found'
      });
    }

    // 🔎 Check duplicate (exclude current ID)
    const dupRequest = pool.request();
    dupRequest.input('id', sql.Int, id);
    dupRequest.input('name', sql.NVarChar, name.trim());

    const duplicate = await dupRequest.query(`
      SELECT id FROM Categories
      WHERE id != @id
      AND name COLLATE Khmer_100_CI_AI = @name
    `);

    if (duplicate.recordset.length > 0) {
      return res.status(409).json({
        success: false,
        message: 'Category name already exists'
      });
    }

    // ✏️ Update
    const updateRequest = pool.request();
    updateRequest.input('id', sql.Int, id);
    updateRequest.input('name', sql.NVarChar, name.trim());
    updateRequest.input('description', sql.NVarChar, description || null);

    await updateRequest.query(`
      UPDATE Categories
      SET name = @name,
          description = @description
      WHERE id = @id
    `);

    res.status(200).json({
      success: true,
      message: 'Category updated successfully'
    });

  } catch (error) {
    console.error('Update category error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update category'
    });
  }
};

/**
 * DELETE /categories/:id
 */
exports.deleteCategory = async (req, res) => {
  try {
    const { id } = req.params;

    if (!id || isNaN(id)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid category ID'
      });
    }

    const pool = await poolPromise;

    // 🔎 Check existence
    const checkRequest = pool.request();
    checkRequest.input('id', sql.Int, id);

    const exists = await checkRequest.query(`
      SELECT id FROM Categories WHERE id = @id
    `);

    if (exists.recordset.length === 0) {
      return res.status(404).json({
        success: false,
        message: 'Category not found'
      });
    }

    // ❌ Delete
    const deleteRequest = pool.request();
    deleteRequest.input('id', sql.Int, id);

    await deleteRequest.query(`
      DELETE FROM Categories WHERE id = @id
    `);

    res.status(200).json({
      success: true,
      message: 'Category deleted successfully'
    });

  } catch (error) {
    console.error('Delete category error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete category'
    });
  }
};
