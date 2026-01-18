


//هاذ الي شغال صح 


const express = require('express');
const dotenv = require('dotenv');
const cors = require('cors');
const connectDB = require('./config/db');
const { errorHandler } = require('./middleware/errorMiddleware');

// 1. استيراد الملفات (تأكد أن المسارات صحيحة)
const authRoutes = require('./routes/authRoutes');
const serviceRoutes = require('./routes/serviceRoutes');

// >>>>> انتبه هنا: تأكد أننا نستورد من bookingRoutes وليس authRoutes <<<<<
const bookingRoutes = require('./routes/bookingRoutes'); 

dotenv.config();
connectDB();

const app = express();

app.use(cors());
app.use(express.json());

// 2. توجيه الروابط
app.use('/api/users', authRoutes);       
app.use('/api/services', serviceRoutes); 

// >>>>> ربط الحجوزات بالملف الصحيح <<<<<
app.use('/api/bookings', bookingRoutes); 

app.get('/', (req, res) => {
  res.send('API is running...');
});

app.use(errorHandler);

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));