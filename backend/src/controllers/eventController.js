const supabase = require('../config/supabase');

// GET /api/events
// 모든 이벤트 조회
exports.getEvents = async (req, res, next) => {
  try {
    const { data, error } = await supabase
      .from('event')
      .select('*')
      .order('upload_time', { ascending: false });

    if (error) return res.status(400).json({ message: error.message });

    res.json({ events: data });
  } catch (err) {
    next(err);
  }
};

// GET /api/events/:id
// 이벤트 상세 조회
exports.getEventById = async (req, res, next) => {
  try {
    const { id } = req.params;

    const { data, error } = await supabase
      .from('event')
      .select('*')
      .eq('event_id', id)
      .single();

    if (error) return res.status(404).json({ message: 'Event not found.' });

    res.json({ event: data });
  } catch (err) {
    next(err);
  }
};

// POST /api/events
// 이벤트 생성
exports.createEvent = async (req, res, next) => {
  try {
    const { user_id, title, category, end_time, capacity } = req.body;

    if (!user_id || !title || !category || !end_time || !capacity) {
      return res.status(400).json({
        message: 'user_id, title, category, end_time, capacity are required.',
      });
    }

    const { data, error } = await supabase
      .from('event')
      .insert({
        user_id,
        title,
        category,
        end_time,
        capacity,
      })
      .select()
      .single();

    if (error) return res.status(400).json({ message: error.message });

    res.status(201).json({
      message: 'Event created successfully.',
      event: data,
    });
  } catch (err) {
    next(err);
  }
};

// GET /api/events/my/:userId
// 특정 유저가 만든 이벤트 조회
exports.getMyEvents = async (req, res, next) => {
  try {
    const { userId } = req.params;

    const { data, error } = await supabase
      .from('event')
      .select('*')
      .eq('user_id', userId)
      .order('upload_time', { ascending: false });

    if (error) return res.status(400).json({ message: error.message });

    res.json({ events: data });
  } catch (err) {
    next(err);
  }
};

// POST /api/events/:id/join
// 이벤트 참가 신청
exports.joinEvent = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { user_id } = req.body;

    if (!user_id) {
      return res.status(400).json({ message: 'user_id is required.' });
    }

    const { data, error } = await supabase
      .from('event_user_link')
      .insert({
        user_id,
        event_id: id,
      })
      .select()
      .single();

    if (error) return res.status(400).json({ message: error.message });

    res.status(201).json({
      message: 'Joined event successfully.',
      data,
    });
  } catch (err) {
    next(err);
  }
};
