const { createClient } = require('@supabase/supabase-js');

const NYU_DOMAIN = '@nyu.edu';

// Stateless per-request clients avoid the cross-request session bleed that
// would happen if controllers called signInWithIdToken / refreshSession on a
// shared singleton (those calls mutate the client's auth state).
function freshClient() {
  return createClient(process.env.SUPABASE_URL, process.env.SUPABASE_ANON_KEY);
}

function clientWithToken(token) {
  return createClient(process.env.SUPABASE_URL, process.env.SUPABASE_ANON_KEY, {
    global: { headers: { Authorization: `Bearer ${token}` } },
  });
}

exports.signInWithGoogle = async (req, res, next) => {
  try {
    const { id_token } = req.body;

    const authClient = freshClient();
    const { data, error } = await authClient.auth.signInWithIdToken({
      provider: 'google',
      token: id_token,
    });
    if (error) return res.status(401).json({ message: error.message });

    const email = data.user?.email || '';
    if (!email.toLowerCase().endsWith(NYU_DOMAIN)) {
      await fetch(`${process.env.SUPABASE_URL}/auth/v1/logout?scope=global`, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${data.session.access_token}`,
          apikey: process.env.SUPABASE_ANON_KEY,
        },
      });
      return res.status(403).json({ message: 'Only NYU emails (@nyu.edu) are allowed.' });
    }

    const userClient = clientWithToken(data.session.access_token);
    const { data: userData } = await userClient
      .from('user')
      .select('*')
      .eq('email', email)
      .single();

    res.json({
      token: data.session.access_token,
      refreshToken: data.session.refresh_token,
      user: userData,
      hasProfile: !!userData?.gender,
    });
  } catch (err) {
    next(err);
  }
};

exports.completeProfile = async (req, res, next) => {
  try {
    const { name, gender, pronouns, college, ethnicity, age, birth_data } = req.body;
    const token = req.headers.authorization.split(' ')[1];
    const userClient = clientWithToken(token);

    const updatePayload = { gender };
    if (name !== undefined) updatePayload.name = name;
    if (pronouns !== undefined) updatePayload.pronouns = pronouns;
    if (college !== undefined) updatePayload.college = college;
    if (ethnicity !== undefined) updatePayload.ethnicity = ethnicity;
    if (age !== undefined) updatePayload.age = age;
    if (birth_data !== undefined) updatePayload.birth_data = birth_data;

    const { data: userData, error } = await userClient
      .from('user')
      .update(updatePayload)
      .eq('email', req.user.email)
      .select()
      .single();

    if (error) return res.status(400).json({ message: error.message });

    res.json({ user: userData });
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

    const authClient = freshClient();
    const { data, error } = await authClient.auth.refreshSession({ refresh_token });
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
    const token = req.headers.authorization.split(' ')[1];
    const userClient = clientWithToken(token);

    const { data: userData, error } = await userClient
      .from('user')
      .select('*')
      .eq('email', req.user.email)
      .single();

    if (error) return res.status(404).json({ message: 'User not found.' });

    res.json({ user: userData, hasProfile: !!userData.gender });
  } catch (err) {
    next(err);
  }
};
