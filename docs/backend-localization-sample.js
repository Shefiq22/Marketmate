/**
 * Sample Node.js/Express controller demonstrating Accept-Language
 * driven multi-tenant schema selection.
 *
 * Assumes a MongoDB collection where each document stores translated
 * fields per locale, e.g.:
 *
 * {
 *   sku: "FRUIT-001",
 *   name_en: "Fresh Apples",
 *   name_ha: "Tuffa Sabbi",
 *   name_ig: "Apụl Ọhụrụ",
 *   name_yo: "Èso Àpù Tuntun",
 *   description_en: "Crisp red apples from Jos plateau",
 *   description_ha: "Tuffa jajayen nan daga Plateau Jos",
 *   category: "fruits",
 *   price: 4500
 * }
 */

const express = require('express');
const router = express.Router();

/**
 * Maps an Accept-Language header value to the corresponding
 * database field suffix used by the schema.
 *
 * @param {string} acceptLanguage - The Accept-Language header value
 * @returns {string} - Database field suffix (e.g., "en", "ha")
 */
function resolveLocale(acceptLanguage) {
  const supported = ['en', 'ha', 'ig', 'yo', 'pcm'];
  const primary = acceptLanguage?.split(',')[0]?.trim().split('-')[0];
  return supported.includes(primary) ? primary : 'en';
}

/**
 * GET /api/v1/products
 *
 * Returns products with names and descriptions localized
 * according to the Accept-Language header.
 */
router.get('/', async (req, res) => {
  try {
    const locale = resolveLocale(req.headers['accept-language']);
    const { category, page = 1, limit = 20 } = req.query;

    const filter = {};
    if (category) filter.category = category;

    const products = await Product.find(filter)
      .skip((page - 1) * limit)
      .limit(Number(limit))
      .lean();

    // Select localized fields dynamically based on locale
    const localized = products.map((p) => ({
      _id: p._id,
      name: p[`name_${locale}`] || p.name_en,
      description: p[`description_${locale}`] || p.description_en,
      category: p.category,
      price: p.price,
      images: p.images,
      sellerId: p.sellerId,
      averageRating: p.averageRating,
      isAvailable: p.isAvailable,
    }));

    res.json({
      success: true,
      data: localized,
      meta: { page, limit, locale },
    });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

/**
 * GET /api/v1/orders/:id
 *
 * Returns a single order with status and timeline labels
 * translated to the requested locale.
 */
router.get('/:id', async (req, res) => {
  try {
    const locale = resolveLocale(req.headers['accept-language']);
    const order = await Order.findById(req.params.id)
      .populate('items.productId')
      .lean();

    if (!order) {
      return res
        .status(404)
        .json({ success: false, message: 'Order not found' });
    }

    // Translate order status
    const statusTranslations = {
      pending: { en: 'Pending', ha: 'Ana jira', ig: 'Na-echere', yo: 'Òṣísẹ́ǹkù', pcm: 'Pending' },
      order_accepted: { en: 'Accepted', ha: 'An karɓa', ig: 'Anabatara', yo: 'Ti gbà', pcm: 'Accepted' },
      preparing_order: { en: 'Preparing', ha: 'Ana shirya', ig: 'Na-akwado', yo: 'Ń mura', pcm: 'Preparing' },
      ready_for_pickup: { en: 'Ready for Pickup', ha: 'Shirye don ɗauka', ig: 'Dị njikere iburu', yo: 'Ń ṣetán fún gbígba', pcm: 'Ready for Pickup' },
      in_transit: { en: 'In Transit', ha: 'Ana kan hanya', ig: "N'ụzọ", yo: 'Ń lọ', pcm: 'In Transit' },
      completed: { en: 'Completed', ha: 'An kammala', ig: 'Emechara', yo: 'Ti parí', pcm: 'Don finish' },
      cancelled: { en: 'Cancelled', ha: 'An soke', ig: 'Akagbuola', yo: 'Ti fagilé', pcm: 'Cancelled' },
    };

    const statusLabel =
      statusTranslations[order.status]?.[locale] || order.status;

    // Translate timeline steps if present
    const timeline = (order.timeline || []).map((step) => ({
      ...step,
      localizedLabel:
        statusTranslations[step.status]?.[locale] || step.label,
    }));

    res.json({
      success: true,
      data: {
        ...order,
        statusLabel,
        timeline,
      },
    });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

/**
 * POST /api/v1/products  (seller creates product)
 *
 * Accepts a product payload; stores translated names/descriptions
 * under locale-specific fields so the same product serves all locales.
 */
router.post('/', async (req, res) => {
  try {
    const { name, description, category, price, images, deliveryClass } =
      req.body;

    const product = new Product({
      name_en: name?.en || name,
      name_ha: name?.ha,
      name_ig: name?.ig,
      name_yo: name?.yo,
      name_pcm: name?.pcm || name?.en,
      description_en: description?.en || description,
      description_ha: description?.ha,
      description_ig: description?.ig,
      description_yo: description?.yo,
      description_pcm: description?.pcm || description?.en,
      category,
      price,
      images,
      deliveryClass,
      sellerId: req.user.id,
    });

    await product.save();
    res.status(201).json({ success: true, data: product });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

module.exports = router;
