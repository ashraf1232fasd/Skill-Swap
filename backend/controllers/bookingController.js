const asyncHandler = require('express-async-handler');
const Booking = require('../models/Booking');
const User = require('../models/User');
const Service = require('../models/Service');

const createBooking = asyncHandler(async (req, res) => {
  const { serviceId, note } = req.body;
  console.log(`📥 طلب حجز جديد للخدمة: ${serviceId}`);

  const service = await Service.findById(serviceId);
  if (!service) {
    res.status(404);
    throw new Error('الخدمة غير موجودة');
  }

  const bookingDate = new Date(service.datetime);
  const duration = Number(service.price);
  
  let studentId, providerId, initialStatus;

  if (service.type === 'offer') {
    studentId = req.user._id;      
    providerId = service.provider; 
    initialStatus = 'pending';
  } else {
    studentId = service.provider; 
    providerId = req.user._id;     
    initialStatus = 'accepted'; 
  }

  if (studentId.toString() === providerId.toString()) {
    res.status(400);
    throw new Error('لا يمكنك الحجز لنفسك');
  }

  const student = await User.findById(studentId);
  if (student.timeBalance < duration) {
    res.status(400);
    throw new Error(`رصيد الطالب (${student.name}) غير كافٍ`);
  }

  student.timeBalance -= duration;
  student.frozenBalance += duration;
  await student.save();

  const booking = await Booking.create({
    student: studentId,
    provider: providerId,
    service: serviceId,
    date: bookingDate,
    duration: duration,
    totalCost: duration,
    note: note || '',
    status: initialStatus,
  });

  console.log("✅ تم إنشاء الحجز بنجاح!");
  res.status(201).json(booking);
});

const updateBookingStatus = asyncHandler(async (req, res) => {
  const { status } = req.body;
  const booking = await Booking.findById(req.params.id);

  if (!booking) {
    res.status(404);
    throw new Error('الحجز غير موجود');
  }

  if (status === 'completed') {
    if (booking.status === 'completed') return res.status(400).json({message: 'مكتمل مسبقاً'});

    const student = await User.findById(booking.student);
    const provider = await User.findById(booking.provider);

    // تحويل الرصيد من المجمد إلى المعلم
    student.frozenBalance -= booking.totalCost;
    await student.save();

    provider.timeBalance += booking.totalCost;
    await provider.save();

    await Service.findByIdAndDelete(booking.service);
    console.log(`🗑️ تم حذف الخدمة المرتبطة بالحجز: ${booking.service}`);

    booking.status = 'completed';
    await booking.save();
    res.json({ message: 'تم إكمال الجلسة وحذف المنشور بنجاح', booking });

  } else if (status === 'cancelled') {
    if (booking.status === 'cancelled') return res.status(400).json({message: 'ملغي مسبقاً'});

    const student = await User.findById(booking.student);
    
    student.frozenBalance -= booking.totalCost;
    student.timeBalance += booking.totalCost;
    await student.save();

    booking.status = 'cancelled';
    await booking.save();
    res.json({ message: 'تم إلغاء الحجز واسترجاع الرصيد', booking });

  } else {
    booking.status = status;
    await booking.save();
    res.json(booking);
  }
});

const getMyBookings = asyncHandler(async (req, res) => {
  const bookings = await Booking.find({
    $or: [{ student: req.user._id }, { provider: req.user._id }],
  })
    .populate('student', 'name email')
    .populate('provider', 'name email')
    .populate('service', 'title category')
    .sort({ createdAt: -1 });

  res.json(bookings);
});

module.exports = { createBooking, updateBookingStatus, getMyBookings };