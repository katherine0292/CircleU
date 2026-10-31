'use strict';
// Disposable design specimen: no inference, fetch, persistence or microphone calls.
const $ = id => document.getElementById(id);
const fixtures = {
    project: {words: 'You never help with our project.', reply: 'I thought you wanted to handle the slides.', intent: 'I want us to agree on who does each part.', rewrite: 'Could we agree on which parts of the project each of us will handle?', points: ['“Never” may sound blaming. Try a specific request', 'Make the next step clear'], replyRewrite: 'Could we agree on who will handle each part of the project?', scene: 'Study'},
    reply: {words: 'I can’t take on another task this week.', reply: 'Could you make an exception this time?', intent: 'I want to say no without sounding dismissive.', rewrite: 'I’m not able to take on another task this week.', points: ['Your boundary is clear', 'Keep the reply brief without adding a commitment'], replyRewrite: 'I’m not able to take this on this week.', scene: 'Work'}
};
let screen = 'editor', mode = 'review', generation = 0, timer, prior = null, saved = '', snapshot = null, tone = 'Balanced';
let styleProfile = null;
let clarification = {review: '', reply: ''};
let consentReturn = 'editor';
let guidanceIntent = '';
function intentOnly() { return mode === 'review' && !$('wording').value.trim() && !!guidanceIntent.trim(); }
function reviewInput() { return mode === 'reply' ? $('intent').value : (intentOnly() ? guidanceIntent : $('wording').value); }
function refreshEditor() {
    const hasWords = !!$('wording').value.trim();
    $('save').disabled = !hasWords; $('copy').disabled = !hasWords;
    $('reply').hidden = !hasWords;
    $('goal-card').hidden = !guidanceIntent.trim(); $('goal-summary').textContent = guidanceIntent;
    $('help-start').hidden = !!guidanceIntent.trim();
    $('original-card').hidden = !$('original').textContent.trim();
    if (screen === 'editor') {
        $('primary').disabled = !hasWords && !guidanceIntent.trim();
        $('primary').textContent = hasWords ? 'Review wording' : (guidanceIntent.trim() ? 'Suggest wording' : 'Review wording');
    }
}
function openGuidance() {
    $('guidance-goal').value = guidanceIntent;
    $('guidance-context').value = clarification.review;
    $('guidance-error').textContent = ''; show('guidance');
}

