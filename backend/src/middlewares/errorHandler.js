module.exports = (err, req, res, next) => {
  console.error(err);
  res.status(err.status || 500).json({ message: err.message || '서버 오류가 발생했습니다.' });
};
