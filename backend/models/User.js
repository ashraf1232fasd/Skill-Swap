const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = mongoose.Schema(
  {
    name: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    
    timeBalance: { 
      type: Number, 
      default: 60, // رصيد ترحيبي: ساعة واحدة
      min: 0 
    },
    frozenBalance: { 
      type: Number, 
      default: 0 // رصيد محجوز للخدمات الجارية
    },
    
    skills: [String], 
    bio: String,
    rating: { type: Number, default: 0 },
  },
  {
    timestamps: true,
  }
);

userSchema.pre('save', async function (next) {
  if (!this.isModified('password')) {
    next();
  }
  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
});

userSchema.methods.matchPassword = async function (enteredPassword) {
  return await bcrypt.compare(enteredPassword, this.password);
};

const User = mongoose.model('User', userSchema);

module.exports = User;