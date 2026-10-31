// Inject SOURCE_MAP and STATE_MAP from the adjacent JSON files before executing.
const page=await figma.getNodeByIdAsync('74:2');await figma.setCurrentPageAsync(page);
await Promise.all(['Regular','SemiBold','Bold'].map(style=>figma.loadFontAsync({family:'Plus Jakarta Sans',style})));
const affected=new Set(),created=[],roots=[],vars={},chips={};
const mark=n=>(affected.add(n.id),n),fresh=n=>(created.push(n.id),n);
for(const item of SOURCE_MAP)roots.push(await figma.getNodeByIdAsync(item.id));
for(const [key,v]of Object.entries(STATE_MAP.variables))vars[key]=await figma.variables.getVariableByIdAsync(v.id);
for(const [key,id]of Object.entries(STATE_MAP.chips))chips[key]=await figma.getNodeByIdAsync(id);
function walk(n){const out=[n];if(n.type!=='INSTANCE'&&'children'in n)for(const c of n.children)out.push(...walk(c));return out;}
const nav=id=>({type:'NODE',destinationId:id,navigation:'NAVIGATE',transition:null,resetScrollPosition:true});
const lit=(type,value)=>({type,resolvedType:type,value});
const ref=k=>({type:'VARIABLE_ALIAS',resolvedType:vars[k].resolvedType,value:{type:'VARIABLE_ALIAS',id:vars[k].id}});
const set=(k,v)=>({type:'SET_VARIABLE',variableId:vars[k].id,variableValue:v});
const bool=(k,v)=>set(k,lit('BOOLEAN',v));
const eq=(k,v)=>({type:'EXPRESSION',resolvedType:'BOOLEAN',value:{expressionFunction:'EQUALS',expressionArguments:[ref(k),lit('FLOAT',v)]}});
const conditional=(condition,yes,no)=>({type:'CONDITIONAL',conditionalBlocks:[{condition,actions:yes},{actions:no}]});
async function click(n,actions){await n.setReactionsAsync([{trigger:{type:'ON_CLICK'},actions:actions.flat()}]);mark(n);}
const labels=Object.keys(chips),entryIDs=['74:775','74:825','74:848','74:871'];
const words=['My groupmate missed the deadline again. I froze in the meeting.','A quiet walk helped me slow down before the group meeting.','I said no to the extra shift and felt okay about it.','Talked with my sister about our holiday plans.'];
const dates=['31 Oct · 09:40','31 Oct · 08:15','29 Oct · 18:12','27 Oct · 20:05'];
const edits=['My groupmate missed the deadline. I want to agree on a fairer split of the work.','A quiet walk helped me slow down. I felt ready for the group meeting.','I said no to the extra shift. I needed time to rest.','Talked with my sister about our holiday plans. We agreed to decide together.'];
function box(parent,name,width,horizontal=false){const n=fresh(figma.createAutoLayout(horizontal?'HORIZONTAL':'VERTICAL'));n.name=name;n.resize(width,44);n.primaryAxisSizingMode=horizontal?'FIXED':'AUTO';n.counterAxisSizingMode=horizontal?'AUTO':'FIXED';n.fills=[];n.itemSpacing=8;parent.appendChild(n);return n;}
function text(parent,content,size,width,bold=false){const t=fresh(figma.createText());t.fontName={family:'Plus Jakarta Sans',style:bold?'SemiBold':'Regular'};t.characters=content;t.fontSize=size;t.lineHeight={unit:'PERCENT',value:135};t.fills=[{type:'SOLID',color:{r:.07,g:.12,b:.2}}];t.textAutoResize='HEIGHT';t.resize(width,24);parent.appendChild(t);t.layoutSizingVertical='HUG';return t;}
const openTags=e=>[...labels.map(l=>set('draft/'+l,ref('entry'+e+'/'+l))),nav(STATE_MAP.pickers[e])];
async function tags(parent,e,width){const row=box(parent,'Compact entry tags',width,true);row.resize(width,44);row.counterAxisSizingMode='FIXED';row.counterAxisAlignItems='CENTER';row.itemSpacing=6;
 for(const label of labels){const target=box(row,label+' · edit tags',chips[label].width,true);target.resize(chips[label].width,44);target.counterAxisSizingMode='FIXED';target.counterAxisAlignItems='CENTER';target.setBoundVariable('visible',vars['entry'+e+'/'+label]);const chip=fresh(chips[label].createInstance());target.appendChild(chip);await click(target,openTags(e));}
 const add=box(row,'Add tag',86,true);add.resize(86,44);add.counterAxisSizingMode='FIXED';add.counterAxisAlignItems='CENTER';add.setBoundVariable('visible',vars['entry'+e+'/empty']);const label=text(add,'+ Add tag',12,82);label.fills=[{type:'SOLID',color:{r:.2,g:.39,b:.65}}];await click(add,openTags(e));return row;
}
const originFrames=[];
for(const [ri,root]of roots.entries()){
 for(const n of walk(root)){if(n.type==='TEXT'&&typeof n.fontSize==='number'&&n.fontSize>24){n.fontSize=24;mark(n);}}
 const cards=walk(root).filter(n=>n.type==='FRAME'&&n.name.startsWith('Entry / '));
 if(cards.length)originFrames.push({index:ri,id:root.id});
 for(const card of cards){const all=walk(card),wordNode=all.find(n=>n.type==='TEXT'&&(words.includes(n.characters)||edits.includes(n.characters)));if(!wordNode)continue;const e=Math.max(words.indexOf(wordNode.characters),edits.indexOf(wordNode.characters));
  for(const child of [...card.children])child.remove();card.layoutMode='VERTICAL';card.primaryAxisSizingMode='AUTO';card.counterAxisSizingMode='FIXED';card.itemSpacing=4;card.paddingLeft=14;card.paddingRight=14;card.paddingTop=12;card.paddingBottom=8;card.cornerRadius=18;card.resize(342,120);card.primaryAxisSizingMode='AUTO';await card.setReactionsAsync([]);mark(card);
  if(e===0)card.setBoundVariable('visible',vars.newEntrySaved);
  const reading=box(card,'Read entry',314);reading.itemSpacing=7;const date=text(reading,dates[e],12,314,true);date.opacity=.65;const t=text(reading,words[e],16,314);t.setBoundVariable('characters',vars['entry'+e+'/words']);await click(reading,[set('entryReturn',lit('FLOAT',ri)),nav(entryIDs[e])]);await tags(card,e,314);
 }
}
const backEntry=originFrames.map(f=>({type:'CONDITIONAL',conditionalBlocks:[{condition:eq('entryReturn',f.index),actions:[nav(f.id)]},{actions:[]}]}));
for(const [e,id]of entryIDs.entries()){
 const root=await figma.getNodeByIdAsync(id),all=walk(root),original=all.find(n=>n.name==='Original words'),t=walk(original).find(n=>n.type==='TEXT');t.fontSize=17;t.setBoundVariable('characters',vars['entry'+e+'/words']);mark(t);await tags(original,e,306);
 await click(all.find(n=>n.type==='INSTANCE'&&n.name==='Back'),[backEntry]);
 const edit=e===0?await figma.getNodeByIdAsync('74:894'):fresh((await figma.getNodeByIdAsync('74:894')).clone());
 const discard=e===0?await figma.getNodeByIdAsync('74:916'):fresh((await figma.getNodeByIdAsync('74:916')).clone());
 if(e){page.appendChild(edit);page.appendChild(discard);edit.name='R13 / edit'+e+' / Edit entry';discard.name='R13 / discardEdit'+e+' / Discard changes?';edit.x=180+e*460;edit.y=13600;discard.x=180+e*460;discard.y=14500;roots.push(edit,discard);walk(edit).forEach(mark);walk(discard).forEach(mark);}
 const editAll=walk(edit),editText=editAll.find(n=>n.type==='TEXT'&&n.parent.name==='Your words');editText.characters=edits[e];mark(editText);
 await click(editAll.find(n=>n.name==='Save changes'),[set('entry'+e+'/words',lit('STRING',edits[e])),nav(id)]);
 await click(editAll.find(n=>n.type==='INSTANCE'&&n.name==='Back'),[nav(discard.id)]);
 for(const n of walk(discard)){if(n.name==='Keep editing'||n.type==='INSTANCE'&&n.name==='Back')await click(n,[nav(edit.id)]);if(n.name==='Discard changes')await click(n,[nav(id)]);}
 let editButton=all.find(n=>n.type==='INSTANCE'&&n.name==='Edit entry');if(!editButton){editButton=fresh((await figma.getNodeByIdAsync('74:779')).clone());root.children[0].appendChild(editButton);const dateTitle=root.children[0].children.find(n=>n.type==='TEXT');dateTitle.resize(234,dateTitle.height);mark(dateTitle);}
 await click(editButton,[nav(edit.id)]);
}
// Save state is updated only at the successful transition, never on failure.
const resumeTargets=['74:4929','74:4997','74:5494','74:5512','74:5528','74:5126','74:5544','74:5686'];
for(const root of roots)for(const n of walk(root))if('reactions'in n&&n.reactions.length){let changed=false;const reactions=n.reactions.map(r=>({trigger:r.trigger,actions:(r.actions||[r.action]).flatMap(a=>{if(a.type==='URL'){changed=true;return [nav('74:4705')];}if(a.type!=='NODE')return[a];const d=a.destinationId;
 if(d==='74:35'&&['74:3','74:150'].includes(root.id)){changed=true;return[bool('todayDraft',true),a];}
 if(d==='74:264'&&root.id==='74:90'){changed=true;return[bool('newEntrySaved',true),bool('todayDraft',false),set('day31Count',lit('STRING','2 entries')),a];}
 if(d==='74:991'){changed=true;return[bool('reflectionSaved',true),a];}
 if(resumeTargets.includes(d)&&!['Back','Practice'].includes(n.name)){changed=true;return[bool('practiceHasHistory',true),bool('practiceDraft',false),set('practiceResume',lit('FLOAT',resumeTargets.indexOf(d))),a];}
 if(d==='74:5392'){changed=true;return[bool('practiceDraft',true),a];}
 return[a];})}));if(changed){await n.setReactionsAsync(reactions);mark(n);}}
