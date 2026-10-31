// One-time applied Figma mutation. Read result.json before reuse.
const page=await figma.getNodeByIdAsync('74:2');await figma.setCurrentPageAsync(page);
await Promise.all(['Regular','SemiBold'].map(style=>figma.loadFontAsync({family:'Plus Jakarta Sans',style})));
const changed=new Set(),created=[],vars=[];
const get=id=>figma.getNodeByIdAsync(id),mark=n=>(changed.add(n.id),n);
const coll=await figma.variables.getVariableCollectionByIdAsync('VariableCollectionId:79:459');
function variable(name,type,value){const v=figma.variables.createVariable(name,coll,type);v.scopes=type==='STRING'?['TEXT_CONTENT']:['ALL_SCOPES'];v.setValueForMode(coll.defaultModeId,value);vars.push({id:v.id,name});return v;}
const prompt=variable('todaySelectedQuestion','STRING','What happened?'),active=variable('todayQuestionVisible','BOOLEAN',false),label=variable('todayQuestionPickerLabel','STRING','What stayed with you?');
const set=(v,value)=>({type:'SET_VARIABLE',variableId:v.id,variableValue:{type:v.resolvedType,resolvedType:v.resolvedType,value}});
const reset=[set(active,false),set(label,'What stayed with you?')];
async function click(n,actions){await n.setReactionsAsync([{trigger:{type:'ON_CLICK'},actions}]);mark(n);}
const titleSource=await get('74:7'),bodySource=await get('74:46'),smallSource=await get('74:17'),closeSource=await get('60:16940');
const paper=(await get('74:18')).fills,pale=(await get('125:471')).fills,ink=bodySource.fills,blue=(await get('74:51')).fills;
function text(parent,value,width,size=17,bold=false){const t=bodySource.clone();parent.appendChild(t);t.name=value;t.characters=value;t.fontName={family:'Plus Jakarta Sans',style:bold?'SemiBold':'Regular'};t.fontSize=size;t.textAutoResize='HEIGHT';t.resize(width,24);created.push(t.id);return t;}
function box(parent,name,w,h,horizontal=false){const n=figma.createAutoLayout(horizontal?'HORIZONTAL':'VERTICAL');parent.appendChild(n);n.name=name;n.resize(w,h);n.primaryAxisSizingMode='FIXED';n.counterAxisSizingMode='FIXED';n.fills=[];created.push(n.id);return n;}
const edge=Math.max(...page.children.filter(n=>'width'in n).map(n=>n.x+n.width))+100;
const chevron=figma.createComponent();page.appendChild(chevron);chevron.name='Review20 / prompt chevron';chevron.resize(20,20);chevron.x=edge;chevron.y=40;chevron.fills=[];created.push(chevron.id);
const svg=figma.createNodeFromSvg('<svg width="20" height="20" viewBox="0 0 20 20" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="m5 8 5 5 5-5" stroke="#054FC9" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"/></svg>');chevron.appendChild(svg);svg.x=0;svg.y=0;created.push(svg.id,...svg.findAll(()=>true).map(n=>n.id));
const option=figma.createComponent();page.appendChild(option);option.name='Review20 / question option';option.layoutMode='HORIZONTAL';option.resize(342,64);option.primaryAxisSizingMode='FIXED';option.counterAxisSizingMode='FIXED';option.counterAxisAlignItems='CENTER';option.paddingLeft=18;option.paddingRight=18;option.cornerRadius=18;option.fills=pale;option.x=edge+80;option.y=40;created.push(option.id);text(option,'What happened?',306,16,true);
const overlay=figma.createFrame();page.appendChild(overlay);overlay.name='Review20 / Choose a question / overlay';overlay.resize(390,844);overlay.x=edge;overlay.y=180;overlay.fills=[];created.push(overlay.id);
const scrim=figma.createRectangle();overlay.appendChild(scrim);scrim.name='Dismiss question picker';scrim.resize(390,844);scrim.fills=[{type:'SOLID',color:{r:0,g:0,b:0},opacity:.24}];created.push(scrim.id);await click(scrim,[{type:'CLOSE'}]);
const sheet=box(overlay,'Question picker sheet',390,352);sheet.x=0;sheet.y=492;sheet.fills=paper;sheet.topLeftRadius=28;sheet.topRightRadius=28;sheet.paddingTop=24;sheet.paddingLeft=24;sheet.paddingRight=24;sheet.paddingBottom=36;sheet.itemSpacing=16;
const header=box(sheet,'Picker heading',342,44,true);header.itemSpacing=8;header.counterAxisAlignItems='CENTER';text(header,'Choose a question',290,22,true);const cancel=closeSource.createInstance();header.appendChild(cancel);cancel.name='Close question picker';created.push(cancel.id);await click(cancel,[{type:'CLOSE'}]);
const options=box(sheet,'Questions',342,208);options.itemSpacing=8;
const choices=[];
for(const q of ['What happened?','How did it make you feel?','What would you like to say next?']){const row=option.createInstance();options.appendChild(row);row.name=q;const t=row.findOne(n=>n.type==='TEXT');t.characters=q;created.push(row.id);await click(row,[set(prompt,q),set(active,true),set(label,'Change question'),{type:'CLOSE'}]);choices.push({question:q,id:row.id});}
const open={type:'NODE',destinationId:overlay.id,navigation:'OVERLAY',transition:null};
const selectedRows=[];
for(const [frameId,inputId,toolbarId] of [['74:3','125:467','125:470'],['74:35','125:475','125:476'],['74:64','125:481','125:484'],['74:90','125:489','125:490'],['74:119','125:494','125:496'],['74:150','125:501','125:505']]){
 const input=await get(inputId),row=box(input,'Selected question',306,44,true);input.insertChild(0,row);row.itemSpacing=8;row.counterAxisAlignItems='CENTER';row.setBoundVariable('visible',active);input.itemSpacing=12;
 const q=text(row,'What happened?',254,14,true);q.setBoundVariable('characters',prompt);q.fills=smallSource.fills;
 const dismiss=closeSource.createInstance();row.appendChild(dismiss);dismiss.name='Remove question, keep words';dismiss.fills=[];created.push(dismiss.id);await click(dismiss,frameId==='74:90'?[]:reset);mark(input);selectedRows.push({frame:frameId,row:row.id,close:dismiss.id});
 if(['74:3','74:35','74:90'].includes(frameId)){
  const toolbar=await get(toolbarId),picker=toolbar.children[0];picker.name='Choose a question';picker.resize(246,44);picker.itemSpacing=6;picker.primaryAxisAlignItems='MIN';picker.counterAxisAlignItems='CENTER';
  const t=picker.findOne(n=>n.type==='TEXT');t.characters='What stayed with you?';t.setBoundVariable('characters',label);t.resize(220,t.height);t.fontSize=14;t.textAlignHorizontal='LEFT';t.fills=blue;
  const c=chevron.createInstance();picker.appendChild(c);created.push(c.id);await click(picker,frameId==='74:90'?[]:[open]);mark(t);mark(picker);
 }
}
// Reset the optional question only when the entry is saved or its draft is discarded.
for(const id of ['74:90','74:196']){const n=await get(id);const reactions=n.reactions.map(r=>{const actions=[...(r.actions||[r.action])];const at=actions.findIndex(a=>a.type==='NODE');actions.splice(at<0?actions.length:at,0,...reset);return {trigger:r.trigger,actions};});await n.setReactionsAsync(reactions);mark(n);}
page.name='CircleU • connected review 20';mark(page);
return {createdNodeIds:created,mutatedNodeIds:[...changed],variables:vars,overlay:overlay.id,sheet:sheet.id,choices,selectedRows,componentIds:[chevron.id,option.id]};
