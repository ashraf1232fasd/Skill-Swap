const express = require('express');
const router = express.Router();
const { createBooking, updateBookingStatus, getMyBookings } = require('../controllers/bookingController');
const { protect } = require('../middleware/authMiddleware');

router.use(protect);

router.route('/')
  .post(createBooking)  
  .get(getMyBookings);

router.route('/:id').put(updateBookingStatus);

module.exports = router;