await click(await figma.getNodeByIdAsync('74:196'),[bool('todayDraft',false),nav('74:210')]);
const expression=(fn,args)=>({type:'EXPRESSION',resolvedType:'BOOLEAN',value:{expressionFunction:fn,expressionArguments:args}});
const practiceHome=[conditional(ref('practiceHasHistory'),[nav('74:5702')],[]),conditional(expression('AND',[expression('NOT',[ref('practiceHasHistory')]),ref('practiceDraft')]),[nav('74:5392')],[]),conditional(expression('AND',[expression('NOT',[ref('practiceHasHistory')]),expression('NOT',[ref('practiceDraft')])]),[nav('74:4705')],[])];
const todayHome=conditional(ref('todayDraft'),[nav('74:35')],[nav('74:3')]);
const journalHome=conditional(ref('todayDraft'),[nav('74:325')],[nav('74:210')]);
for(const root of roots){let tab=root.children.find(n=>n.name==='Tab bar');if(['74:4705','74:5392','74:5702'].includes(root.id)){
 tab=fresh((await figma.getNodeByIdAsync('74:252')).clone());root.appendChild(tab);walk(tab).forEach(mark);root.paddingBottom=20;root.itemSpacing=12;
 const navigation=root.children.find(n=>n.name==='Navigation');if(navigation){navigation.visible=false;mark(navigation);}const heading=root.children.find(n=>n.name==='Title');if(heading)heading.children[0].fontSize=24;
 for(const item of tab.children){item.fills=item.name==='Practice'?[{type:'SOLID',color:{r:.88,g:.94,b:1}}]:[];mark(item);}
 }
 if(tab)for(const item of tab.children)await click(item,[item.name==='Today'?todayHome:item.name==='Journal'?journalHome:practiceHome]);
}
const resume=resumeTargets.map((id,i)=>conditional(eq('practiceResume',i),[nav(id)],[]));
for(const id of ['74:4717','74:5714']){const n=await figma.getNodeByIdAsync(id);n.setBoundVariable('visible',vars.practiceHasHistory);await click(n,[resume]);}
// All original Practice back-to-home routes now respect saved history.
for(const root of roots.filter(r=>r.id.startsWith('74:')&&SOURCE_MAP.find(x=>x.id===r.id)?.oldId.startsWith('51:')))for(const n of walk(root))if(n.type==='INSTANCE'&&n.name==='Practice')await click(n,[practiceHome]);
for(const root of roots){for(const n of walk(root)){if(n.type==='TEXT'&&n.characters==='2 entries'&&root.name.includes('calendar31')){n.setBoundVariable('characters',vars.day31Count);mark(n);}}}
// Avoid presenting stale, separate edited-entry states: route them to the bound entry.
for(const root of roots)for(const n of walk(root))if('reactions'in n&&n.reactions.length){let changed=false;const rr=n.reactions.map(r=>({trigger:r.trigger,actions:(r.actions||[r.action]).map(a=>{if(a.type==='NODE'&&a.destinationId==='74:800'){changed=true;return nav('74:775');}return a;})}));if(changed){await n.setReactionsAsync(rr);mark(n);}}
page.flowStartingPoints=[{nodeId:'74:3',name:'Start · Today → Journal → Practice'},{nodeId:'74:210',name:'Journal · tags and editing'},{nodeId:'74:4705',name:'Practice · prepare, refine, reply'}];
return {createdNodeIds:created,mutatedNodeIds:[...affected].join(' '),rootCount:roots.length,tagVisualHeight:32,tagTargetHeight:44};
