const asyncHandler = require('express-async-handler');
const Service = require('../models/Service');
const User = require('../models/User'); 

const getServices = asyncHandler(async (req, res) => {
  const services = await Service.find()
    .populate('provider', 'name email _id')
    .sort({ createdAt: -1 });
  res.status(200).json(services);
});

const createService = asyncHandler(async (req, res) => {
  const { title, description, category, price, type, datetime, countryCode, phone } = req.body;

  if (!title || !description || !category || !datetime || !phone) {
    res.status(400);
    throw new Error('الرجاء إدخال جميع البيانات');
  }

  if (type === 'request') {
     const user = await User.findById(req.user._id);
     const servicePrice = Number(price) || 0;
     
     if (user.timeBalance < servicePrice) {
       res.status(400);
       throw new Error(`رصيدك الحالي (${user.timeBalance}) لا يكفي لنشر طلب بقيمة ${servicePrice} دقيقة. يرجى الشحن أولاً.`);
     }
  }

  const service = await Service.create({
    provider: req.user._id,
    title,
    description,
    category,
    price: price || 60,
    type: type || 'offer',
    datetime: datetime,
    countryCode: countryCode || '+962',
    phone: phone,
  });

  const populatedService = await Service.findById(service._id)
      .populate('provider', 'name email');

  res.status(201).json(populatedService);
});

const deleteService = asyncHandler(async (req, res) => {
  const service = await Service.findById(req.params.id);
  if (!service) {
    res.status(404); throw new Error('الخدمة غير موجودة');
  }
  if (service.provider.toString() !== req.user.id) {
    res.status(401); throw new Error('غير مصرح لك');
  }
  await service.deleteOne();
  res.status(200).json({ id: req.params.id });
});

module.exports = { getServices, createService, deleteService };