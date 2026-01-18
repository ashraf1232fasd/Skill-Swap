const express = require('express');
const router = express.Router();
const { 
  getServices, 
  createService, 
  deleteService 
} = require('../controllers/serviceController');

const { protect } = require('../middleware/authMiddleware');


router.get('/', getServices);
router.post('/', protect, createService); 
router.delete('/:id', protect, deleteService);

module.exports = router;