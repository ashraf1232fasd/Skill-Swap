const mongoose = require('mongoose');

const serviceSchema = mongoose.Schema({
  provider: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
    ref: 'User',
  },
  title: {
    type: String,
    required: true,
  },
  description: {
    type: String,
    required: true,
  },
  category: {
    type: String,
    required: true,
  },
  price: {
    type: Number,
    required: true,
    default: 60, 
  },
  type: {
    type: String,
    enum: ['offer', 'request'],
    default: 'offer',
  },
  datetime: {
    type: Date,
    required: true,
  },
  countryCode: {
    type: String,
    required: true, 
    default: '+962' // قيمة افتراضية (الأردن)
  },
  phone: {
    type: String,
    required: true,
  }
}, {
  timestamps: true,
});

module.exports = mongoose.model('Service', serviceSchema);