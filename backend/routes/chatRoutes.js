const express = require('express');
const { protect } = require('../middleware/authMiddleware');
const { accessChat, fetchChats, sendMessage, allMessages } = require('../controllers/chatController');

const router = express.Router();

router.route('/').post(protect, accessChat); // فتح شات
router.route('/').get(protect, fetchChats);  // جلب القائمة
router.route('/message').post(protect, sendMessage); // إرسال
router.route('/message/:chatId').get(protect, allMessages); // جلب الرسائل

module.exports = router;