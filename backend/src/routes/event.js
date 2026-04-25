const express = require('express');
const router = express.Router();

const eventController = require('../controllers/eventController');
const protect = require('../middlewares/auth');

router.use(protect);

router.get('/', eventController.getEvents);
router.post('/', eventController.createEvent);

router.get('/my/:userId', eventController.getMyEvents);
router.get('/joined/:userId', eventController.getJoinedEvents);

router.get('/:id/participants', eventController.getEventParticipants);
router.post('/:id/join', eventController.joinEvent);
router.delete('/:id/join', eventController.leaveEvent);

router.get('/:id', eventController.getEventById);
router.delete('/:id', eventController.deleteEvent);

module.exports = router;
