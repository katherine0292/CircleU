const existing=figma.root.children.find(p=>p.name==='Practice • review 09');
if(existing) return {existingPageId:existing.id,alreadyCreated:true};
const prior=await figma.getNodeByIdAsync('24:2');
const originalButton=await figma.getNodeByIdAsync('24:32');
const sourceArt=await figma.getNodeByIdAsync('1:17');
const ice=prior.fills, blue=originalButton.fills;
const page=figma.createPage(); page.name='Practice • review 09'; await figma.setCurrentPageAsync(page);
await Promise.all(['Regular','SemiBold','Bold'].map(style=>figma.loadFontAsync({family:'Plus Jakarta Sans',style})));
const ids=[page.id], wired=[], screens={};
const ink={r:13/255,g:20/255,b:33/255}, muted={r:70/255,g:93/255,b:127/255};
const white=[{type:'SOLID',color:{r:1,g:1,b:1}}];
function record(n){ids.push(n.id);return n}
function text(parent,value,size=17,bold=false,color=ink,width=342){
 const n=record(figma.createText()); n.fontName={family:'Plus Jakarta Sans',style:bold?'SemiBold':'Regular'};n.fontSize=size;n.lineHeight={unit:'PERCENT',value:140};n.fills=[{type:'SOLID',color}];n.characters=value;n.textAutoResize='HEIGHT';n.resize(width,24);parent.appendChild(n);n.layoutSizingHorizontal='FIXED';n.layoutSizingVertical='HUG';return n;
}
function stack(parent,name,width=342,gap=12){
 const n=record(figma.createAutoLayout('VERTICAL'));n.name=name;n.fills=[];n.itemSpacing=gap;n.resize(width,100);n.primaryAxisSizingMode='AUTO';n.counterAxisSizingMode='FIXED';parent.appendChild(n);return n;
}
function kitButton(name,filled){
 const n=record(figma.createComponent());n.name=name;n.layoutMode='HORIZONTAL';n.resize(342,52);n.primaryAxisSizingMode='FIXED';n.counterAxisSizingMode='FIXED';n.primaryAxisAlignItems='CENTER';n.counterAxisAlignItems='CENTER';n.cornerRadius=18;n.fills=filled?blue:white;
 const t=text(n,'Continue',17,true,filled?{r:1,g:1,b:1}:blue[0].color,310);t.textAlignHorizontal='CENTER';return n;
}
const primary=kitButton('Review09 / Primary action',true), secondary=kitButton('Review09 / Secondary action',false);
primary.x=180;primary.y=-200;secondary.x=560;secondary.y=-200;
function button(parent,label,target,filled=true){
 const n=record((filled?primary:secondary).createInstance());parent.appendChild(n);n.name=label;
 const t=n.findOne(x=>x.type==='TEXT');t.characters=label;ids.push(t.id);
 if(target)wired.push({node:n,target});return n;
}
function card(parent,label,value,target){
 const n=stack(parent,label,342,8);n.fills=white;n.cornerRadius=22;n.paddingTop=16;n.paddingBottom=16;n.paddingLeft=16;n.paddingRight=16;
 text(n,label,13,true,muted,310);text(n,value,17,false,ink,310);if(target)wired.push({node:n,target});return n;
}
const original='You left most of the slides to me. Can we split the work fairly?';
const rewrite='Could we agree on which slides each of us will finish by Friday?';
const edited='Could we split the remaining slides and agree on a time to finish them?';
const intent='Agree on a fair split of the slides';
const defs=[
{k:'start',title:'Practice',art:true,cards:[['Your conversations','Prepare words that feel right to you']],primary:['Practice a message','blank'],secondary:[['Open conversation','saved']]},
{k:'blank',title:'What would you like to say?',back:'start',cards:[['Your wording','Tap here to add your words','filled']],secondary:[['Help me get started','guide']]},
{k:'filled',title:'What would you like to say?',back:'discard',cards:[['Your wording',original]],primary:['Review wording','consent'],secondary:[['Save without feedback','savedOriginal']]},
{k:'guide',title:'What do you want to happen?',back:'blank',cards:[['Your intent',intent]],primary:['Continue','intent']},
{k:'intent',title:'What would you like to say?',back:'blank',cards:[['Your intent',intent]],primary:['Review wording','consentIntent'],secondary:[['Edit intent','guide'],['Clear intent','blank']]},
{k:'consent',title:'Review selected text',back:'filled',cards:[['Your wording',original],['Sharing','Only this text is selected. Nothing else is included.']],primary:['Send for feedback','loading']},
{k:'consentIntent',title:'Review selected text',back:'intent',cards:[['Your intent',intent],['Sharing','Only this intent is selected. Nothing else is included.']],primary:['Send for feedback','loadingIntent']},
{k:'loading',title:'Reviewing your wording',back:'filled',art:true,cards:[['Your wording',original]],secondary:[['Cancel','filled']]},
{k:'loadingIntent',title:'Preparing wording',back:'intent',art:true,cards:[['Your intent',intent]],secondary:[['Cancel','intent']]},
{k:'result',title:'Find your words',back:'filled',cards:[['Your wording',original],['Try this','Name the work you need shared, then make one clear request.'],['Suggested wording',rewrite]],primary:['Use this wording','applied'],secondary:[['Keep my wording','filled']]},
{k:'resultIntent',title:'Find your words',back:'intent',cards:[['Your intent',intent],['Try this','Ask for a clear agreement on who will do what.'],['Suggested wording',rewrite]],primary:['Use this wording','appliedIntent'],secondary:[['Keep my intent','intent']]},
{k:'applied',title:'Your wording',back:'result',cards:[['Prepared message',rewrite]],primary:['Save','saved'],secondary:[['Edit wording','edited'],['Undo','filled']]},
{k:'appliedIntent',title:'Your wording',back:'resultIntent',cards:[['Prepared message',rewrite]],primary:['Save','saved'],secondary:[['Edit wording','edited'],['Undo','intent']]},
{k:'edited',title:'Your wording',back:'applied',cards:[['Prepared message',edited]],primary:['Save','savedEdited'],secondary:[['Discard edit','applied']]},
{k:'savedOriginal',title:'Conversation',back:'start',cards:[['Prepared by you',original],['Saved','Not sent to anyone']],primary:['Add their reply','replyOriginal']},
{k:'saved',title:'Conversation',back:'start',cards:[['Prepared by you',rewrite],['Saved','Not sent to anyone']],primary:['Add their reply','reply']},
{k:'savedEdited',title:'Conversation',back:'start',cards:[['Prepared by you',edited],['Saved','Not sent to anyone']],primary:['Add their reply','replyEdited']},
{k:'reply',title:'Add their reply',back:'saved',cards:[['Their reply','I can finish the research slides on Thursday.'],['More context','I need the slides ready before our Friday rehearsal.']],primary:['Save reply','conversation']},
{k:'replyOriginal',title:'Add their reply',back:'savedOriginal',cards:[['Their reply','I can finish the research slides on Thursday.'],['More context','I need the slides ready before our Friday rehearsal.']],primary:['Save reply','conversationOriginal']},
{k:'replyEdited',title:'Add their reply',back:'savedEdited',cards:[['Their reply','I can finish the research slides on Thursday.'],['More context','I need the slides ready before our Friday rehearsal.']],primary:['Save reply','conversationEdited']},
{k:'conversation',title:'Conversation',back:'start',cards:[['Prepared by you',rewrite],['Their reply','I can finish the research slides on Thursday.'],['Your context','I need the slides ready before our Friday rehearsal.']],primary:['Prepare next message','next']},
{k:'conversationOriginal',title:'Conversation',back:'start',cards:[['Prepared by you',original],['Their reply','I can finish the research slides on Thursday.'],['Your context','I need the slides ready before our Friday rehearsal.']],primary:['Prepare next message','nextOriginal']},
{k:'conversationEdited',title:'Conversation',back:'start',cards:[['Prepared by you',edited],['Their reply','I can finish the research slides on Thursday.'],['Your context','I need the slides ready before our Friday rehearsal.']],primary:['Prepare next message','nextEdited']},
{k:'next',title:'What would you like to say?',back:'conversation',cards:[['Their reply','I can finish the research slides on Thursday.'],['Your next message','Your next draft starts here']],secondary:[['Back to conversation','conversation']]},
{k:'nextOriginal',title:'What would you like to say?',back:'conversationOriginal',cards:[['Their reply','I can finish the research slides on Thursday.'],['Your next message','Your next draft starts here']],secondary:[['Back to conversation','conversationOriginal']]},
{k:'nextEdited',title:'What would you like to say?',back:'conversationEdited',cards:[['Their reply','I can finish the research slides on Thursday.'],['Your next message','Your next draft starts here']],secondary:[['Back to conversation','conversationEdited']]},
{k:'error',title:'Couldn’t get feedback',back:'filled',cards:[['Your wording',original],['Try again','Your words are still here. Try again or keep editing.']],primary:['Try again','consent'],secondary:[['Keep editing','filled']]},
{k:'discard',title:'Leave this draft?',back:'filled',cards:[['Your wording',original],['Keep editing','Keep editing, or discard these words.']],primary:['Keep editing','filled'],secondary:[['Discard draft','blank']]},
];
for(let i=0;i<defs.length;i++){
 const d=defs[i];const n=record(figma.createAutoLayout('VERTICAL'));n.name='R09 / '+d.k+' / '+d.title;
 n.resize(390,844);n.primaryAxisSizingMode='FIXED';n.counterAxisSizingMode='FIXED';n.paddingLeft=24;n.paddingRight=24;n.paddingTop=52;n.paddingBottom=24;n.itemSpacing=16;n.fills=ice;n.cornerRadius=36;n.clipsContent=true;page.appendChild(n);n.x=180+(i%7)*470;n.y=180+Math.floor(i/7)*960;screens[d.k]=n;
 const head=stack(n,'Navigation',342,0);head.resize(342,44);head.primaryAxisSizingMode='FIXED';
 if(d.back){const b=text(head,'Back',17,false,blue[0].color);b.resize(342,44);wired.push({node:b,target:d.back});}
 const h=text(n,d.title,28,true);h.name='Heading';
 const body=stack(n,'Content',342,14);body.layoutSizingVertical='FILL';
 if(d.art){const art=record(figma.createRectangle());art.name='Pingu practising';art.resize(112,112);art.fills=sourceArt.fills;body.appendChild(art);}
 for(const c of d.cards??[])card(body,...c);
 const footer=stack(n,'Actions',342,8);if(d.primary)button(footer,...d.primary,true);
 for(const a of d.secondary??[])button(footer,...a,false);
}
for(const link of wired){if(!screens[link.target])throw Error('Missing destination '+link.target);await link.node.setReactionsAsync([{trigger:{type:'ON_CLICK'},actions:[{type:'NODE',destinationId:screens[link.target].id,navigation:'NAVIGATE',transition:null,resetScrollPosition:true}]}]);}
for(const [from,to] of [['loading','result'],['loadingIntent','resultIntent']]) await screens[from].setReactionsAsync([{trigger:{type:'AFTER_TIMEOUT',timeout:1.8},actions:[{type:'NODE',destinationId:screens[to].id,navigation:'NAVIGATE',transition:null}]}]);
page.flowStartingPoints=[{nodeId:screens.start.id,name:'Practice · direct wording and replies'},{nodeId:screens.guide.id,name:'Practice · optional guidance'},{nodeId:screens.error.id,name:'Practice · failure recovery'}];
const note=stack(page,'Review scope',900,12);note.x=180;note.y=-580;
text(note,'CircleU / Practice flow review 09',32,true,ink,900);
text(note,'Fixed scenario for flow review: tap the wording area to load the example. Text entry, edits, saving and received replies are preset states. No microphone, AI request or storage runs in Figma.',17,false,muted,900);
text(note,'Check: direct wording → consent → feedback → Use → edit or Undo → Save → add their actual reply. Optional guidance and failure recovery have separate starts. The next-message screen marks the end of this slice; further reply refinement, Copy, voice and other tabs remain in the browser/native specimens.',17,false,muted,900);
return {pageId:page.id,createdNodeIds:ids,screenIds:Object.fromEntries(Object.entries(screens).map(([k,v])=>[k,v.id])),screenCount:defs.length,wiredActions:wired.length+2,font:'Plus Jakarta Sans'};
