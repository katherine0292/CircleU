// Applies bounded edits to the existing six-slide showcase deck.
// Run inside artifactSession with its prebound presentation.
export default async function refine({presentation,input}) {
 const root=input.root;
 const bg=root+'docs/design/showcase-2026-10-30/refinement-04/assets/arctic-background.png';
 const logo=root+'docs/design/showcase-2026-10-30/refinement-04/assets/uts-apple-foundation-program-original.png';
 const ink='#0D1421', blue='#054FC9', muted='#465D7F';
 function tx(s,id,text,x,y,w,h,size=28,bold=false,color=ink){
   const e=s.shapes.items.find(e=>e.id===id); if(!e)throw new Error('Missing shape '+id);
   e.text=text; e.position={left:x,top:y,width:w,height:h};
   e.text.style={typeface:'Plus Jakarta Sans',fontSize:size,bold,color,insets:0,autoFit:'none',verticalAlignment:'top'};
   return e;
 }
 function add(s,text,x,y,w,h,size=24,bold=false,color=ink){
   const e=s.shapes.add({geometry:'textbox',fill:'none',line:{fill:'none',width:0},position:{left:x,top:y,width:w,height:h}});
   e.text=text;e.text.style={typeface:'Plus Jakarta Sans',fontSize:size,bold,color,insets:0,autoFit:'none'};return e;
 }
 function art(s,index,x,y,w,h){s.images.items.filter(i=>i.alt!=='Soft arctic sunset background')[index].position={left:x,top:y,width:w,height:h};}
 const slides=presentation.slides.items;
 if(slides.length!==6)throw new Error('Expected six existing slides');
 for(const s of slides.filter((_,i)=>i===input.part)){s.background.fill='#F5FAFF';const image=s.images.add({path:bg,alt:'Soft arctic sunset background',position:{left:0,top:0,width:1280,height:720},fit:'cover'});image.sendToBack();}
 let s;
 if(input.part===0){ s=slides[0];
 const circle=s.shapes.items.find(e=>e.id==='3487439740993536');circle.fill='none';circle.line={fill:'none',width:0};
 // The cover no longer needs a tiny editor: preserve the real screens on slides 4 and 5.
 const oldCoverScreen=s.images.items.find(e=>e.id==='3487439740993542');if(oldCoverScreen)oldCoverScreen.delete();
 art(s,0,725,175,520,520);
 tx(s,'3487439740993537','CircleU',130,62,380,65,42,true);
 s.images.add({path:root+'Prototypes/CircleUVisualPrototype/Sources/CircleUVisualPrototype/Resources/BrandArtwork/BrandLogo.png',alt:'CircleU penguin brand mark',position:{left:64,top:52,width:58,height:70},fit:'contain'});
 tx(s,'3487439740993538','Find your\nwords',64,205,670,215,88,true);
 tx(s,'3487439740993539','A calmer space to prepare for\ndifficult conversations',68,445,670,100,30,false,muted);
 tx(s,'3487439740993540','Student project · UTS UI showcase',297,643,460,38,20,false,muted);
 s.images.add({path:logo,alt:'UTS Apple Foundation Program official lockup',position:{left:64,top:604,width:208,height:83},crop:{left:0.07,right:0.07,top:0.19,bottom:0.19},fit:'contain'});
 s.speakerNotes.text='CircleU is a student iPhone project for reflecting on difficult conversations and preparing what to say. This presentation shows the current design direction alongside identified native and prototype screens. Source: docs/product/overview.md and docs/design/branding-guideline.md. UTS Apple Foundation Program lockup source: https://www.uts.edu.au/for-students/experience-uts/career-planning/uts-innovation-hub-for-apple-technologies/apple-foundation-program . Program attribution does not imply endorsement. Pingu assets and background are AI-assisted artwork. No downloadable release is claimed.';
 }
 if(input.part===1){ s=slides[1];
 tx(s,'1561620386938880','A difficult group conversation',64,60,1100,75,48,true);
 tx(s,'1561620386938881','“You never help with our project.”',68,211,710,105,38,true);
 tx(s,'1561620386938882','A possible rewrite',68,357,680,38,24,true,blue);
 tx(s,'1561620386938883','“Could we agree on which parts\neach of us will handle?”',68,409,735,135,38,true);
 tx(s,'1561620386938884','Illustrative example · Keep the meaning. Choose the words.',68,626,800,36,20,false,muted);
 add(s,'First thought',68,164,650,38,24,true,blue);
 art(s,0,846,255,382,390);
 s.speakerNotes.text='This is an invented group-project example, not a participant quote or measured outcome. The rewrite demonstrates one way to turn frustration into a concrete request. CircleU should let people edit or reject wording, and must not invent intentions or facts. Sources: docs/product/overview.md; docs/design/refine-story-review-2026-10-29.md. Ask the audience whether the second version still expresses the original concern. PinguConsideringV1 is existing AI-assisted art.';
 }
 if(input.part===2){ s=slides[2];
 tx(s,'3369948249325568','Meet Pingu',64,54,1100,72,50,true);
 art(s,0,64,150,300,300);art(s,1,429,150,300,300);art(s,2,794,150,300,300);
 tx(s,'3369948249325572','Write',160,468,210,38,26,true);
 tx(s,'3369948249325573','Reflect',519,468,210,38,26,true);
 tx(s,'3369948249325574','Practise',880,468,210,38,26,true);
 tx(s,'3369948249325575','Plus Jakarta Sans',68,559,570,46,30,true);
 tx(s,'3369948249325576','Soft illustration, clear type and room for your words',68,617,1000,40,24,false,muted);
 s.speakerNotes.text='The chosen direction uses softly dimensional Pingu artwork, Plus Jakarta Sans and navy/ice/cobalt colors with a small warm accent. The mascot supports welcome and reflection moments; writing areas stay quiet. Source: docs/design/branding-guideline.md. Existing Activities01 artwork is AI-assisted. Font family is specified as Plus Jakarta Sans; actual runtime rendering should be checked in the presentation environment. Palette swatches are design references, not measured accessibility results.';
 }
 if(input.part===3){ s=slides[3];
 tx(s,'3935693210386432','Practice a difficult conversation',64,42,1160,67,44,true);
 tx(s,'3935693210386433','01  Prepare',92,123,315,38,26,true,blue);
 tx(s,'3935693210386435','02  Refine',500,123,315,38,26,true,blue);
 tx(s,'3935693210386437','03  Continue',914,123,310,38,26,true,blue);
 tx(s,'3935693210386439','Write what you mean',92,650,355,35,22,false,ink);
 tx(s,'3935693210386440','Edit before applying',500,650,355,35,22,false,ink);
 tx(s,'3935693210386441','Add their actual reply',914,650,340,35,22,false,ink);
 tx(s,'3935693210386442','Design prototypes · Scripted feedback',64,696,940,21,16,false,muted);
 s.speakerNotes.text='Prepare, Refine and Continue show the design direction, with scripted feedback rather than a deployed cloud model. The screens come from related browser review iterations; they are not a single completed native session. Sources: PracticeFeedbackReview/prepare-review-08.png, feedback-review-07.png and PracticeFlowReview/reply-review-v2.png under Prototypes/CircleUVisualPrototype. Keep user control explicit: review suggested changes, edit or reject them, and add only the actual reply from the other person. Voice input has separate native evidence; this slide does not demonstrate it.';
 }
 if(input.part===4){ s=slides[4];
 tx(s,'991921553014784','Keep a moment\nin your own words',64,73,520,165,48,true);
 tx(s,'991921553014785','Today',68,309,440,44,28,true,blue);
 tx(s,'991921553014786','Write or talk through\nwhat happened',68,363,450,88,27,false,ink);
 tx(s,'991921553014787','Journal',68,484,440,44,28,true,blue);
 tx(s,'991921553014788','Return to an entry\nand edit it when you need',68,538,470,88,27,false,ink);
 tx(s,'991921553014791','Native guest app captures · Invented content',68,674,800,29,18,false,muted);
 s.speakerNotes.text='These are native guest app captures with invented content, distinct from the generated poster mockups and the scripted browser feedback screens. Sources: docs/design/core-screen-review-2026-10-27/t1-chips.png and u5-saved.png; corresponding capture manifest. Guest working-tree evidence covers writing and saved entries. Do not generalize guest behavior to the standard cloud Release build.';
 }
 if(input.part===5){ s=slides[5];
 tx(s,'2471357695655936','Would you say it\nthis way?',64,60,850,170,66,true);
 tx(s,'2471357695655937','Working in the native guest app',68,287,760,42,27,true,blue);
 tx(s,'2471357695655938','Writing, saved entries and Practice voice input',68,340,800,64,26,false,ink);
 tx(s,'2471357695655939','Still being explored',68,433,700,42,27,true,blue);
 tx(s,'2471357695655940','Editable feedback shown with scripted examples',68,486,800,64,26,false,ink);
 tx(s,'2471357695655941','Next: review the wording with students',68,586,835,45,28,true);
 tx(s,'2471357695655942','CircleU · Student project in development',68,661,800,29,19,false,muted);
 art(s,0,895,270,355,375);
 s.speakerNotes.text='Invite feedback: Is the situation recognizable? Would you use this wording? Does it still sound like you? Native writing, saved entries and voice input have specific working-tree/device evidence; not all release behavior is validated. Scripted feedback remains a design prototype; student usability research and AI-quality validation are pending. Sources: docs/qa/native-practice-2026-10-27/README.md, docs/product/overview.md and docs/design/practice-usability-session-2026-10-30.md. The old TestFlight build is expired as checked 30 October 2026, so this presentation intentionally has no download CTA. PinguBackpackV1 is existing AI-assisted artwork.';
 }
 return {slides:slides.length,part:input.part};
}
