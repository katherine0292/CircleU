// Approved review scope: editable Figma states only; no native service activation.
if (figma.root.children.some(p => p.name === 'Practice • review 10')) return {alreadyCreated:true};
const source = await figma.getNodeByIdAsync('39:7');
const artSource = await figma.getNodeByIdAsync('39:11');
const primarySource = await figma.getNodeByIdAsync('39:3');
const secondarySource = await figma.getNodeByIdAsync('39:5');
await Promise.all(['Regular','SemiBold','Bold'].map(style=>figma.loadFontAsync({family:'Plus Jakarta Sans',style})));
const page=figma.createPage();page.name='Practice • review 10';await figma.setCurrentPageAsync(page);
const ids=[page.id], screens={}, links=[], controls={};
const ink={r:13/255,g:20/255,b:33/255},muted={r:70/255,g:93/255,b:127/255};
const blue=primarySource.fills[0].color,ice=source.fills;
const white=[{type:'SOLID',color:{r:1,g:1,b:1}}],pale=[{type:'SOLID',color:{r:.88,g:.94,b:1}}];
const solid=c=>[{type:'SOLID',color:c}];
const remember=n=>(ids.push(n.id),n);
function stack(parent,name,w=342,gap=12,horizontal=false){const n=remember(figma.createAutoLayout(horizontal?'HORIZONTAL':'VERTICAL'));n.name=name;n.fills=[];n.resize(w,40);n.primaryAxisSizingMode='AUTO';n.counterAxisSizingMode='FIXED';n.itemSpacing=gap;parent.appendChild(n);return n;}
function txt(parent,s,size=17,bold=false,color=ink,w=342){const n=remember(figma.createText());n.fontName={family:'Plus Jakarta Sans',style:bold?'SemiBold':'Regular'};n.characters=s;n.fontSize=size;n.lineHeight={unit:'PERCENT',value:140};n.fills=solid(color);n.textAutoResize='HEIGHT';n.resize(w,24);parent.appendChild(n);n.layoutSizingHorizontal='FIXED';n.layoutSizingVertical='HUG';return n;}
function art(parent,size=88){const n=remember(figma.createRectangle());n.name='Pingu • decorative';n.resize(size,size);n.fills=artSource.fills;parent.appendChild(n);return n;}
const glyphs={back:'M15 6 L9 12 L15 18',copy:'M9 7 L9 4 L20 4 L20 17 L17 17 M5 8 L16 8 L16 21 L5 21 Z',edit:'M4 17 L4 21 L8 21 L20 9 L16 5 Z M14 7 L18 11',mic:'M9 5 C9 1 15 1 15 5 L15 12 C15 16 9 16 9 12 Z M6 11 L6 13 C6 21 18 21 18 13 L18 11 M12 20 L12 23',more:'M4 12 L5 12 M11 12 L12 12 M18 12 L19 12',check:'M5 12 L10 17 L20 6',chat:'M4 4 L20 4 L20 17 L10 17 L4 21 Z',close:'M6 6 L18 18 M18 6 L6 18'};
const iconKits={};
for(const [key,path] of Object.entries(glyphs)){const c=remember(figma.createComponent());c.name='Review10 / '+key;c.resize(44,44);c.fills=white;c.cornerRadius=16;page.appendChild(c);c.x=180+Object.keys(iconKits).length*60;c.y=-200;const v=remember(figma.createVector());v.vectorPaths=[{windingRule:'NONZERO',data:path}];v.fills=[];v.strokes=solid(blue);v.strokeWeight=1.8;v.strokeCap='ROUND';v.strokeJoin='ROUND';c.appendChild(v);v.x=10;v.y=10;iconKits[key]=c;}
function icon(parent,key,label,target){const n=remember(iconKits[key].createInstance());n.name=label;parent.appendChild(n);if(target)links.push({node:n,target});return n;}
function button(parent,label,target,filled=true){const n=remember((filled?primarySource:secondarySource).createInstance());n.name=label;parent.appendChild(n);n.resize(342,52);const t=n.findOne(x=>x.type==='TEXT');t.characters=label;ids.push(t.id);if(target)links.push({node:n,target});return n;}
function panel(parent,label,value,opts={}){const p=stack(parent,label,342,10);p.fills=opts.hero?solid(blue):opts.tinted?pale:white;p.cornerRadius=24;p.paddingLeft=18;p.paddingRight=18;p.paddingTop=18;p.paddingBottom=18;
 const color=opts.hero?{r:1,g:1,b:1}:ink;
 txt(p,label,12,true,opts.hero?color:muted,306);txt(p,value,opts.hero?23:17,!!opts.hero,color,306);
 if(opts.min){p.resize(342,opts.min);p.primaryAxisSizingMode='FIXED';}
 if(opts.target)links.push({node:p,target:opts.target});return p;}
