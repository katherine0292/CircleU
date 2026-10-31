await figma.setCurrentPageAsync(await figma.getNodeByIdAsync('74:2'));
const created=[],removed=[],mutated=[];
for(const [oldId,componentId,parentId] of [['74:12','125:463','125:471'],['74:44','125:463','125:477'],['74:73','125:465','125:485'],['74:99','125:463','125:491'],['74:128','125:463','125:497'],['74:159','125:463','125:506']]){
 const old=await figma.getNodeByIdAsync(oldId),parent=await figma.getNodeByIdAsync(parentId),component=await figma.getNodeByIdAsync(componentId);
 const icon=component.createInstance();parent.insertChild(0,icon);icon.name=old.name;icon.fills=[];icon.resize(44,44);await icon.setReactionsAsync([]);old.remove();removed.push(oldId);created.push(icon.id);parent.itemSpacing=4;parent.paddingLeft=0;parent.paddingRight=4;parent.resize(112,44);mutated.push(parent.id);
 const label=parent.children.find(n=>n.type==='TEXT'); label.resize(56,label.height);mutated.push(label.id);
}
return {createdNodeIds:created,removedNodeIds:removed,mutatedNodeIds:mutated};
