const express = require('express');
const dotenv = require('dotenv');
const cors = require('cors');
const connectDB = require('./config/db');
const { errorHandler } = require('./middleware/errorMiddleware');

// 1. استيراد المكتبات الجديدة للسوكت
const http = require('http'); 
const { Server } = require("socket.io"); 

const authRoutes = require('./routes/authRoutes');
const serviceRoutes = require('./routes/serviceRoutes');
const bookingRoutes = require('./routes/bookingRoutes');
const chatRoutes = require('./routes/chatRoutes'); // ضروري لجلب المحادثات

dotenv.config();
connectDB();

const app = express();

app.use(cors());
app.use(express.json());

// 2. توجيه الروابط
app.use('/api/users', authRoutes);       
app.use('/api/services', serviceRoutes); 
app.use('/api/bookings', bookingRoutes); 
app.use('/api/chat', chatRoutes); // رابط الشات

app.get('/', (req, res) => {
  res.send('API is running...');
});

app.use(errorHandler);

// ---------------------------------------------------------
// 3. إعداد السيرفر والسوكت (Socket.io Setup)
// ---------------------------------------------------------

// تحويل Express App إلى HTTP Server
const server = http.createServer(app);

// إعداد Socket.io
const io = new Server(server, {
  pingTimeout: 60000, // يغلق الاتصال إذا لم يستجب المستخدم خلال 60 ثانية
  cors: {
    origin: "*", // يسمح بالاتصال من أي مكان (تطبيق الموبايل)
  },
});

// منطق السوكت
io.on("connection", (socket) => {
  console.log("Connected to socket.io");

  // إعداد الغرفة الخاصة بالمستخدم
  socket.on("setup", (userData) => {
    // userData هو الـ ID الخاص بالمستخدم الذي أرسلناه من Flutter
    socket.join(userData); 
    console.log("User Connected: " + userData);
    socket.emit("connected");
  });

  // الانضمام لغرفة محادثة معينة
  socket.on("join chat", (room) => {
    socket.join(room);
    console.log("User Joined Room: " + room);
  });

  // إرسال رسالة جديدة
  socket.on("new message", (newMessageRecieved) => {
    var chat = newMessageRecieved.chat;

    if (!chat.users) return console.log("chat.users not defined");

    // إرسال الرسالة لكل الموجودين في الشات ما عدا المرسل
    chat.users.forEach((user) => {
      if (user._id == newMessageRecieved.sender._id) return; // لا ترسل لي رسالتي
      
      // إرسال للطرف الآخر باستخدام الـ ID الخاص به كاسم للغرفة
      socket.in(user._id).emit("message received", newMessageRecieved);
    });
  });

  socket.on('disconnect', () => {
    console.log("USER DISCONNECTED");
  });
});

const PORT = process.env.PORT || 5000;

// ملاحظة: غيرنا app.listen إلى server.listen
server.listen(PORT, () => console.log(`Server running on port ${PORT}`));