const router = require('express').Router();
const { register, login, logout, refresh, getMe, forgotPassword } = require('../controllers/authController');
const protect = require('../middlewares/auth');
const { requireFields } = require('../middlewares/validate');

router.post('/register', requireFields(['email', 'password', 'name', 'gender']), register);
router.post('/login', requireFields(['email', 'password']), login);
router.post('/logout', protect, logout);
router.post('/refresh', requireFields(['refresh_token']), refresh);
router.get('/me', protect, getMe);
router.post('/forgot-password', requireFields(['email']), forgotPassword);

module.exports = router;
