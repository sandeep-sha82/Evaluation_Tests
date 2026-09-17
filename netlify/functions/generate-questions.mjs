const json = (statusCode, body) => ({ statusCode, headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) });

export default async (request) => {
  if (request.httpMethod !== 'POST') return json(405, { error: 'Method not allowed' });
  try {
    const token = request.headers.authorization?.replace('Bearer ', '');
    if (!token) return json(401, { error: 'Sign in as an admin to generate questions.' });
    const auth = await fetch(`${process.env.SUPABASE_URL}/auth/v1/user`, { headers: { apikey: process.env.SUPABASE_ANON_KEY, Authorization: `Bearer ${token}` } });
    const user = await auth.json();
    if (!auth.ok || user.app_metadata?.role !== 'admin') return json(403, { error: 'Admin access required.' });
    const { topic, count } = JSON.parse(request.body || '{}');
    const quantity = Math.min(Math.max(Number(count) || 10, 1), 50);
    if (!String(topic || '').trim()) return json(400, { error: 'A topic is required.' });
    const prompt = `Create ${quantity} accurate multiple-choice assessment questions about: ${topic}. Return ONLY JSON: {"questions":[{"prompt":"...","options":["...","...","...","..."],"answer":0}]}. Each question must have exactly four plausible options; answer is the zero-based correct option index.`;
    const ai = await fetch('https://api.openai.com/v1/chat/completions', { method: 'POST', headers: { Authorization: `Bearer ${process.env.OPENAI_API_KEY}`, 'Content-Type': 'application/json' }, body: JSON.stringify({ model: process.env.OPENAI_MODEL || 'gpt-4o-mini', response_format: { type: 'json_object' }, messages: [{ role: 'user', content: prompt }] }) });
    const result = await ai.json();
    if (!ai.ok) return json(ai.status, { error: result.error?.message || 'AI generation failed.' });
    const parsed = JSON.parse(result.choices?.[0]?.message?.content || '{}');
    const questions = (parsed.questions || []).filter(q => q.prompt && Array.isArray(q.options) && q.options.length === 4 && Number.isInteger(q.answer) && q.answer >= 0 && q.answer < 4);
    return json(200, { questions });
  } catch (error) { return json(500, { error: error.message || 'Could not generate questions.' }); }
};
