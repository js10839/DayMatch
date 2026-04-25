const router = require('express').Router();
const { signInWithGoogle, completeProfile, logout, refresh, getMe } = require('../controllers/authController');
const protect = require('../middlewares/auth');
const { requireFields } = require('../middlewares/validate');

router.post('/google', requireFields(['id_token']), signInWithGoogle);
router.post('/profile', protect, requireFields(['gender']), completeProfile);
router.post('/logout', protect, logout);
router.post('/refresh', requireFields(['refresh_token']), refresh);
router.get('/me', protect, getMe);

module.exports = router;
