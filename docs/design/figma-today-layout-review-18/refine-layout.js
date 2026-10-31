// One-time applied Figma layout correction; see result.json before reuse.
const page=await figma.getNodeByIdAsync('74:2');await figma.setCurrentPageAsync(page);
await Promise.all(['Regular','SemiBold','Bold'].map(style=>figma.loadFontAsync({family:'Plus Jakarta Sans',style})));
const created=[],changed=new Set();const mark=n=>(changed.add(n.id),n);
const sourceText=await figma.getNodeByIdAsync('74:49');
const primary=await figma.getNodeByIdAsync('74:51');const blue=primary.fills;
const pale=(await figma.getNodeByIdAsync('74:10')).fills;
function box(parent,name,width,height,horizontal=false){const n=figma.createAutoLayout(horizontal?'HORIZONTAL':'VERTICAL');parent.appendChild(n);n.name=name;n.resize(width,height);n.primaryAxisSizingMode='FIXED';n.counterAxisSizingMode='FIXED';n.fills=[];created.push(n.id);return n;}
function text(parent,value,width,size=14,bold=false){const t=sourceText.clone();parent.appendChild(t);t.characters=value;t.name=value;t.fontName={family:'Plus Jakarta Sans',style:bold?'SemiBold':'Regular'};t.fontSize=size;t.textAutoResize='HEIGHT';t.resize(width,20);created.push(t.id);return t;}
const symbols={};let sx=Math.max(...page.children.filter(n=>'width'in n).map(n=>n.x+n.width))+120;
for(const [kind,id] of [['mic','74:12'],['stop','74:73']]){const source=await figma.getNodeByIdAsync(id),c=source.mainComponent.clone();page.appendChild(c);c.name='Review18 / '+kind+' centred';c.x=sx;c.y=180;sx+=80;c.resize(44,44);const v=c.findOne(n=>n.type==='VECTOR');v.resize(kind==='mic'?14:16,kind==='mic'?24:16);v.x=(44-v.width)/2;v.y=(44-v.height)/2;v.strokeWeight=1.8;symbols[kind]=c;created.push(c.id,...c.findAll(()=>true).map(n=>n.id));}
const frames=['74:3','74:35','74:64','74:90','74:119','74:150'];const geometry=[];
for(const id of frames){
 const root=await figma.getNodeByIdAsync(id),body=root.findOne(n=>n.name==='Scrollable content'),content=body.children[0];
 const hero=root.findOne(n=>n.name==='Pingu capture scene'),art=hero.children.find(n=>n.type==='RECTANGLE'),mic=hero.children.find(n=>n.type==='INSTANCE');
 const editor=root.findOne(n=>n.name==='Your words'),prompts=root.findOne(n=>n.name==='Writing prompts'),nudge=root.findOne(n=>n.name==='Pingu nudge');
 const error=root.findOne(n=>n.type==='TEXT'&&(/Couldn’t save your words|Microphone unavailable/.test(n.characters)));
 const listening=id==='74:64',busy=id==='74:90',unavailable=id==='74:150';
 const inputActions=editor.reactions.map(r=>({trigger:r.trigger,actions:r.actions||[r.action]}));
 const micActions=mic.reactions.map(r=>({trigger:r.trigger,actions:r.actions||[r.action]}));
 const inputChildren=[...editor.children];
 editor.resize(342,310);editor.primaryAxisSizingMode='FIXED';editor.counterAxisSizingMode='FIXED';editor.paddingLeft=18;editor.paddingRight=18;editor.paddingTop=18;editor.paddingBottom=18;editor.itemSpacing=12;editor.cornerRadius=24;
 await editor.setReactionsAsync([]);mark(editor);
 const input=box(editor,'Writing field',306,162);input.clipsContent=true;await input.setReactionsAsync(inputActions);
 for(const n of inputChildren){input.appendChild(n);if(n.type==='INSTANCE'){n.visible=false;}mark(n);}
 if(!inputChildren.some(n=>n.type==='TEXT')){const t=text(input,'Write what happened…',306,17);t.opacity=.65;}
 let middle;
 if(error){middle=box(editor,'Capture status',306,44,true);middle.counterAxisAlignItems='CENTER';middle.appendChild(error);error.resize(306,error.height);error.fontSize=14;mark(error);if(prompts){prompts.visible=false;mark(prompts);}if(nudge){nudge.visible=false;mark(nudge);}const old=content.children.find(n=>n.name==='Status');if(old){old.visible=false;mark(old);}}
 else if(prompts){editor.appendChild(prompts);prompts.resize(306,44);prompts.primaryAxisSizingMode='FIXED';prompts.counterAxisSizingMode='FIXED';prompts.itemSpacing=8;middle=prompts;mark(prompts);for(const p of prompts.children){p.resize(149,44);p.primaryAxisSizingMode='FIXED';p.counterAxisSizingMode='FIXED';p.fills=pale;mark(p);const label=p.findOne(n=>n.type==='TEXT');label.resize(133,label.height);mark(label);}}
 else if(nudge){editor.appendChild(nudge);nudge.resize(306,44);nudge.primaryAxisSizingMode='FIXED';nudge.counterAxisSizingMode='FIXED';middle=nudge;mark(nudge);for(const n of nudge.children){if(n.type==='RECTANGLE'){n.visible=false;}else if(n.type==='TEXT'){n.resize(306,n.height);}mark(n);}}
 else {middle=box(editor,'Dictation status',306,44,true);middle.counterAxisAlignItems='CENTER';text(middle,'Listening…',306,14);}
 const toolbar=box(editor,'Writing controls',306,44,true);toolbar.primaryAxisAlignItems='MAX';toolbar.counterAxisAlignItems='CENTER';
 const voice=box(toolbar,listening?'Stop dictation control':'Speak control',112,44,true);voice.counterAxisAlignItems='CENTER';voice.itemSpacing=0;voice.cornerRadius=16;voice.strokes=pale;voice.strokeWeight=1;
 voice.appendChild(mic);mic.swapComponent(symbols[listening?'stop':'mic']);mic.resize(44,44);mic.fills=[];mic.cornerRadius=14;
 mark(mic);
 const label=text(voice,listening?'Stop':'Speak',60,14,true);label.fills=blue;
 if(busy||unavailable){voice.opacity=.4;await mic.setReactionsAsync([]);await voice.setReactionsAsync([]);}else await voice.setReactionsAsync(micActions);
 // The full-width illustration has its natural 2:1 ratio; no control floats over the art.
 hero.resize(342,171);hero.primaryAxisSizingMode='FIXED';hero.counterAxisSizingMode='FIXED';hero.paddingLeft=0;hero.paddingRight=0;hero.paddingTop=0;hero.paddingBottom=0;hero.itemSpacing=0;hero.cornerRadius=24;hero.clipsContent=true;hero.fills=[];
 art.resize(342,171);art.fills=[{type:'IMAGE',imageHash:listening?'08eed5e99fe706366c522588900219f37f7867f8':'e486645bf7fa13c5fd1ed7c597bfcdaf4d047417',scaleMode:'FIT'}];art.name=listening?'Scene / Voice corner':'Scene / Window pause';mark(art);mark(hero);
 // Preserve layout order and fixed footer positions across every capture state.
 content.insertChild(0,hero);content.insertChild(1,editor);content.itemSpacing=14;mark(content);
 geometry.push({frame:id,hero:hero.id,composer:editor.id,input:input.id,microphone:mic.id,voiceControl:voice.id,toolbar:toolbar.id,tab:root.children.find(n=>n.name==='Tab bar').id});
}
page.name='CircleU • connected review 18';mark(page);
return {createdNodeIds:created,mutatedNodeIds:[...changed],geometry};
