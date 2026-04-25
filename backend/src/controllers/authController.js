const supabase = require('../config/supabase');

exports.register = async (req, res, next) => {
  try {
    const { name, email, password } = req.body;

    const { data, error } = await supabase.auth.signUp({ email, password });
    if (error) return res.status(400).json({ message: error.message });

    const { data: userData, error: dbError } = await supabase
      .from('user')
      .insert({ email, name })
      .select()
      .single();

    if (dbError) return res.status(400).json({ message: dbError.message });

    res.status(201).json({
      token: data.session?.access_token,
      user: { id: userData.user_id, name: userData.name, email: userData.email },
    });
  } catch (err) {
    next(err);
  }
};

exports.login = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    const { data, error } = await supabase.auth.signInWithPassword({ email, password });
    if (error) return res.status(401).json({ message: '이메일 또는 비밀번호가 올바르지 않습니다.' });

    const { data: userData } = await supabase
      .from('user')
      .select('*')
      .eq('email', email)
      .single();

    res.json({
      token: data.session.access_token,
      user: { id: userData.user_id, name: userData.name, email: userData.email },
    });
  } catch (err) {
    next(err);
  }
};

exports.getMe = async (req, res, next) => {
  try {
    const { data: userData, error } = await supabase
      .from('user')
      .select('*')
      .eq('email', req.user.email)
      .single();

    if (error) return res.status(404).json({ message: '사용자를 찾을 수 없습니다.' });

    res.json({ user: userData });
  } catch (err) {
    next(err);
  }
};
