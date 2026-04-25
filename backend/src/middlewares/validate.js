function requireFields(fields) {
  return (req, res, next) => {
    const missing = fields.filter(f => req.body[f] === undefined || req.body[f] === '');
    if (missing.length) {
      return res.status(400).json({ message: `Missing required fields: ${missing.join(', ')}` });
    }
    next();
  };
}

function isValidEmail(email) {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

module.exports = { requireFields, isValidEmail };
