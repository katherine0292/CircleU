/* Reply and voice DESIGN FIXTURES. No microphone, speech service or model calls. */
let followupMode = 'reply';
const followupDrafts = {reply:'This needs to be finished today. Can you make it work?',context:''};
let followupRevision = 0, followupBusy = false;
const followup = byId('followup-input');
const microphoneIcon = '<svg viewBox="0 0 24 24" width="20" height="20" aria-hidden="true" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"><rect x="8" y="2" width="8" height="13" rx="4"/><path d="M5 10v2a7 7 0 0 0 14 0v-2M12 19v3m-4 0h8"/></svg>';
document.querySelectorAll('[data-voice]').forEach(button => {button.innerHTML=microphoneIcon;button.type='button';});
function invalidateFollowup() {
    followupRevision++; followupBusy=false;
    byId('followup-results').hidden=true;
    byId('reply-feedback').textContent='';
    updateFollowupAction();
}
function updateFollowupAction() {
    const action=byId('get-options');
    action.disabled=followupBusy || !followup.value.trim();
    action.textContent=followupBusy ? 'Preparing options…' : followupMode==='reply' ? 'Get reply options' : 'Update wording';
}
function setFollowupMode(mode) {
    followupDrafts[followupMode]=followup.value;
    followupMode=mode;followup.value=followupDrafts[mode];
    byId('mode-reply').setAttribute('aria-selected',String(mode==='reply'));
    byId('mode-context').setAttribute('aria-selected',String(mode==='context'));
    byId('followup-fields').setAttribute('aria-labelledby','mode-'+mode);
    byId('followup-label').textContent=mode==='reply'?'Paste their reply':'Add more context';
    followup.placeholder=mode==='reply'?'What did they say?':'What else would help explain the situation?';
    document.querySelector('[data-voice="followup-input"]').setAttribute('aria-label',mode==='reply'?'Dictate their reply':'Record more context');
    invalidateFollowup();
}
byId('mode-reply').addEventListener('click',()=>setFollowupMode('reply'));
byId('mode-context').addEventListener('click',()=>setFollowupMode('context'));
document.querySelector('.mode-picker').addEventListener('keydown',event=>{
    if(['ArrowLeft','ArrowRight'].includes(event.key)) {
        event.preventDefault();setFollowupMode(followupMode==='reply'?'context':'reply');byId('mode-'+followupMode).focus();
    }
});
function openFollowup() {
    byId('current-wording').textContent=wording.value;
    invalidateFollowup();setMode(false);showStep('reply',true);
}
document.addEventListener('practice-step',event=>{if(event.detail!=='reply')invalidateFollowup();});
byId('open-reply').addEventListener('click',openFollowup);
byId('reply-back').addEventListener('click',()=>{invalidateFollowup();showStep('refine',true);});
followup.addEventListener('input',()=>{followupDrafts[followupMode]=followup.value;invalidateFollowup();});
document.addEventListener('wording-updated',()=>{byId('current-wording').textContent=wording.value;invalidateFollowup();});
byId('get-options').addEventListener('click',()=>{
    if(followupBusy||!followup.value.trim())return;
    const request=++followupRevision;
    const mode=followupMode,base=wording.value;
    followupBusy=true;byId('reply-feedback').textContent='Preparing options…';updateFollowupAction();
    setTimeout(()=>{
        if(request!==followupRevision)return;
        followupBusy=false;updateFollowupAction();
        if(byId('suggestion-scenario').value==='failed') {
            byId('reply-feedback').textContent='Suggestions are unavailable. Your words are still here; try again.';
            return;
        }
        byId('reply-feedback').textContent='';
        const source=byId('result-source');source.replaceChildren();
        const label=document.createElement('strong');label.textContent=mode==='reply'?'Reply options':'Updated wording';
        source.append(label);
        const options=mode==='reply' ? [
            {name:'Clarify priorities',text:'Could we agree on what to prioritise and what can wait?'},
            {name:'Set a limit',text:"I can't commit to that yet. Could we agree on a realistic next step?"}
        ] : [
            {name:'Keep my wording',text:base},
            {name:'Invite a next step',text:[base,'Could we talk through the next step together?'].filter(Boolean).join('\n\n')}
        ];
        const list=byId('reply-options');list.replaceChildren();
        for(const option of options) {
            const card=document.createElement('article');card.className='reply-option';
            const title=document.createElement('strong');title.textContent=option.name;
            const text=document.createElement('p');text.textContent=option.text;
            const use=document.createElement('button');use.type='button';use.className='secondary';use.textContent='Use wording';
            use.setAttribute('aria-label','Use '+option.name.toLowerCase());use.disabled=!option.text.trim();
            use.addEventListener('click',()=>{
                undoText=wording.value;
                wording.value=option.text;edited=true;byId('undo').hidden=false;byId('softer').disabled=false;
                clearFeedback();updateSave();byId('feedback').textContent='Wording added. Review it before saving.';
                invalidateFollowup();setMode(false);showStep('refine',true);
            });
            card.append(title,text,use);list.append(card);
        }
        byId('followup-results').hidden=false;
        source.scrollIntoView({behavior:'auto',block:'nearest'});
    },450);
});
byId('undo').addEventListener('click',()=>{byId('current-wording').textContent=wording.value;invalidateFollowup();});

