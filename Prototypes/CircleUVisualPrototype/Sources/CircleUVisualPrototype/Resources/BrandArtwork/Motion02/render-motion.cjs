// Showcase composition only: original PNGs stay intact; no image generation.
// Run from the repository root with NODE_PATH pointing to the bundled Node modules.
const {createCanvas, loadImage} = require('@napi-rs/canvas');
const {spawn, execFileSync} = require('node:child_process');
const {once} = require('node:events');
const fs = require('node:fs');
const path = require('node:path');
const crypto = require('node:crypto');

const base = path.resolve('Prototypes/CircleUVisualPrototype/Sources/CircleUVisualPrototype/Resources/BrandArtwork');
const out = path.join(base, 'Motion02');
const hash = file => crypto.createHash('sha256').update(fs.readFileSync(file)).digest('hex');
const manifest = {date:'2026-10-31', method:'Local keyframed composition of unchanged transparent PNGs', width:720, height:720, fps:30, duration_seconds:6, audio:false, credits_used:0, assets:[]};

async function render(name, source, voice) {
    const file = path.join(out, name + '.mp4');
    if (fs.existsSync(file)) throw new Error('Refusing to overwrite ' + file);
    const img = await loadImage(path.join(base, source));
    const canvas = createCanvas(720,720);
    const c = canvas.getContext('2d');
    const encoder = spawn('/opt/homebrew/bin/ffmpeg', ['-hide_banner','-loglevel','error','-n','-f','rawvideo','-pixel_format','rgba','-video_size','720x720','-framerate','30','-i','pipe:0','-an','-c:v','libx264','-preset','medium','-crf','18','-pix_fmt','yuv420p','-movflags','+faststart',file], {stdio:['pipe','ignore','inherit']});
    const complete = once(encoder, 'close');
    for (let f=0;f<180;f++) {
        const t=f/30, phase=2*Math.PI*t/3;
        c.fillStyle='#F5FAFF'; c.fillRect(0,0,720,720);
        const glow=c.createRadialGradient(360,330,40,360,330,330);
        glow.addColorStop(0,'#DCEEFF'); glow.addColorStop(1,'#F5FAFF');
        c.fillStyle=glow; c.fillRect(0,0,720,720);
        c.strokeStyle='#DFECFA'; c.lineWidth=2;
        c.beginPath(); c.ellipse(360,332,267,267,0,0,Math.PI*2); c.stroke();
        // A small whole-sprite lift, not a fabricated eye blink or body rig.
        const lift=3*(1-Math.cos(phase));
        c.fillStyle='rgba(5,79,201,0.07)';
        c.beginPath(); c.ellipse(360,565,112-lift,12-lift*.35,0,0,Math.PI*2); c.fill();
        c.drawImage(img,110,70-lift,500,500);
        if (voice) {
            for (let i=0;i<17;i++) {
                const envelope=Math.sin(Math.PI*(i+1)/18);
                const wave=(1+Math.sin(2*Math.PI*t+i*.72))/2;
                const height=10+envelope*(14+38*wave);
                c.fillStyle=i%4===0?'#47C7FF':'#054FC9';
                c.beginPath(); c.roundRect(226+i*16,629-height/2,8,height,4); c.fill();
            }
        } else {
            c.fillStyle='#BDD8F6'; c.beginPath(); c.ellipse(360,629,4,4,0,0,Math.PI*2); c.fill();
        }
        if (f===0) fs.writeFileSync(path.join(out,name+'.png'),canvas.toBuffer('image/png'));
        if (!encoder.stdin.write(Buffer.from(c.getImageData(0,0,720,720).data))) await once(encoder.stdin,'drain');
    }
    encoder.stdin.end();
    const [code]=await complete;
    if(code!==0) throw new Error('FFmpeg exit '+code);
    const probe=JSON.parse(execFileSync('/opt/homebrew/bin/ffprobe',['-v','error','-show_streams','-show_format','-of','json',file]));
    const v=probe.streams[0];
    if(v.width!==720 || v.height!==720 || v.nb_frames!=='180' || probe.streams.length!==1 || Number(probe.format.duration)!==6) throw new Error('Unexpected export format');
    execFileSync('/opt/homebrew/bin/ffmpeg',['-v','error','-i',file,'-f','null','-']);
    manifest.assets.push({file:path.basename(file),source,source_sha256:hash(path.join(base,source)),sha256:hash(file),bytes:fs.statSync(file).size,verified:'180 frames, 6 seconds, 720 square, H.264, no audio; full decode passed',motion:voice?'6 px sprite lift over 3 seconds plus illustrative waves, not microphone-driven':'6 px sprite lift over 3 seconds'});
    console.log('Verified '+path.basename(file));
}
(async()=>{
    await render('PinguIdle-keyframe-v1','Activities01/PinguQuietBreathV1.png',false);
    await render('PinguVoice-keyframe-v1','Activities01/PinguPractisingV1.png',true);
    fs.writeFileSync(path.join(out,'provenance.json'),JSON.stringify(manifest,null,2)+'\n');
})().catch(error=>{console.error(error);process.exitCode=1;});
