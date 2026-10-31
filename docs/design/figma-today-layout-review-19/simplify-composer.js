await figma.setCurrentPageAsync(await figma.getNodeByIdAsync('74:2'));
await Promise.all(['Regular','SemiBold'].map(style=>figma.loadFontAsync({family:'Plus Jakarta Sans',style})));
const changed=new Set(),evidence=[];
for(const [frameId,editorId] of [['74:3','74:18'],['74:35','74:45'],['74:64','74:74'],['74:90','74:100'],['74:119','74:129'],['74:150','74:165']]){
 const root=await figma.getNodeByIdAsync(frameId),editor=await figma.getNodeByIdAsync(editorId);
 const input=editor.children.find(n=>n.name==='Writing field'),toolbar=editor.children.find(n=>n.name==='Writing controls'),middle=editor.children.find(n=>n!==input&&n!==toolbar&&n.visible);
 const voice=toolbar.children.find(n=>n.name.includes('control')),icon=voice.children.find(n=>n.type==='INSTANCE');
 const pale=voice.strokes;
 for(const t of voice.children.filter(n=>n.type==='TEXT')){t.visible=false;changed.add(t.id);}
 voice.name=frameId==='74:64'?'Stop dictation':'Record your words';
 voice.resize(44,44);voice.paddingLeft=0;voice.paddingRight=0;voice.paddingTop=0;voice.paddingBottom=0;voice.itemSpacing=0;voice.cornerRadius=22;voice.strokes=[];voice.fills=pale;
 toolbar.primaryAxisAlignItems='MIN';toolbar.counterAxisAlignItems='CENTER';toolbar.itemSpacing=16;
 if(middle.name==='Writing prompts'){
  const p=middle.children.find(n=>n.name==='What stayed with you?');
  toolbar.insertChild(0,p);p.resize(246,44);p.fills=[];p.strokes=[];p.paddingLeft=0;p.paddingRight=0;p.primaryAxisAlignItems='MIN';p.counterAxisAlignItems='CENTER';
  const t=p.findOne(n=>n.type==='TEXT');t.fontName={family:'Plus Jakarta Sans',style:'Regular'};t.fontSize=14;t.resize(246,t.height);t.fills=(await figma.getNodeByIdAsync('74:49')).fills;
  changed.add(p.id);changed.add(t.id);middle.visible=false;
 }else{
  toolbar.insertChild(0,middle);middle.resize(246,44);middle.primaryAxisSizingMode='FIXED';middle.counterAxisSizingMode='FIXED';middle.paddingLeft=0;middle.paddingRight=0;
  middle.layoutMode='HORIZONTAL';middle.counterAxisAlignItems='CENTER';
  for(const t of middle.children.filter(n=>n.type==='TEXT')){if(middle.name==='Pingu nudge')t.characters='What would help next?';t.resize(246,t.height);changed.add(t.id);}
 }
 input.resize(306,218);editor.itemSpacing=12;editor.resize(342,310);
 for(const n of [editor,input,toolbar,middle,voice,icon])changed.add(n.id);
 evidence.push({frame:frameId,editor:{height:editor.height,visibleRows:editor.children.filter(n=>n.visible).map(n=>({id:n.id,name:n.name,height:n.height}))},toolbar:toolbar.children.filter(n=>n.visible).map(n=>({id:n.id,name:n.name,width:n.width,height:n.height})),voiceActions:voice.reactions.length,tabY:root.children.find(n=>n.name==='Tab bar').y});
}
const page=figma.currentPage;page.name='CircleU • connected review 19';changed.add(page.id);
return {mutatedNodeIds:[...changed],evidence};