const original='I’ve done most of the slides. Can you take a fair share before Friday?';
const suggested='Could we agree on a fair split of the remaining slides before Friday?';
const edited='Could we split the remaining slides fairly before Friday?';
const reply='I can finish the research slides on Thursday.';
const context='Our group rehearsal is on Friday.';
const next='Thursday works. Can you send them by 4 pm so we can practise?';
const nextSuggestion='Thursday works. Could you send the slides by 4 pm so we can practise together?';
const intent='Agree on a fair split of the slides before Friday';
const defs=[
 {k:'start',title:'Practice',art:144,sub:'Find words that feel like you',primary:['Practice a message','blank'],secondary:[['Open conversation','saved']]},
 {k:'blank',title:'What would you like to say?',nav:'Prepare',back:'start',cards:[['Your wording','Write your message',{min:190,target:'filled'}]],mic:'voiceReady',secondary:[['Help me get started','guide']]},
 {k:'filled',title:'What would you like to say?',nav:'Prepare',back:'discard',cards:[['Your wording',original,{min:190}]],primary:['Review wording','consent'],secondary:[['Save without feedback','savedOriginal']]},
 {k:'guide',title:'What do you want to happen?',nav:'Prepare',back:'blank',cards:[['Your intent',intent,{target:'intent'}]],primary:['Continue','intent']},
 {k:'intent',title:'What would you like to say?',nav:'Prepare',back:'guide',cards:[['Your intent',intent]],primary:['Suggest wording','consentIntent'],secondary:[['Edit intent','guide'],['Clear intent','blank']]},
 {k:'consent',title:'Review online',back:'filled',sub:'Only the text below will be shared',cards:[['Your wording',original]],primary:['Send for feedback','loading']},
 {k:'loading',title:'Reviewing your wording',back:'filled',art:112,sub:'Your draft stays as it is',cards:[['Your wording',original]],secondary:[['Cancel','filled']],timer:'refineA'},
 {k:'refineA',title:'Find your words',nav:'Refine',back:'filled',hero:true,cards:[['Suggested wording',suggested,{hero:true}],['Try this','Make one clear request about sharing the work.']],primary:['Use this wording','applied'],secondary:[['Compare with mine','refineB'],['Keep my wording','filled']]},
 {k:'refineB',title:'Find your words',nav:'Refine',back:'filled',cards:[['Your wording',original],['Suggested wording',suggested,{tinted:true}],['Try this','Make one clear request about sharing the work.']],primary:['Use this wording','applied'],secondary:[['Keep my wording','filled']]},
 {k:'applied',title:'Your wording',back:'refineA',cards:[['Prepared message',suggested,{min:190}]],tools:[['edit','Edit wording','edited'],['copy','Copy wording','copiedUnsaved']],primary:['Save','saved'],secondary:[['Undo','filled']]},
 {k:'edited',title:'Your wording',back:'discardEdit',cards:[['Prepared message',edited,{min:190}]],primary:['Save','savedEdited'],secondary:[['Discard edit','applied']]},
 {k:'copiedUnsaved',title:'Your wording',back:'applied',sub:'Copied. Not saved or sent.',cards:[['Prepared message',suggested,{min:190}]],primary:['Save','saved'],secondary:[['Keep editing','applied']]},
 {k:'saved',title:'Conversation',back:'start',sub:'Saved on this iPhone',cards:[['Prepared by you',suggested,{tinted:true}]],tools:[['copy','Copy saved wording','copiedSaved']],primary:['Add their reply','replyBlank']},
 {k:'copiedSaved',title:'Conversation',back:'saved',sub:'Copied. Not sent.',cards:[['Prepared by you',suggested,{tinted:true}]],primary:['Add their reply','replyBlank']},
 {k:'replyBlank',title:'Add their reply',back:'saved',cards:[['Their reply','Paste or type their reply',{min:140,target:'replyFilled'}]],secondary:[['Add more context','contextOnly']]},
 {k:'replyFilled',title:'Add their reply',back:'discardReply',cards:[['Their reply',reply],['More context',context]],primary:['Save reply','conversation']},
 {k:'conversation',title:'Conversation',back:'start',cards:[['Prepared by you',suggested,{tinted:true}],['Their reply',reply],['Your context',context]],primary:['Prepare next message','nextBlank']},
 {k:'nextBlank',title:'What would you like to say?',nav:'Prepare reply',back:'conversation',cards:[['Their reply',reply],['Your next message','Write your reply',{min:130,target:'nextFilled'}]]},
 {k:'nextFilled',title:'What would you like to say?',nav:'Prepare reply',back:'discardNext',cards:[['Your next message',next]],primary:['Review wording','consentNext'],secondary:[['Save without feedback','savedNextOriginal']]},
 {k:'consentNext',title:'Review online',back:'nextFilled',sub:'Only the text below will be shared',cards:[['Your next message',next],['Their reply',reply],['Your context',context]],primary:['Send for feedback','loadingNext']},
 {k:'loadingNext',title:'Reviewing your wording',back:'nextFilled',art:112,cards:[['Your next message',next]],secondary:[['Cancel','nextFilled']],timer:'resultNext'},
 {k:'resultNext',title:'Find your words',nav:'Refine reply',back:'nextFilled',cards:[['Suggested wording',nextSuggestion,{hero:true}],['Try this','Keep the time specific and explain what it helps you do.']],primary:['Use this wording','appliedNext'],secondary:[['Keep my wording','nextFilled']]},
 {k:'appliedNext',title:'Your wording',back:'resultNext',cards:[['Prepared message',nextSuggestion]],primary:['Save','savedNext'],secondary:[['Undo','nextFilled']]},
 {k:'savedNext',title:'Conversation',back:'start',sub:'Saved on this iPhone',cards:[['Prepared by you',suggested,{tinted:true}],['Their reply',reply],['Your context',context],['Prepared by you',nextSuggestion,{tinted:true}]],tools:[['copy','Copy latest wording','copiedNext']],primary:['Done','start']},
 {k:'copiedNext',title:'Conversation',back:'savedNext',sub:'Copied. Not sent.',cards:[['Prepared by you',suggested,{tinted:true}],['Their reply',reply],['Your context',context],['Prepared by you',nextSuggestion,{tinted:true}]],primary:['Done','start']},
 {k:'voiceReady',title:'Record your words',back:'blank',art:144,sub:'You can review the text before using it',primary:['Record','recording']},
 {k:'recording',title:'Listening',back:'discardVoice',wave:true,sub:'00:08',cards:[['Heard so far',original]],primary:['Stop','transcript'],secondary:[['Cancel','discardVoice']]},
 {k:'transcript',title:'Review your words',back:'discardVoice',cards:[['Transcript',original,{min:190,target:'transcriptEdit'}]],primary:['Use text','filled'],secondary:[['Record again','voiceReady']]},
 {k:'transcriptEdit',title:'Review your words',back:'transcript',cards:[['Transcript','I’ve done most of the slides. Could you share the work before Friday?',{min:190}]],primary:['Use text','voiceEditedFilled']},
 {k:'voiceEditedFilled',title:'What would you like to say?',nav:'Prepare',back:'discardVoiceEdited',cards:[['Your wording','I’ve done most of the slides. Could you share the work before Friday?',{min:190}]],primary:['Review wording','consentVoice'],secondary:[['Save without feedback','savedVoice']]},
 {k:'voiceDenied',title:'Microphone unavailable',back:'blank',art:112,sub:'Allow microphone access in Settings, or type instead',primary:['Type instead','blank']},
 {k:'voiceError',title:'Couldn’t transcribe',back:'blank',sub:'Try recording again, or type your words',primary:['Try again','voiceReady'],secondary:[['Type instead','blank']]},
 {k:'feedbackError',title:'Couldn’t get feedback',back:'filled',sub:'Your words are still here. Try again or keep editing.',cards:[['Your wording',original]],primary:['Try again','consent'],secondary:[['Keep editing','filled']]},
 {k:'saveError',title:'Couldn’t save',back:'applied',sub:'Your wording is still here. Try again.',cards:[['Prepared message',suggested]],primary:['Try again','saved'],secondary:[['Keep editing','applied']]},
 {k:'copyError',title:'Couldn’t copy',back:'applied',sub:'Try again, or select your words to copy them',cards:[['Prepared message',suggested]],primary:['Try again','copiedUnsaved'],secondary:[['Keep editing','applied']]},
 {k:'blankError',title:'What would you like to say?',nav:'Prepare',back:'start',sub:'Add your words, or ask for help to get started',cards:[['Your wording','Write your message',{min:190,target:'filled'}]],secondary:[['Help me get started','guide']]},
 {k:'discard',title:'Leave this draft?',back:'filled',cards:[['Your wording',original]],primary:['Keep editing','filled'],secondary:[['Keep draft and leave','draftSaved'],['Discard draft','blank']]},
 {k:'draftSaved',title:'Practice',sub:'Draft kept on this iPhone',cards:[['Continue your draft',original,{target:'filled'}]],primary:['Continue draft','filled']},
 {k:'discardEdit',title:'Discard your edit?',back:'edited',cards:[['Your edit',edited]],primary:['Keep editing','edited'],secondary:[['Discard edit','applied']]},
 {k:'discardNext',title:'Leave this draft?',back:'nextFilled',cards:[['Your next message',next]],primary:['Keep editing','nextFilled'],secondary:[['Discard draft','conversation']]},
 {k:'discardReply',title:'Discard this reply?',back:'replyFilled',cards:[['Their reply',reply],['Your context',context]],primary:['Keep editing','replyFilled'],secondary:[['Discard reply','saved']]},
 {k:'discardVoice',title:'Discard this recording?',back:'transcript',cards:[['Transcript',original]],primary:['Review text','transcript'],secondary:[['Discard recording','blank']]},
 {k:'contextOnly',title:'Add more context',back:'replyBlank',cards:[['Your context',context]],primary:['Save context','conversationContext']},
 {k:'conversationContext',title:'Conversation',back:'start',cards:[['Prepared by you',suggested,{tinted:true}],['Your context',context]],primary:['Done','saved']},
 {k:'savedOriginal',title:'Conversation',back:'start',sub:'Saved on this iPhone',cards:[['Prepared by you',original,{tinted:true}]],primary:['Done','start']},
 {k:'savedEdited',title:'Conversation',back:'start',sub:'Saved on this iPhone',cards:[['Prepared by you',edited,{tinted:true}]],primary:['Done','start']},
 {k:'savedNextOriginal',title:'Conversation',back:'start',sub:'Saved on this iPhone',cards:[['Prepared by you',suggested,{tinted:true}],['Their reply',reply],['Your context',context],['Prepared by you',next,{tinted:true}]],primary:['Done','start']},
 {k:'consentIntent',title:'Review online',back:'intent',sub:'Only the text below will be shared',cards:[['Your intent',intent]],primary:['Send for feedback','resultIntent']},
 {k:'resultIntent',title:'Find your words',nav:'Refine',back:'intent',cards:[['Your intent',intent],['Suggested wording',suggested,{hero:true}]],primary:['Use this wording','appliedIntent'],secondary:[['Keep my intent','intent']]},
 {k:'appliedIntent',title:'Your wording',back:'resultIntent',cards:[['Prepared message',suggested]],primary:['Save','saved'],secondary:[['Undo','intent']]},
 {k:'consentVoice',title:'Review online',back:'voiceEditedFilled',sub:'Only the text below will be shared',cards:[['Your wording','I’ve done most of the slides. Could you share the work before Friday?']],primary:['Send for feedback','resultVoice']},
 {k:'resultVoice',title:'Find your words',nav:'Refine',back:'voiceEditedFilled',cards:[['Suggested wording',suggested,{hero:true}]],primary:['Use this wording','appliedVoice'],secondary:[['Keep my wording','voiceEditedFilled']]},
 {k:'appliedVoice',title:'Your wording',back:'resultVoice',cards:[['Prepared message',suggested]],primary:['Save','saved'],secondary:[['Undo','voiceEditedFilled']]},
 {k:'discardVoiceEdited',title:'Discard your words?',back:'voiceEditedFilled',primary:['Keep editing','voiceEditedFilled'],secondary:[['Discard draft','blank']]},
 {k:'savedVoice',title:'Conversation',back:'start',sub:'Saved on this iPhone',cards:[['Prepared by you','I’ve done most of the slides. Could you share the work before Friday?',{tinted:true}]],primary:['Done','start']}
];
for(let i=0;i<defs.length;i++){
 const d=defs[i],n=remember(figma.createAutoLayout('VERTICAL'));n.name='R10 / '+d.k+' / '+d.title;n.resize(390,844);n.primaryAxisSizingMode='FIXED';n.counterAxisSizingMode='FIXED';n.fills=ice;n.cornerRadius=36;n.paddingLeft=24;n.paddingRight=24;n.paddingTop=50;n.paddingBottom=28;n.itemSpacing=16;n.clipsContent=true;page.appendChild(n);n.x=180+(i%8)*460;n.y=180+Math.floor(i/8)*950;screens[d.k]=n;
 const nav=stack(n,'Navigation',342,8,true);nav.resize(342,44);nav.primaryAxisSizingMode='FIXED';nav.counterAxisSizingMode='FIXED';nav.counterAxisAlignItems='CENTER';if(d.back)icon(nav,'back','Back',d.back);else icon(nav,'chat','Practice');txt(nav,d.nav||'CircleU',13,true,muted,240);
 const title=stack(n,'Title',342,6);txt(title,d.title,28,true);if(d.sub)txt(title,d.sub,14,false,muted);
 const body=stack(n,'Scrollable content',342,14);body.layoutSizingVertical='FILL';body.clipsContent=true;body.overflowDirection='VERTICAL';
 const content=stack(body,'Content',342,14);
 if(d.hero){const row=stack(content,'Pingu guidance',342,12,true);row.counterAxisAlignItems='CENTER';art(row,64);txt(row,'A clearer way to ask',14,true,muted,250);}
 if(d.art){art(content,d.art);content.counterAxisAlignItems='CENTER';}
 if(d.wave){const wave=stack(content,'Recording waveform',342,7,true);wave.resize(342,70);wave.primaryAxisSizingMode='FIXED';wave.counterAxisSizingMode='FIXED';wave.primaryAxisAlignItems='CENTER';wave.counterAxisAlignItems='CENTER';for(const h of [12,22,35,52,30,64,40,24,55,38,18,28,12]){const r=remember(figma.createRectangle());r.resize(6,h);r.cornerRadius=3;r.fills=solid(blue);wave.appendChild(r);}}
 for(const c of d.cards||[])panel(content,...c);
 if(d.mic){const r=stack(content,'Input tools',342,8,true);icon(r,'mic','Record your words',d.mic);txt(r,'Record your words',14,true,blue,270);}
 if(d.tools){const r=stack(content,'Message tools',342,8,true);for(const a of d.tools)icon(r,...a);}
 const footer=stack(n,'Pinned actions',342,8);if(d.primary)button(footer,...d.primary,true);for(const a of d.secondary||[])button(footer,...a,false);
 controls[d.k]={bodyId:body.id,footerId:footer.id};
}
for(const l of links){if(!screens[l.target])throw Error('Missing '+l.target);await l.node.setReactionsAsync([{trigger:{type:'ON_CLICK'},actions:[{type:'NODE',destinationId:screens[l.target].id,navigation:'NAVIGATE',transition:null,resetScrollPosition:true}]}]);}
for(const d of defs.filter(x=>x.timer))await screens[d.k].setReactionsAsync([{trigger:{type:'AFTER_TIMEOUT',timeout:1.2},actions:[{type:'NODE',destinationId:screens[d.timer].id,navigation:'NAVIGATE',transition:null}]}]);
page.flowStartingPoints=[['start','01 · Practice full route'],['refineA','02 · Refine A — suggested wording'],['refineB','03 · Refine B — comparison'],['voiceReady','04 · Voice input'],['feedbackError','05 · Feedback failure'],['voiceDenied','06 · Microphone denied'],['voiceError','07 · Transcription failure'],['saveError','08 · Save failure'],['copyError','09 · Copy failure'],['blankError','10 · Empty validation']].map(([k,name])=>({nodeId:screens[k].id,name}));
const note=stack(page,'Review notes',1080,12);note.x=180;note.y=-650;txt(note,'CircleU / Practice review 10',32,true,ink,1080);txt(note,'Editable design study • 390 × 844 • Plus Jakarta Sans • Original and review 09 preserved',17,false,muted,1080);txt(note,'Preset states only: tap wording or reply fields to populate invented text. Recording, clipboard, feedback and storage are simulated. Nothing is recorded, copied, sent or saved by these Figma screens.',17,false,muted,1080);txt(note,'Review A against B using the flow selector. Primary route: prepare → refine → use → save → add their reply → prepare next → refine → save. Separate starts cover failures. Native accessibility, real typing and live AI remain outside this review.',17,false,muted,1080);
const texts=page.findAllWithCriteria({types:['TEXT']});
return {pageId:page.id,createdNodeIds:ids,screenIds:Object.fromEntries(Object.entries(screens).map(([k,n])=>[k,n.id])),screenCount:defs.length,linkCount:links.length+defs.filter(d=>d.timer).length,controls,fontFamilies:[...new Set(texts.map(t=>t.fontName.family))],textCount:texts.length,startingPoints:page.flowStartingPoints};
