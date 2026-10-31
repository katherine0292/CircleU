// One-time Figma mutation. Applied IDs are recorded in result.json; do not rerun blindly.
const page=await figma.getNodeByIdAsync('74:2');await figma.setCurrentPageAsync(page);
await Promise.all(['Regular','SemiBold','Bold'].map(style=>figma.loadFontAsync({family:'Plus Jakarta Sans',style})));
const changed=new Set(),created=[],variables=[];
const mark=n=>(changed.add(n.id),n);
function walk(n){return [n,...(n.type!=='INSTANCE'&&'children'in n?n.children.flatMap(walk):[])];}
const get=id=>figma.getNodeByIdAsync(id),find=(n,name)=>walk(n).find(c=>c.name===name);
const nav=id=>({type:'NODE',destinationId:id,navigation:'NAVIGATE',transition:null,resetScrollPosition:true});
const lit=(type,value)=>({type,resolvedType:type,value});
const ref=(id,type='BOOLEAN')=>({type:'VARIABLE_ALIAS',resolvedType:type,value:{type:'VARIABLE_ALIAS',id}});
const set=(id,value,type='BOOLEAN')=>({type:'SET_VARIABLE',variableId:id,variableValue:lit(type,value)});
const expr=(f,a)=>({type:'EXPRESSION',resolvedType:'BOOLEAN',value:{expressionFunction:f,expressionArguments:a}});
const cond=(test,yes,no=[])=>({type:'CONDITIONAL',conditionalBlocks:[{condition:test,actions:yes},{actions:no}]});
async function click(n,actions){await n.setReactionsAsync(actions.length?[{trigger:{type:'ON_CLICK'},actions}]:[]);mark(n);}
const coll=await figma.variables.getVariableCollectionByIdAsync('VariableCollectionId:79:459');
function variable(name,type,value){const v=figma.variables.createVariable(name,coll,type);v.scopes=type==='STRING'?['TEXT_CONTENT']:type==='BOOLEAN'?['VISIBILITY']:['ALL_SCOPES'];v.setValueForMode(coll.defaultModeId,value);variables.push({id:v.id,name});return v;}
const draft=variable('reflectionDraftWords','STRING',''),saved=variable('reflectionSavedWords','STRING',''),exit=variable('reflectionExit','FLOAT',0);
const todayDraft='VariableID:79:504',hasReflection='VariableID:79:505',newEntry='VariableID:79:503';
const original=(await get('74:3')).children.find(n=>n.name==='Tab bar');
const home=Object.fromEntries(original.children.map(n=>[n.name,n.reactions[0].actions]));
const oldJournal='66c762ef9f6a6369a20bd5516b943865d3ee4c98',oldLogo='eed07c3462597854915dc32ab8e10bebdf4df427';
// Restore missing raster references using the existing local Codex artwork uploaded this turn.
for(const n of page.findAll(n=>n.type==='RECTANGLE'))if(Array.isArray(n.fills)){
 const paints=n.fills.map(p=>p.type==='IMAGE'&&[oldJournal,oldLogo].includes(p.imageHash)?{...p,imageHash:p.imageHash===oldJournal?'b69b99149d4cfcde2069e52e3aecaf573ab45840':'c5ece8de326c8402ee7c704898a1c482fa93c376'}:p);
 if(JSON.stringify(paints)!==JSON.stringify(n.fills)){n.fills=paints;mark(n);}
}
// Keep a visible route back to unsaved Today words.
const journalDraft=await get('74:325'),content=find(journalDraft,'Content');
const draftCard=(await get('74:1000')).clone();content.insertChild(1,draftCard);draftCard.name='Continue your draft';draftCard.setBoundVariable('visible',await figma.variables.getVariableByIdAsync(todayDraft));
const dt=draftCard.findAll(n=>n.type==='TEXT');dt[0].characters='Continue your draft';dt[1].characters='My groupmate missed the deadline again. I froze in the meeting.';dt[1].fontSize=16;
const close=(await get('74:278')).clone();draftCard.appendChild(close);close.name='Manage draft';close.layoutPositioning='ABSOLUTE';close.x=284;close.y=8;dt[0].resize(252,dt[0].height);
await click(draftCard,[set(todayDraft,true),nav('74:35')]);await click(close,[nav('74:184')]);walk(draftCard).forEach(n=>created.push(n.id));
await click(await get('74:195'),[set(todayDraft,true),nav('74:325')]);
// Dictation cannot silently lose the existing typed draft when cancelled.
await click(await get('74:73'),[set(todayDraft,true),nav('74:35')]);
await click(await get('74:77'),[cond(ref(todayDraft),[nav('74:35')],[nav('74:3')])]);
for(const t of (await get('74:64')).children.find(n=>n.name==='Tab bar').children)await click(t,[set(todayDraft,true),...home[t.name]]);
// During this short simulated save, keep the request on screen until success.
for(const n of walk(await get('74:90')))if(n.id!=='74:90'&&'reactions'in n&&n.reactions.length)await click(n,[]);
// A directly opened failure fixture starts with its unsaved words retained.
await (await get('74:119')).setReactionsAsync([{trigger:{type:'AFTER_TIMEOUT',timeout:0.01},actions:[set(todayDraft,true)]}]);changed.add('74:119');
const blank=await get('74:964');
const baseY=Math.max(...page.children.filter(n=>'height'in n).map(n=>n.y+n.height))+160;let col=0;
function cloneFrame(source,key){const n=source.clone();page.appendChild(n);n.name='R17 / '+key;n.x=180+460*col++;n.y=baseY;walk(n).forEach(c=>created.push(c.id));return n;}
const filled=cloneFrame(blank,'reflectionWriting / Reflection');
const failure=cloneFrame(blank,'reflectionError / Reflection');
const saving=cloneFrame(blank,'reflectionSaving / Reflection');
const discard=cloneFrame(await get('74:184'),'discardReflection / Discard changes?');
const answer='I want to ask for a fairer split without blaming anyone.';
const edited='I want a fairer split of the work and time to explain my needs.';
for(const f of [blank,filled,failure,saving]){
 const source=find(f,'Guided prompt');source.characters='Your own reflection';mark(source);
 const input=find(f,'Your words'),text=input.findOne(n=>n.type==='TEXT');input.name='Your reflection';
 if(f===blank){text.characters='Write what matters to you';text.opacity=.55;await click(input,[set(draft.id,answer,'STRING'),nav(filled.id)]);const b=find(f,'Save reflection');b.opacity=.45;await click(b,[]);}
 else{text.setBoundVariable('characters',draft);await click(input,f===saving?[]:[set(draft.id,edited,'STRING')]);}
 mark(text);
}
// The filled editor supports a clear/empty validation state through an existing outline icon.
for(const f of [filled,failure]){const header=find(f,'Header'),clear=(await get('74:278')).clone();header.appendChild(clear);clear.name='Clear reflection';const title=header.children.find(n=>n.type==='TEXT');title.resize(234,title.height);await click(clear,[set(draft.id,'','STRING'),nav(blank.id)]);created.push(clear.id);mark(title);}
const error=(await get('74:135')).clone();find(failure,'Content').appendChild(error);error.characters='Couldn’t save your reflection. Try again.';error.name='Reflection save error';created.push(error.id);
const failSave=find(failure,'Save reflection');failSave.name='Try again';failSave.findOne(n=>n.type==='TEXT').characters='Try again';mark(failSave);
for(const f of [filled,failure])await click(find(f,f===failure?'Try again':'Save reflection'),[nav(saving.id)]);
const savingButton=find(saving,'Save reflection');savingButton.findOne(n=>n.type==='TEXT').characters='Saving…';savingButton.name='Saving reflection';mark(savingButton);
for(const n of walk(saving))if('reactions'in n&&n.reactions.length)await click(n,[]);
await saving.setReactionsAsync([{trigger:{type:'AFTER_TIMEOUT',timeout:.8},actions:[{type:'SET_VARIABLE',variableId:saved.id,variableValue:ref(draft.id,'STRING')},set(hasReflection,true),nav('74:775')]}]);mark(saving);
// Saved reflection belongs to the canonical entry so reopening does not lose it.
const panel=(await get('74:1000')).clone();find(await get('74:775'),'Content').appendChild(panel);panel.name='Saved reflection';panel.setBoundVariable('visible',await figma.variables.getVariableByIdAsync(hasReflection));panel.findAll(n=>n.type==='TEXT')[1].setBoundVariable('characters',saved);walk(panel).forEach(n=>created.push(n.id));
const pencil=(await get('74:779')).clone();panel.appendChild(pencil);pencil.layoutPositioning='ABSOLUTE';pencil.x=282;pencil.y=4;pencil.name='Edit reflection';created.push(pencil.id);
await click(pencil,[{type:'SET_VARIABLE',variableId:draft.id,variableValue:ref(saved.id,'STRING')},nav(filled.id)]);
(await get('74:1002')).setBoundVariable('characters',saved);changed.add('74:1002');(await get('74:999')).setBoundVariable('characters',await figma.variables.getVariableByIdAsync('VariableID:79:460'));changed.add('74:999');
// Opening the offer always starts blank; it never invents a reflection on behalf of the person.
await click(await get('74:276'),[set(draft.id,'','STRING'),set('VariableID:79:507',7,'FLOAT'),nav(blank.id)]);
// Protect user-entered reflection text when leaving. Exit 0=entry/list, 1=Today, 2=Journal, 3=Practice.
const eq=i=>expr('EQUALS',[ref(exit.id,'FLOAT'),lit('FLOAT',i)]);
// Flatten nested conditions to the subset supported by the Figma prototype runtime.
const routes=[cond(expr('AND',[eq(0),ref(hasReflection)]),[nav('74:775')]),cond(expr('AND',[eq(0),expr('NOT',[ref(hasReflection)])]),[nav('74:210')])];
for(const [i,name]of ['Today','Journal','Practice'].entries())for(const a of home[name]){if(a.type==='CONDITIONAL'){const b=a.conditionalBlocks[0];if(b.actions.length)routes.push(cond(expr('AND',[eq(i+1),b.condition]),b.actions));const no=a.conditionalBlocks[1];if(no.actions.length)routes.push(cond(expr('AND',[eq(i+1),expr('NOT',[b.condition])]),no.actions));}else routes.push(cond(eq(i+1),[a]));}
for(const f of [filled,failure]){await click(find(f,'Back'),[set(exit.id,0,'FLOAT'),nav(discard.id)]);await click(find(f,'Not now'),[set(exit.id,0,'FLOAT'),nav(discard.id)]);for(const [i,t]of find(f,'Tab bar').children.entries())await click(t,[set(exit.id,i+1,'FLOAT'),nav(discard.id)]);}
const discardTitle=find(discard,'Leave this draft?');discardTitle.characters='Discard changes?';mark(discardTitle);
find(discard,'Your words').findOne(n=>n.type==='TEXT').setBoundVariable('characters',draft);
await click(find(discard,'Keep editing'),[nav(filled.id)]);
const drop=find(discard,'Keep draft and leave');drop.name='Discard changes';drop.findOne(n=>n.type==='TEXT').characters='Discard changes';await click(drop,[set(draft.id,'','STRING'),...routes]);find(discard,'Discard draft').visible=false;
for(const [i,t]of find(discard,'Tab bar').children.entries())await click(t,[set(exit.id,i+1,'FLOAT')]);
// Failure fixture is entered separately from the success path, with invented unsaved reflection text.
await failure.setReactionsAsync([{trigger:{type:'AFTER_TIMEOUT',timeout:.01},actions:[set(draft.id,answer,'STRING'),set(newEntry,true),set('VariableID:79:506','2 entries','STRING'),set('VariableID:79:507',7,'FLOAT')]}]);mark(failure);
page.name='CircleU • connected review 17';mark(page);
page.flowStartingPoints=[...page.flowStartingPoints,{nodeId:'74:119',name:'Today · save error and retry'},{nodeId:'74:150',name:'Today · microphone unavailable'},{nodeId:failure.id,name:'Reflection · save error and retry'}];
return {createdNodeIds:created,mutatedNodeIds:[...changed],variables,frames:{blank:blank.id,filled:filled.id,failure:failure.id,saving:saving.id,discard:discard.id},draftCard:draftCard.id,savedPanel:panel.id};
