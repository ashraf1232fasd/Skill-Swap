const mongoose = require('mongoose');

const bookingSchema = mongoose.Schema(
  {
    student: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    provider: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    service: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Service',
      required: true,
    },
    date: {
      type: Date,
      required: true, // تاريخ ووقت الحجز
    },
    duration: {
      type: Number,
      required: true, // المدة بالدقائق (مثلاً 60)
    },
    totalCost: {
      type: Number,
      required: true, // التكلفة المخصومة بالدقائق
    },
    status: {
      type: String,
      enum: ['pending', 'accepted', 'completed', 'cancelled'],
      default: 'pending', // الحالة الافتراضية
    },
    note: {
      type: String, // ملاحظة من الطالب عند الحجز
    },
  },
  {
    timestamps: true,
  }
);

module.exports = mongoose.model('Booking', bookingSchema);