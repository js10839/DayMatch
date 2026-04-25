const router = require('express').Router();
const authRoutes = require('./auth');

router.get('/health', (req, res) => res.json({ status: 'ok' }));

router.use('/auth', authRoutes);
router.use('/events', require('./event'));

module.exports = router;