const voiceDialog=byId('voice-dialog');
let voiceTarget=null,voiceState='ready';
function voiceFixture() {
    if(voiceTarget==='followup-input')return followupMode==='reply'?'Could we talk about this tomorrow?':'I have already agreed to another deadline.';
    if(voiceTarget==='context')return 'I have already agreed to another deadline.';
    return "I want to help, but I need more time.";
}
function voiceStage(state) {
    voiceState=state;
    byId('voice-wave').hidden=state!=='recording';
    const review=state==='review'||state==='interrupted';
    byId('transcript-label').hidden=!review;byId('voice-transcript').hidden=!review;
    byId('voice-error').hidden=true;
    const titles={ready:'Ready to talk?',recording:'Listening preview',review:'Check your words',denied:'Microphone access is off',unavailable:'Voice is unavailable',interrupted:'Recording interrupted'};
    const hints={ready:'Speak your own message or context',recording:'Stop when you’re ready to review',review:'Edit before adding it to your draft',denied:'You can keep typing',unavailable:'You can keep typing',interrupted:'Review the words captured so far'};
    byId('voice-title').textContent=titles[state];byId('voice-hint').textContent=hints[state];
    byId('voice-action').textContent=state==='ready'?'Start preview':state==='recording'?'Stop':review?'Use text':'Keep typing';
    byId('voice-type').hidden=state==='denied'||state==='unavailable';
    byId('voice-action').disabled=review&&!byId('voice-transcript').value.trim();
}
document.querySelectorAll('[data-voice]').forEach(button=>button.addEventListener('click',()=>{
    voiceTarget=button.dataset.voice;byId('voice-transcript').value='';
    const scenario=byId('voice-scenario').value;
    voiceStage(scenario==='denied'||scenario==='unavailable'?scenario:'ready');
    voiceDialog.showModal();
}));
byId('voice-action').addEventListener('click',()=>{
    if(voiceState==='ready'){voiceStage('recording');return;}
    if(voiceState==='recording'){
        byId('voice-transcript').value=voiceFixture();
        voiceStage(byId('voice-scenario').value==='interrupted'?'interrupted':'review');return;
    }
    if(voiceState==='review'||voiceState==='interrupted'){
        const text=byId('voice-transcript').value.trim();if(!text)return;
        const target=byId(voiceTarget);
        target.value=[target.value.trim(),text].filter(Boolean).join('\n\n');
        target.dispatchEvent(new Event('input',{bubbles:true}));
        voiceDialog.close();target.focus();return;
    }
    voiceDialog.close();byId(voiceTarget).focus();
});
byId('voice-transcript').addEventListener('input',()=>{byId('voice-action').disabled=!byId('voice-transcript').value.trim();});
byId('voice-close').addEventListener('click',()=>voiceDialog.close());
byId('voice-type').addEventListener('click',()=>{voiceDialog.close();byId(voiceTarget).focus();});
voiceDialog.addEventListener('close',()=>{byId('voice-transcript').value='';voiceState='ready';});
followup.value=followupDrafts.reply;byId('current-wording').textContent=wording.value;updateFollowupAction();
