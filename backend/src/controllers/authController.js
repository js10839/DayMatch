const supabase = require('../config/supabase');
const { isValidEmail } = require('../middlewares/validate');

exports.register = async (req, res, next) => {
  try {
    const { email, password, name, gender, pronouns, college, ethnicity, age, birth_data } = req.body;

    if (!isValidEmail(email)) {
      return res.status(400).json({ message: 'Invalid email format.' });
    }
    if (password.length < 8) {
      return res.status(400).json({ message: 'Password must be at least 8 characters.' });
    }

    const { data, error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: { name, gender, pronouns, college, ethnicity, age, birth_data },
      },
    });
    if (error) return res.status(400).json({ message: error.message });

    if (!data.session) {
      return res.status(201).json({ message: 'Registration successful. Please confirm your email.' });
    }

    res.status(201).json({
      token: data.session.access_token,
      refreshToken: data.session.refresh_token,
      user: { email, name, gender },
    });
  } catch (err) {
    next(err);
  }
};

exports.login = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    const { data, error } = await supabase.auth.signInWithPassword({ email, password });
    if (error) return res.status(401).json({ message: 'Invalid email or password.' });

    const { data: userData, error: dbError } = await supabase
      .from('user')
      .select('*')
      .eq('email', email)
      .single();

    if (dbError) return res.status(404).json({ message: 'User not found.' });

    res.json({
      token: data.session.access_token,
      refreshToken: data.session.refresh_token,
      user: userData,
    });
  } catch (err) {
    next(err);
  }
};

exports.logout = async (req, res, next) => {
  try {
    const token = req.headers.authorization.split(' ')[1];

    const response = await fetch(`${process.env.SUPABASE_URL}/auth/v1/logout?scope=global`, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${token}`,
        apikey: process.env.SUPABASE_ANON_KEY,
      },
    });

    if (!response.ok) {
      const data = await response.json().catch(() => ({}));
      return res.status(400).json({ message: data.msg || 'Logout failed.' });
    }

    res.json({ message: 'Logged out successfully.' });
  } catch (err) {
    next(err);
  }
};

exports.refresh = async (req, res, next) => {
  try {
    const { refresh_token } = req.body;

    const { data, error } = await supabase.auth.refreshSession({ refresh_token });
    if (error) return res.status(401).json({ message: 'Invalid or expired refresh token.' });

    res.json({
      token: data.session.access_token,
      refreshToken: data.session.refresh_token,
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

    if (error) return res.status(404).json({ message: 'User not found.' });

    res.json({ user: userData });
  } catch (err) {
    next(err);
  }
};

exports.forgotPassword = async (req, res, next) => {
  try {
    const { email } = req.body;

    if (!isValidEmail(email)) {
      return res.status(400).json({ message: 'Invalid email format.' });
    }

    const { error } = await supabase.auth.resetPasswordForEmail(email);
    if (error) return res.status(400).json({ message: error.message });

    res.json({ message: 'Password reset email sent.' });
  } catch (err) {
    next(err);
  }
};
