import fs from 'node:fs/promises';
import path from 'node:path';
import { createRequire } from 'node:module';
import { GlobalFonts } from '@napi-rs/canvas';
const root=process.cwd();
const out=path.join(root,'docs/design/showcase-2026-10-30/refinement-06');
const build=path.join(root,'.build/showcase-refinement-06');
const font=path.join(root,'Prototypes/CircleUVisualPrototype/Sources/CircleUVisualPrototype/Resources/BrandFonts/PlusJakartaSans.ttf');
GlobalFonts.registerFromPath(font,'Plus Jakarta Sans');
const require=createRequire(import.meta.url);
const artPath=require.resolve('@oai/artifact-tool');
const skia=require(path.join(path.dirname(artPath),'../node_modules/skia-canvas'));
if(skia.FontLibrary?.use)skia.FontLibrary.use('Plus Jakarta Sans',[font]);
const {Presentation,PresentationFile}=await import('@oai/artifact-tool');
const presentation=Presentation.create({slideSize:{width:1280,height:720}});
const slide=presentation.slides.add();
async function addImage(file,alt,pos,crop){
 const b=await fs.readFile(file);
 return slide.images.add({blob:b.buffer.slice(b.byteOffset,b.byteOffset+b.byteLength),contentType:'image/png',alt,position:pos,fit:'contain',...(crop?{crop}:{})});
}
await addImage(path.join(out,'poster-artwork.png'),'CircleU illustrated design mockups with distinct screen artwork',{left:0,top:0,width:1280,height:720});
function tx(name,text,x,y,w,h,size,bold=false,color='#0D1421'){
 const s=slide.shapes.add({name,geometry:'textbox',fill:'none',line:{fill:'none',width:0},position:{left:x,top:y,width:w,height:h}});
 s.text=text;s.text.style={typeface:'Plus Jakarta Sans',fontSize:size,bold,color,insets:0,autoFit:'none',verticalAlignment:'top'};
}
tx('Headline','Some\nconversations\nstay with you',64,158,382,173,43,true);
tx('Introduction','A space to reflect on what happened\nand find words for what comes next',66,345,365,68,19,false,'#465D7F');
tx('Original-label','First thought',66,448,345,25,16,true,'#054FC9');
tx('Original-quote','“You never help with our project.”',66,479,362,58,20);
tx('Rewrite-label','A possible rewrite',66,548,360,25,16,true,'#054FC9');
tx('Rewrite-quote','“Could we agree on which parts\neach of us will handle?”',66,578,373,70,21,true);
await addImage(path.join(root,'docs/design/showcase-2026-10-30/refinement-04/assets/uts-apple-foundation-program-original.png'),'UTS Apple Foundation Program official lockup',{left:66,top:653,width:167,height:64}, {left:0.07,right:0.07,top:0.19,bottom:0.19});
tx('Example-disclosure','Illustrative example',250,680,188,22,12,false,'#465D7F');
slide.speakerNotes.text='Local revision of the existing Direction B poster after its live Spaces connection failed. Headline and left-side copy are editable; logo, phone UI and environment are raster design mockups, not screenshots of implemented app behaviour. New image references: BrandArtwork/ScreenScenes06 (WindowPause, JournalDesk, PracticeStudio). Artwork created with built-in imagegen; exact prompt stored alongside. The UTS Apple Foundation Program mark is reused from the prior poster; no endorsement is implied. No active App Store or TestFlight availability is claimed. Source: docs/product/overview.md and docs/design/branding-guideline.md.';
await fs.writeFile(path.join(out,'CircleU-Poster-v6.png'),new Uint8Array(await (await presentation.export({slide,format:'png',scale:2})).arrayBuffer()));
await fs.writeFile(path.join(build,'poster.layout.json'),await (await slide.export({format:'layout'})).text());
await (await PresentationFile.exportPptx(presentation)).save(path.join(build,'candidate.pptx'));
await fs.writeFile(path.join(build,'font-check.json'),JSON.stringify({registered:GlobalFonts.families.filter(f=>f.family.includes('Jakarta')),skia:skia.FontLibrary?.families?.filter(f=>f.includes('Jakarta'))},null,2));
console.log('Rendered poster and exported candidate');
