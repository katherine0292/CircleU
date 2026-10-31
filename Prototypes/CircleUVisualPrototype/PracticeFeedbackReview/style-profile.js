'use strict';
// Optional preferences for this browser session only; no inferred traits or persistence.
let styleReturn = 'settings';
function updateStyleSummary() {
    const description = styleProfile?.enabled ? `${styleProfile.voice} · ${styleProfile.length}` : (styleProfile ? 'Saved · not in use' : 'Not in use');
    $('settings-style-summary').textContent = description;
    $('style-summary').hidden = !styleProfile?.enabled;
    $('style-summary').textContent = `My style: ${description}`;
}
function openStyle() {
    styleReturn = screen;
    $('style-enabled').checked = styleProfile?.enabled || false;
    $('style-language').value = styleProfile?.language || 'Australian English';
    $('style-voice').value = styleProfile?.voice || 'Conversational';
    $('style-length').value = styleProfile?.length || 'Brief';
    show('style');
}
const practiceAction = $('primary').onclick;
$('primary').onclick = () => {
    if (screen === 'style') {
        invalidate();
        styleProfile = {enabled:$('style-enabled').checked, language:$('style-language').value, voice:$('style-voice').value, length:$('style-length').value};
        updateStyleSummary(); $('settings-status').textContent = styleProfile.enabled ? 'Preferences enabled' : 'Saved · not in use'; show(styleReturn);
    } else if (screen === 'today') show('journal');
    else if (screen === 'entry') { $('example').value = 'project'; reset(); }
    else practiceAction();
};
const practiceBack = $('back').onclick;
$('back').onclick = () => {
    if (screen === 'style') show(styleReturn);
    else if (screen === 'entry') show('journal');
    else practiceBack();
};
function navigate(page) { invalidate(); show(page); }
$('open-settings').onclick = () => navigate('settings');
$('manage-style').onclick = openStyle;
$('clear-style').onclick = () => {
    invalidate(); styleProfile = null; updateStyleSummary();
    $('include-style').checked = false; $('shared-style').textContent = ''; $('shared-style').hidden = true;
    $('settings-status').textContent = 'Preferences cleared'; show(styleReturn);
};
$('include-style').onchange = () => { $('shared-style').hidden = !$('include-style').checked; };
$('today-practice').onclick = () => navigate('editor');
$('journal-entry').onclick = () => navigate('entry');
$('screen-picker').onchange = () => navigate($('screen-picker').value);
document.querySelectorAll('[data-page]').forEach(button => button.onclick = () => navigate(button.dataset.page));
updateStyleSummary();
