const supabase = require('../config/supabase');

module.exports = async (req, res, next) => {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ message: '인증 토큰이 없습니다.' });
  }
  const token = authHeader.split(' ')[1];
  const { data, error } = await supabase.auth.getUser(token);
  if (error || !data.user) {
    return res.status(401).json({ message: '유효하지 않은 토큰입니다.' });
  }
  req.user = data.user;
  next();
};
