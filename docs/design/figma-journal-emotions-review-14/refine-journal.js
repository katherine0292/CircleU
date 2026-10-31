// Inject STATE from review 13 state-map.json. Run once against its known page.
const p=await figma.getNodeByIdAsync('74:2');await figma.setCurrentPageAsync(p);
await Promise.all(['Regular','SemiBold','Bold'].map(style=>figma.loadFontAsync({family:'Plus Jakarta Sans',style})));
const changed=new Set(),created=[],v={},portrait={},contexts=['Study','Work','Friends','Family'],feelings=['Calm','Worried','Overloaded','Happy','Sad','Frustrated'],labels=[...contexts,...feelings];
const mark=n=>(changed.add(n.id),n),fresh=n=>(created.push(n.id),n);
const portraitIDs={Calm:'94:437',Worried:'94:440',Overloaded:'94:443',Happy:'94:446',Sad:'94:449',Frustrated:'94:452'};
for(const[k,id]of Object.entries(portraitIDs))portrait[k]=await figma.getNodeByIdAsync(id);
for(const[k,x]of Object.entries(STATE.variables))v[k]=await figma.variables.getVariableByIdAsync(x.id);
const collection=await figma.variables.getVariableCollectionByIdAsync(STATE.collectionId);
function add(name,value){const variable=figma.variables.createVariable(name,collection,'BOOLEAN');variable.scopes=['ALL_SCOPES'];variable.setValueForMode(collection.defaultModeId,value);v[name]=variable;}
for(let e=0;e<4;e++){for(const f of feelings.slice(3))add('entry'+e+'/'+f,false);add('entry'+e+'/noFeeling',e===0||e===3);add('entry'+e+'/noContext',e===0||e===1);}
for(const f of feelings.slice(3))add('draft/'+f,false);
const ref=k=>({type:'VARIABLE_ALIAS',resolvedType:v[k].resolvedType,value:{type:'VARIABLE_ALIAS',id:v[k].id}}),lit=value=>({type:'BOOLEAN',resolvedType:'BOOLEAN',value}),set=(k,value)=>({type:'SET_VARIABLE',variableId:v[k].id,variableValue:value});
const nav=id=>({type:'NODE',destinationId:id,navigation:'NAVIGATE',transition:null,resetScrollPosition:true});
const open=e=>[...labels.map(l=>set('draft/'+l,ref('entry'+e+'/'+l))),nav(STATE.pickers[e])];
async function click(n,actions){await n.setReactionsAsync([{trigger:{type:'ON_CLICK'},actions}]);mark(n);}
function walk(n){return[n,...(n.type!=='INSTANCE'&&'children'in n?n.children.flatMap(walk):[])];}
function box(parent,name,width,horizontal=false){const n=fresh(figma.createAutoLayout(horizontal?'HORIZONTAL':'VERTICAL'));n.name=name;n.resize(width,44);n.fills=[];n.primaryAxisSizingMode=horizontal?'FIXED':'AUTO';n.counterAxisSizingMode=horizontal?'AUTO':'FIXED';n.itemSpacing=6;parent.appendChild(n);return n;}
function txt(parent,value,size,width,bold=false){const n=fresh(figma.createText());n.fontName={family:'Plus Jakarta Sans',style:bold?'SemiBold':'Regular'};n.characters=value;n.fontSize=size;n.lineHeight={unit:'PERCENT',value:135};n.fills=[{type:'SOLID',color:{r:.051,g:.078,b:.129}}];n.textAutoResize='HEIGHT';n.resize(width,20);parent.appendChild(n);n.layoutSizingVertical='HUG';return n;}
const entryByWord=Object.fromEntries([0,1,2,3].map(e=>[v['entry'+e+'/words'].id,e]));
const roots=p.children.filter(n=>n.type==='FRAME');
let rows=0;
for(const root of roots){const nodes=walk(root);for(const row of nodes.filter(n=>n.type==='FRAME'&&n.name==='Compact entry tags')){
 const oldChildren=[...row.children];const bound=oldChildren.find(n=>n.boundVariables?.visible)?.boundVariables.visible.id;
 let e=[0,1,2,3].find(e=>labels.some(l=>v['entry'+e+'/'+l]?.id===bound));
 if(e===undefined){const t=walk(row.parent).find(n=>n.type==='TEXT'&&n.boundVariables?.characters&&entryByWord[n.boundVariables.characters.id]!==undefined);e=t?entryByWord[t.boundVariables.characters.id]:undefined;}
 if(e===undefined)throw Error('Cannot identify entry '+row.id);
 for(const n of oldChildren)n.remove();row.name='Context and feeling';row.itemSpacing=0;row.resize(row.width,44);row.counterAxisSizingMode='FIXED';row.counterAxisAlignItems='CENTER';mark(row);
 const left=box(row,'Conversation context',130,true);left.resize(130,44);left.counterAxisSizingMode='FIXED';left.counterAxisAlignItems='CENTER';
 for(const label of contexts){const target=box(left,label+' context',label.length*8+46,true);target.resize(label.length*8+46,44);target.counterAxisSizingMode='FIXED';target.counterAxisAlignItems='CENTER';target.setBoundVariable('visible',v['entry'+e+'/'+label]);const source=await figma.getNodeByIdAsync(STATE.chips[label]);target.appendChild(fresh(source.createInstance()));await click(target,open(e));}
 const addContext=box(left,'Choose context',104,true);addContext.resize(104,44);addContext.counterAxisSizingMode='FIXED';addContext.counterAxisAlignItems='CENTER';txt(addContext,'+ Context',12,100).opacity=.65;addContext.setBoundVariable('visible',v['entry'+e+'/noContext']);await click(addContext,open(e));
 const spacer=box(row,'Flexible gap',8,true);spacer.layoutSizingHorizontal='FILL';
 const right=box(row,'Feeling',130,true);right.resize(130,44);right.counterAxisSizingMode='FIXED';right.counterAxisAlignItems='CENTER';right.primaryAxisAlignItems='MAX';
 for(const label of feelings){const target=box(right,label+' feeling',label.length*6.7+44,true);target.resize(label.length*6.7+44,44);target.counterAxisSizingMode='FIXED';target.counterAxisAlignItems='CENTER';target.itemSpacing=5;target.setBoundVariable('visible',v['entry'+e+'/'+label]);const art=fresh(portrait[label].createInstance());target.appendChild(art);art.rescale(.1);txt(target,label,12,label.length*6.7+3);await click(target,open(e));}
 const addFeeling=box(right,'Choose feeling',90,true);addFeeling.resize(90,44);addFeeling.counterAxisSizingMode='FIXED';addFeeling.counterAxisAlignItems='CENTER';txt(addFeeling,'+ Feeling',12,86).opacity=.65;addFeeling.setBoundVariable('visible',v['entry'+e+'/noFeeling']);await click(addFeeling,open(e));rows++;
 }
 // Date grouping applies to the history list, not the already dated calendar/detail.
 const lists=walk(root).filter(n=>n.type==='FRAME'&&n.name==='Content'&&n.children.some(c=>c.name.startsWith('Entry / ')));
 for(const list of lists){let previous='';const isCalendar=root.name.includes('calendar');for(const card of [...list.children].filter(n=>n.name.startsWith('Entry / '))){const date=card.name.split(' / ')[1];const read=card.children.find(n=>n.name==='Read entry');if(!read)continue;const stamp=read.children.find(n=>n.type==='TEXT');if(stamp){stamp.characters=stamp.characters.split(' · ')[1]||stamp.characters;stamp.fontSize=12;stamp.opacity=.65;mark(stamp);}if(!isCalendar&&date!==previous){const heading=txt(list,date,14,342,true);heading.name='Date group / '+date;list.insertChild(list.children.indexOf(card),heading);previous=date;}card.paddingTop=12;card.paddingBottom=10;card.itemSpacing=6;card.cornerRadius=20;mark(card);}
 list.itemSpacing=10;mark(list);
 }
 const emptyAction=root.children.find(n=>n.name==='Pinned action'&&n.type==='FRAME'&&n.children.length===0);if(emptyAction){emptyAction.visible=false;mark(emptyAction);}
}
for(let e=0;e<4;e++){
 const picker=await figma.getNodeByIdAsync(STATE.pickers[e]);const body=picker.children.find(n=>n.name==='Scrollable content').children[0];const heading=body.children.find(n=>n.type==='TEXT'&&n.characters==='Activity');heading.characters='Conversation context';mark(heading);
 const activity=body.children.find(n=>n.name==='Activity choices');for(const row of activity.children)for(const choice of row.children){choice.resize(choice.width,80);mark(choice);const art=choice.children.find(n=>n.type==='RECTANGLE');if(art){art.resize(40,40);mark(art);}const label=contexts.find(l=>l===choice.name);await click(choice,[{type:'CONDITIONAL',conditionalBlocks:[{condition:ref('draft/'+label),actions:[set('draft/'+label,lit(false))]},{actions:contexts.map(l=>set('draft/'+l,lit(l===label)))}]}]);}
 const old=body.children.find(n=>n.name==='Feeling · optional choices');const at=body.children.indexOf(old);old.remove();const grid=box(body,'Feeling portraits',342);body.insertChild(at,grid);grid.itemSpacing=8;
 for(let r=0;r<2;r++){const row=box(grid,'Emotion choices',342,true);row.itemSpacing=9;for(const label of feelings.slice(r*3,r*3+3)){const choice=box(row,label,108);choice.resize(108,92);choice.primaryAxisSizingMode='FIXED';choice.counterAxisSizingMode='FIXED';choice.primaryAxisAlignItems='CENTER';choice.counterAxisAlignItems='CENTER';choice.fills=[{type:'SOLID',color:{r:1,g:1,b:1}}];choice.cornerRadius=20;const art=fresh(portrait[label].createInstance());choice.appendChild(art);art.rescale(56/360);const text=txt(choice,label,12,98);text.textAlignHorizontal='CENTER';const check=fresh(figma.createNodeFromSvg('<svg width="14" height="14" viewBox="0 0 16 16" xmlns="http://www.w3.org/2000/svg"><path d="M3 8l3 3 7-7" stroke="#054FC9" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" fill="none"/></svg>'));choice.appendChild(check);check.layoutPositioning='ABSOLUTE';check.x=87;check.y=8;check.setBoundVariable('visible',v['draft/'+label]);await click(choice,[{type:'CONDITIONAL',conditionalBlocks:[{condition:ref('draft/'+label),actions:[set('draft/'+label,lit(false))]},{actions:feelings.map(l=>set('draft/'+l,lit(l===label)))}]}]);}}
 const done=picker.children.find(n=>n.name==='Pinned action').children[0];const actions=labels.map(l=>set('entry'+e+'/'+l,ref('draft/'+l)));
 for(const[group,key]of [[labels,'empty'],[contexts,'noContext'],[feelings,'noFeeling']]){actions.push(set('entry'+e+'/'+key,lit(true)));for(const l of group)actions.push({type:'CONDITIONAL',conditionalBlocks:[{condition:ref('draft/'+l),actions:[set('entry'+e+'/'+key,lit(false))]},{actions:[]}]});}
 actions.push({type:'BACK'});await click(done,actions);
}
p.name='CircleU • connected review 14';mark(p);
return {createdNodeIds:created,mutatedNodeIds:[...changed],updatedTagRows:rows,variables:Object.fromEntries(Object.entries(v).map(([k,x])=>[k,{id:x.id,type:x.resolvedType}])),portraitIDs};
