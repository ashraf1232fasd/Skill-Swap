const validateEmail = (email) => {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
};

const validatePassword = (password) => {
  return password && password.length >= 6;
};

const validatePhone = (phone) => {
  const phoneRegex = /^[0-9]{10,}$/;
  return phoneRegex.test(phone);
};

const validateName = (name) => {
  return name && name.length >= 2;
};

module.exports = {
  validateEmail,
  validatePassword,
  validatePhone,
  validateName,
};
