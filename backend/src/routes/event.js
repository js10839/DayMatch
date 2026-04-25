const express = require('express');
const router = express.Router();

const eventController = require('../controllers/eventController');

router.get('/', eventController.getEvents);
router.post('/', eventController.createEvent);

router.get('/my/:userId', eventController.getMyEvents);

router.get('/:id/participants', eventController.getEventParticipants);
router.post('/:id/join', eventController.joinEvent);
router.delete('/:id/join', eventController.leaveEvent);

router.get('/:id', eventController.getEventById);

module.exports = router;
