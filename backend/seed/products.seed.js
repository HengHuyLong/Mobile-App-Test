require('dotenv').config();
const { sql, poolPromise } = require('../src/config/db');

// ============================
// GET CATEGORY ID BY NAME
// ============================
async function getCategoryId(pool, name) {
  const result = await pool
    .request()
    .input('name', sql.NVarChar, name)
    .query('SELECT id FROM categories WHERE name = @name');

  if (!result.recordset.length) {
    throw new Error(`Category not found: ${name}`);
  }

  return result.recordset[0].id;
}

// ============================
// SEED PRODUCTS
// ============================
async function seedProducts() {
  try {
    const pool = await poolPromise;

    const mangaId = await getCategoryId(pool, 'Manga');
    const novelId = await getCategoryId(pool, 'Novel');
    const comicId = await getCategoryId(pool, 'Comic');

    const products = [
      // 🟥 MANGA
      { name: 'One Piece Vol. 1', desc: 'Japanese manga', price: 8.5, cat: mangaId, img: 'product1.png' },
      { name: 'Naruto Vol. 1', desc: 'Popular ninja manga', price: 7.99, cat: mangaId, img: 'product2.png' },
      { name: 'Attack on Titan', desc: 'Dark fantasy manga', price: 10.99, cat: mangaId, img: 'product3.png' },
      { name: 'Demon Slayer', desc: 'Action manga', price: 9.99, cat: mangaId, img: 'product4.png' },
      { name: 'ក្មេងប្រយុទ្ធ', desc: 'ម៉ង់ហ្គាខ្មែរ', price: 6.99, cat: mangaId, img: 'product5.png' },

      // 🟩 NOVEL
      { name: 'Harry Potter', desc: 'Fantasy novel', price: 12.0, cat: novelId, img: 'product6.png' },
      { name: 'The Great Gatsby', desc: 'Classic novel', price: 10.5, cat: novelId, img: 'product7.png' },
      { name: '1984', desc: 'Dystopian novel', price: 11.99, cat: novelId, img: 'product8.png' },
      { name: 'The Alchemist', desc: 'Inspirational novel', price: 9.5, cat: novelId, img: 'product9.png' },
      { name: 'ផ្លូវជីវិត', desc: 'ប្រលោមលោកខ្មែរ', price: 8.99, cat: novelId, img: 'product10.png' },
      { name: 'បេះដូងអ្នកសរសេរ', desc: 'ប្រលោមលោកខ្មែរ', price: 7.99, cat: novelId, img: 'product11.png' },

      // 🟦 COMIC
      { name: 'Spider-Man: Homecoming', desc: 'Marvel comic', price: 6.5, cat: comicId, img: 'product12.png' },
      { name: 'Batman: Killing Joke', desc: 'DC comic', price: 9.0, cat: comicId, img: 'product13.png' },
      { name: 'Avengers Assemble', desc: 'Superhero comic', price: 8.75, cat: comicId, img: 'product14.png' },
      { name: 'Iron Man', desc: 'Marvel comic', price: 7.5, cat: comicId, img: 'product15.png' },
      { name: 'វីរបុរសដ៏អស្ចារ្យ', desc: 'កំប្លែងខ្មែរ', price: 6.25, cat: comicId, img: 'product16.png' },
      { name: 'Justice League', desc: 'DC superhero comic', price: 9.25, cat: comicId, img: 'product17.png' },
      { name: 'X-Men', desc: 'Mutant comic', price: 8.99, cat: comicId, img: 'product18.png' },
      { name: 'Thor', desc: 'Marvel comic', price: 7.99, cat: comicId, img: 'product19.png' },
      { name: 'Captain America', desc: 'Marvel comic', price: 8.49, cat: comicId, img: 'product20.png' },
    ];

    for (const p of products) {
      await pool.request()
        .input('name', sql.NVarChar, p.name)
        .input('description', sql.NVarChar, p.desc)
        .input('price', sql.Decimal(10, 2), p.price)
        .input('category_id', sql.Int, p.cat)
        .input('image_url', sql.NVarChar, `upload/images/${p.img}`)
        .query(`
          INSERT INTO products (name, description, price, category_id, image_url)
          VALUES (@name, @description, @price, @category_id, @image_url)
        `);
    }

    console.log('✅ 20 book products seeded successfully');
    process.exit(0);

  } catch (err) {
    console.error('❌ Seeding failed:', err.message);
    process.exit(1);
  }
}

seedProducts();