function fixture() { return fixtures[$('example').value]; }
function invalidate() { generation++; clearTimeout(timer); }
function show(next) {
    if (screen === 'loading' && next !== 'loading') invalidate();
    screen = next;
    document.querySelectorAll('.screen').forEach(el => el.hidden = el.id !== next + '-screen');
    const main = ['editor','today','journal','settings'].includes(next);
    $('brand').hidden = !main; $('back').hidden = main;
    $('open-settings').hidden = !['editor','today','journal'].includes(next);
    $('app-tabs').hidden = !['editor','today','journal','settings'].includes(next);
    $('nav-title').textContent = ({today:'Today',journal:'Journal',settings:'Settings',style:'Settings',entry:'Journal'})[next] || 'Practice';
    document.querySelectorAll('[data-page]').forEach(button => button.setAttribute('aria-current',button.dataset.page === next ? 'page' : 'false'));
    if (main) $('screen-picker').value = next;
    $('close').hidden = !['result', 'problem', 'consent'].includes(next);
    $('cancel').hidden = next !== 'loading';
    $('primary').hidden = ['loading','journal','settings'].includes(next);
    $('primary').disabled = next === 'editor' && !$('wording').value.trim();
    const labels = {today:'Open journal', entry:'Practise these words',style:'Save preferences',editor:'Review wording', guidance:'Continue', reply:'Draft a reply', clarify:'Review again', consent:'Send for feedback', result:'Use this wording', problem: $('scenario').value === 'clarify' ? 'Add context' : 'Back to writing'};
    $('primary').textContent = labels[next] || '';
    $('screen-label').textContent = ({editor:'01 — Prepare',guidance:'Optional guidance',reply:'02 — Their reply',clarify:'Add context',consent:'03 — Selected text',loading:'04 — Reviewing',result:'05 — Your choice',problem:'04 — Keep your words', today:'Today', journal:'Journal', entry:'Reflection', settings:'Settings',style:'My communication style'})[next];
    if (next === 'editor') { $('editor-context').value = clarification.review; refreshEditor(); }
    $('body').scrollTop = 0;
    document.querySelector('#' + next + '-screen h2')?.focus({preventScroll:true});
}
function reset(blank = false) {
    invalidate(); const f = fixture(); mode = 'review'; prior = null; snapshot = null; saved = '';
    clarification = {review: '', reply: ''}; guidanceIntent = '';
    $('options').open = false;
    $('wording').value = blank ? '' : f.words; $('original').textContent = blank ? '' : f.words;
    $('their-reply').value = blank ? '' : f.reply; $('intent').value = blank ? '' : f.intent;
    setTone('Balanced'); $('undo').hidden = true; $('editor-status').textContent = ''; $('reply-error').textContent = '';
    show('editor');
}
function setTone(value) {
    invalidate(); tone = value;
    document.querySelectorAll('[data-tone]').forEach(button => button.setAttribute('aria-pressed', String(button.dataset.tone === tone)));
}
function openReply() { mode = 'reply'; $('prepared').textContent = $('wording').value; show('reply'); }
function openClarification() {
    $('clarification').value = clarification[mode];
    $('clarification-source-label').textContent = mode === 'reply' || intentOnly() ? 'Your intent' : 'Your words';
    $('clarification-source').textContent = reviewInput();
    $('clarification-error').textContent = '';
    show('clarify');
}
function confirm() {
    invalidate();
    if (mode === 'reply' && !$('intent').value.trim()) { $('reply-error').textContent = 'Add what you want to say next'; $('intent').focus(); return; }
    if (mode === 'review' && !$('wording').value.trim() && !guidanceIntent.trim()) { $('editor-status').textContent = 'Add your words first'; $('wording').focus(); return; }
    $('shared-tone').textContent = tone;
    $('style-consent').hidden = !styleProfile?.enabled;
    $('include-style').checked = false; $('shared-style').hidden = true;
    $('shared-style').textContent = styleProfile ? [styleProfile.language, styleProfile.voice, styleProfile.length].join(' · ') : '';
    $('payload-label').textContent = mode === 'reply' || intentOnly() ? 'Your intent' : 'Your words';
    $('payload-words').textContent = reviewInput();
    $('intent-preview').hidden = mode !== 'review' || intentOnly() || !guidanceIntent.trim();
    $('shared-intent').textContent = guidanceIntent;
    $('shared-context').textContent = clarification[mode];
    $('context-preview').hidden = !clarification[mode].trim();
    $('context-options').hidden = mode !== 'reply';
    $('include-prepared').checked = false; $('include-reply').checked = false;
    $('selected-prepared').textContent = $('wording').value; $('selected-reply').textContent = $('their-reply').value;
    $('selected-prepared').hidden = true; $('selected-reply').hidden = true;
    consentReturn = screen;
    show('consent');
}
function result() {
    const f = fixture();
    $('points').replaceChildren();
    const points = snapshot.inputKind === 'intent' && mode === 'review' ? ['State the request clearly', 'Leave room for their response'] : mode === 'reply' ? (fixture() === fixtures.reply ? ['Keep your boundary clear', 'No extra promise is needed'] : ['Ask for a shared decision', 'Keep the next step specific']) : f.points;
    for (const point of points) {
        const li = document.createElement('li');
        li.innerHTML = '<svg aria-hidden="true" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><path d="M12 3v3m0 12v3M3 12h3m12 0h3M7 7l2 2m6 6 2 2M7 17l2-2m6-6 2-2"/><circle cx="12" cy="12" r="3"/></svg>';
        const text = document.createElement('span'); text.textContent = point; li.append(text); $('points').append(li);
    }
    const choices = {
        project: {
            review: {Soft:'Could we work out together who will handle each part of the project?', Balanced:f.rewrite, Firm:'We need to agree on who will handle each part of the project.'},
            reply: {Soft:'Could we work out together who will handle each part?', Balanced:f.replyRewrite, Firm:'Let’s agree on who will handle each part of the project.'}
        },
        reply: {
            review: {Soft:'I’m afraid I can’t take on another task this week.', Balanced:f.rewrite, Firm:'I can’t take on another task this week.'},
            reply: {Soft:'I’m afraid I can’t make an exception this week.', Balanced:f.replyRewrite, Firm:'I can’t make an exception this week.'}
        }
    };
    $('rewrite-edit').value = choices[$('example').value][mode][tone];
    if (snapshot.style?.voice === 'Formal') {
        const formal = $('example').value === 'project' ? (tone === 'Firm' ? 'We need to agree on the responsibilities for each part of the project.' : 'Could we agree on the responsibilities for each part of the project?') : (mode === 'reply' ? 'I am unable to make an exception this week.' : 'I am unable to take on another task this week.');
        $('rewrite-edit').value = formal;
    } else if (snapshot.style?.length === 'Brief' && $('example').value === 'project') {
        $('rewrite-edit').value = tone === 'Firm' ? 'Let’s agree on who handles each part.' : 'Could we agree on who handles each part?';
    }
    $('result-tone').textContent = tone;
    document.querySelector('.result-meta .source').textContent = snapshot.style ? 'Online suggestion · My style' : 'Online suggestion';
    $('compare-label').textContent = snapshot.inputKind === 'intent' ? 'Your intent' : 'Your original words';
    $('compare-text').textContent = snapshot.words;
    show('result');
}
function submit() {
    invalidate();
    prior = null; $('undo').hidden = true;
    snapshot = {inputKind: mode === 'reply' || intentOnly() ? 'intent' : 'wording', guidanceIntent, words: $('payload-words').textContent, original: $('wording').value, intent: $('intent').value, reply: $('their-reply').value, mode, tone, style: $('include-style').checked && styleProfile?.enabled ? {...styleProfile} : null, example:$('example').value,
        prepared: $('include-prepared').checked ? $('selected-prepared').textContent : null,
        received: $('include-reply').checked ? $('selected-reply').textContent : null, context: clarification[mode]};
    const request = generation; show('loading');
    timer = setTimeout(() => {
        if (request !== generation || screen !== 'loading') return;
        const scenario = $('scenario').value;
        if (scenario === 'success') return result();
        const states = {clarify:['A little more context', 'What would you like the other person to do next?'],error:['Try again later', 'Couldn’t review your wording. Your words are still here'],offline:['You’re offline', 'You can keep writing and try again later']};
        $('problem-title').textContent = states[scenario][0]; $('problem-copy').textContent = states[scenario][1]; show('problem');
    }, 1600);
}
function dismiss() {
    invalidate();
    show(screen === 'consent' ? consentReturn : (mode === 'reply' ? 'reply' : 'editor'));
}
$('primary').onclick = () => {
    if (screen === 'editor') { mode = 'review'; confirm(); }
    else if (screen === 'guidance') {
        if (!$('guidance-goal').value.trim()) { $('guidance-error').textContent = 'Add what you want to happen'; $('guidance-goal').focus(); return; }
        invalidate(); prior = null; $('undo').hidden = true;
        guidanceIntent = $('guidance-goal').value;
        clarification.review = $('guidance-context').value;
        $('editor-status').textContent = ''; mode = 'review'; show('editor');
    }
    else if (screen === 'reply') confirm();
    else if (screen === 'clarify') {
        if (!$('clarification').value.trim()) {
            $('clarification-error').textContent = 'Add a little context to review again';
            $('clarification').focus(); return;
        }
        clarification[mode] = $('clarification').value;
        confirm();
    }
    else if (screen === 'consent') submit();
    else if (screen === 'result') {
        if (!snapshot || snapshot.guidanceIntent !== guidanceIntent || snapshot.context !== clarification[mode] || snapshot.tone !== tone || snapshot.original !== $('wording').value || snapshot.intent !== $('intent').value || snapshot.reply !== $('their-reply').value) { dismiss(); return; }
        const proposed = $('rewrite-edit').value;
        if (!proposed.trim()) { $('rewrite-edit').focus(); return; }
        prior = $('wording').value; $('original').textContent = prior; $('wording').value = proposed; $('undo').hidden = false;
        $('editor-status').textContent = 'Wording updated'; mode = 'review'; show('editor');
    } else if (screen === 'problem') { if ($('scenario').value === 'clarify') openClarification(); else dismiss(); }
};
$('help-start').onclick = openGuidance; $('edit-goal').onclick = openGuidance;
$('clear-goal').onclick = () => { invalidate(); guidanceIntent = ''; prior = null; $('undo').hidden = true; refreshEditor(); };
$('guidance-goal').oninput = () => { $('guidance-error').textContent = ''; };
$('editor-context').oninput = () => { invalidate(); clarification.review = $('editor-context').value; };
$('save').onclick = () => {
    if (!$('wording').value.trim()) return;
    saved = $('wording').value; $('editor-status').textContent = 'Saved';
};
$('copy').onclick = async () => {
    const words = $('wording').value;
    if (!words.trim()) return;
    try {
        await navigator.clipboard.writeText(words);
        if (screen === 'editor' && $('wording').value === words) $('editor-status').textContent = saved === words ? 'Copied. Not sent.' : 'Copied. Not saved or sent.';
    } catch {
        if (screen === 'editor' && $('wording').value === words) $('editor-status').textContent = 'Couldn’t copy. Select your words and try again';
    }
};
$('reply').onclick = openReply;
$('back').onclick = () => { if (screen === 'reply' || screen === 'guidance') { mode = 'review'; show('editor'); } else dismiss(); };
$('close').onclick = dismiss; $('cancel').onclick = dismiss;
$('undo').onclick = () => { if (prior !== null) $('wording').value = prior; prior = null; $('undo').hidden = true; $('editor-status').textContent = 'Previous wording restored'; refreshEditor(); };
$('rewrite-edit').oninput = () => $('primary').disabled = !$('rewrite-edit').value.trim();
$('clarification').oninput = () => {
    invalidate(); clarification[mode] = $('clarification').value;
    $('clarification-error').textContent = '';
};
for (const id of ['wording','intent','their-reply']) $(id).addEventListener('input', () => { invalidate(); $('editor-status').textContent = ''; $('reply-error').textContent = ''; if (id === 'wording') { prior = null; $('undo').hidden = true; refreshEditor(); } });
for (const name of ['prepared','reply']) $('include-' + name).onchange = () => $('selected-' + name).hidden = !$('include-' + name).checked;
$('large').onclick = () => { const large = document.body.classList.toggle('large'); $('large').setAttribute('aria-pressed', String(large)); };
document.querySelectorAll('[data-tone]').forEach(button => button.onclick = () => setTone(button.dataset.tone));
$('reset').onclick = () => reset(); $('blank').onclick = () => reset(true); $('example').onchange = () => reset();
$('scenario').onchange = () => { if (['loading','result','problem'].includes(screen)) dismiss(); };
document.addEventListener('visibilitychange', () => { if (document.hidden && screen === 'loading') dismiss(); });
reset(true);
