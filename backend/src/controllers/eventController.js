const { createClient } = require('@supabase/supabase-js');

function clientWithToken(token) {
  return createClient(process.env.SUPABASE_URL, process.env.SUPABASE_ANON_KEY, {
    global: { headers: { Authorization: `Bearer ${token}` } },
  });
}

function tokenFrom(req) {
  return req.headers.authorization.split(' ')[1];
}

// GET /api/events — list all events
exports.getEvents = async (req, res, next) => {
  try {
    const supabase = clientWithToken(tokenFrom(req));
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

// GET /api/events/:id — single event
exports.getEventById = async (req, res, next) => {
  try {
    const { id } = req.params;
    const supabase = clientWithToken(tokenFrom(req));

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

// POST /api/events — create event
exports.createEvent = async (req, res, next) => {
  try {
    const { user_id, title, category, end_time, capacity } = req.body;

    if (!user_id || !title || !category || !end_time || !capacity) {
      return res.status(400).json({
        message: 'user_id, title, category, end_time, capacity are required.',
      });
    }

    const supabase = clientWithToken(tokenFrom(req));
    const { data, error } = await supabase
      .from('event')
      .insert({ user_id, title, category, end_time, capacity })
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

// GET /api/events/my/:userId — events created by a user
exports.getMyEvents = async (req, res, next) => {
  try {
    const { userId } = req.params;
    const supabase = clientWithToken(tokenFrom(req));

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

// POST /api/events/:id/join — join an event
exports.joinEvent = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { user_id } = req.body;

    if (!user_id) {
      return res.status(400).json({ message: 'user_id is required.' });
    }

    const supabase = clientWithToken(tokenFrom(req));

    const { data: event, error: eventError } = await supabase
      .from('event')
      .select('*')
      .eq('event_id', id)
      .single();

    if (eventError || !event) {
      return res.status(404).json({ message: 'Event not found.' });
    }

    const { data: existing } = await supabase
      .from('event_user_link')
      .select('*')
      .eq('event_id', id)
      .eq('user_id', user_id)
      .maybeSingle();

    if (existing) {
      return res.status(400).json({ message: 'Already joined this event.' });
    }

    const { count, error: countError } = await supabase
      .from('event_user_link')
      .select('*', { count: 'exact', head: true })
      .eq('event_id', id);

    if (countError) {
      return res.status(400).json({ message: countError.message });
    }

    if (count >= event.capacity) {
      return res.status(400).json({ message: 'Event is full.' });
    }

    const { data, error } = await supabase
      .from('event_user_link')
      .insert({ user_id, event_id: Number(id) })
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

// DELETE /api/events/:id/join — leave an event
exports.leaveEvent = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { user_id } = req.body;

    if (!user_id) {
      return res.status(400).json({ message: 'user_id is required.' });
    }

    const supabase = clientWithToken(tokenFrom(req));
    const { error } = await supabase
      .from('event_user_link')
      .delete()
      .eq('event_id', id)
      .eq('user_id', user_id);

    if (error) return res.status(400).json({ message: error.message });

    res.json({ message: 'Left event successfully.' });
  } catch (err) {
    next(err);
  }
};

// GET /api/events/:id/participants — list participants
exports.getEventParticipants = async (req, res, next) => {
  try {
    const { id } = req.params;
    const supabase = clientWithToken(tokenFrom(req));

    const { data, error } = await supabase
      .from('event_user_link')
      .select(
        `
        user_id,
        user (
          user_id,
          name,
          email,
          college
        )
      `,
      )
      .eq('event_id', id);

    if (error) return res.status(400).json({ message: error.message });

    res.json({ participants: data });
  } catch (err) {
    next(err);
  }
};
