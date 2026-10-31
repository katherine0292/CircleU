/* Isolated design review. No network, storage, inference, microphone or image reading. */
const byId = id => document.getElementById(id);
const example = "I can't take on another task this week.";
const toneNames = ['Soft', 'Balanced', 'Firm'];
let scene = 'Work', selectedStep = 'prepare', lastKey = '', edited = false, softer = false, undoText = null, savedMessage = null;
const wording = byId('wording');
function selectedScene() { return byId('custom-wrap').hidden ? scene : byId('custom').value.trim(); }
function key() { return JSON.stringify([byId('message').value, selectedScene(), byId('tone').value, byId('context').value]); }
function draftText(isSoft = false) {
    const message = byId('message').value.trim();
    if (message === example && selectedScene() === 'Work') {
        if (isSoft || byId('tone').value === '0') return "I'd like to help, but my week is already full. Could we look together at what can wait?";
        if (byId('tone').value === '2') return "I can't take on another task this week. If this is the priority, we'll need to move an existing deadline.";
        return "I'm at capacity this week. If this is the priority, could we agree on which deadline to move?";
    }
    // Keep arbitrary user input verbatim. This is a wording scaffold, not an AI claim.
    return (isSoft || byId('tone').value === '0' ? 'Could we talk this through?\n\n' : '') + message;
}
function updateSave() { byId('save').disabled = !wording.value.trim(); byId('copy').disabled = !wording.value.trim(); if (!wording.value.trim()) byId('softer').disabled = true; document.dispatchEvent(new Event('wording-updated')); }
function clearFeedback() { byId('feedback').textContent = ''; byId('copy').textContent = '▢ Copy'; }
function showStep(step, focus = false) {
    selectedStep = step;
    document.dispatchEvent(new CustomEvent('practice-step',{detail:step}));
    ['prepare','refine','reply'].forEach(name => byId(name+'-panel').classList.toggle('active', name === step));
    if (focus) {
        const target = step === 'prepare' ? byId('message') : byId(step+'-title');
        target.focus({preventScroll:true});
        byId(step+'-panel').scrollIntoView({behavior:'auto',block:'nearest'});
    }
}
function setMode(compare) {
    byId('board').classList.toggle('compare', compare); byId('board').classList.toggle('walk', !compare);
    byId('compare').setAttribute('aria-pressed', String(compare)); byId('walk').setAttribute('aria-pressed', String(!compare));
    showStep(selectedStep);
}
function renderRefine() {
    byId('scene-chip').textContent = selectedScene();
    byId('tone-chip').textContent = toneNames[Number(byId('tone').value)];
    byId('original-message').textContent = byId('message').value;
    byId('context-preview').textContent = byId('context').value;
    byId('context-preview').hidden = !byId('context').value.trim();
    if (key() !== lastKey) {
        wording.value = draftText(); lastKey = key(); edited = false; softer = false; undoText = null;
        byId('undo').hidden = true; byId('softer').disabled = false; clearFeedback();
    }
    updateSave();
}
byId('prepare-form').addEventListener('submit', event => {
    event.preventDefault();
    if (!byId('message').value.trim() || !selectedScene()) {
        byId('prepare-error').textContent = !byId('message').value.trim() ? 'Add your message to continue' : 'Name your scene or choose one above';
        byId('prepare-error').hidden = false; return;
    }
    if (edited && key() !== lastKey && !window.confirm('Update the suggestion? This replaces your edited wording.')) return;
    byId('prepare-error').hidden = true; renderRefine(); setMode(false); showStep('refine', true);
});
document.querySelectorAll('[data-scene]').forEach(button => button.addEventListener('click', () => {
    scene = button.dataset.scene; byId('custom-wrap').hidden = true; byId('custom-toggle').setAttribute('aria-expanded','false');
    document.querySelectorAll('[data-scene]').forEach(item => { item.classList.toggle('selected',item === button); item.setAttribute('aria-pressed',String(item===button)); });
}));
byId('custom-toggle').addEventListener('click', () => {
    const open = byId('custom-wrap').hidden; byId('custom-wrap').hidden = !open;
    byId('custom-toggle').setAttribute('aria-expanded',String(open));
    document.querySelectorAll('[data-scene]').forEach(item => {const selected=!open && item.dataset.scene===scene; item.classList.toggle('selected',selected);item.setAttribute('aria-pressed',String(selected));});
    if(open) byId('custom').focus();
});
byId('tone').addEventListener('input', () => { const text=toneNames[Number(byId('tone').value)]; byId('tone-value').textContent=text; byId('tone').setAttribute('aria-valuetext',text); });
byId('back').addEventListener('click', () => showStep('prepare',true));
wording.addEventListener('input', () => {edited=true;undoText=null;byId('undo').hidden=true;clearFeedback();byId('softer').disabled=false;updateSave();});
byId('softer').addEventListener('click', () => {
    if (!wording.value.trim()) return;
    undoText=wording.value;
    wording.value=edited ? 'Could we talk this through?\n\n'+wording.value : draftText(true);
    softer=true;edited=true;byId('undo').hidden=false;byId('softer').disabled=true;clearFeedback();updateSave();
    byId('feedback').textContent='Softer version ready';
});
byId('undo').addEventListener('click', () => { if(undoText!==null) wording.value=undoText; undoText=null; byId('undo').hidden=true;byId('softer').disabled=false;clearFeedback();updateSave(); });
byId('save').addEventListener('click', () => {
    if(!wording.value.trim())return;
    savedMessage={wording:wording.value,scene:byId('scene-chip').textContent,tone:byId('tone-chip').textContent};
    wording.blur();byId('feedback').textContent='Saved in this preview';
});
byId('copy').addEventListener('click', async () => {
    try { await navigator.clipboard.writeText(wording.value);byId('copy').textContent='✓ Copied';byId('feedback').textContent='Copied'; }
    catch { byId('feedback').textContent='Select your wording and copy it manually';wording.focus();wording.select(); }
});
byId('compare').addEventListener('click',()=>setMode(true));
byId('walk').addEventListener('click',()=>{setMode(false);showStep('prepare');});
byId('large').addEventListener('click',()=>{const on=document.body.classList.toggle('large');byId('large').setAttribute('aria-pressed',String(on));});
byId('reset').addEventListener('click',()=>location.reload());
renderRefine();showStep('prepare');
