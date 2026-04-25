const express = require('express');
const router = express.Router();

const eventController = require('../controllers/eventController');

router.get('/', eventController.getEvents);
router.get('/:id', eventController.getEventById);
router.post('/', eventController.createEvent);
router.get('/my/:userId', eventController.getMyEvents);
router.post('/:id/join', eventController.joinEvent);

module.exports = router;
