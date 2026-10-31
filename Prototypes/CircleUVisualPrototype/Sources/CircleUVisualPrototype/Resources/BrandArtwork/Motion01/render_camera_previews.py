"""Render finite camera-motion videos from saved originals; no character rig."""
from pathlib import Path
import hashlib,json,subprocess
# Run from repository root.
root=Path.cwd()
base=root/'Prototypes/CircleUVisualPrototype/Sources/CircleUVisualPrototype/Resources/BrandArtwork'
out=base/'Motion01'
out.mkdir(exist_ok=True)
items=[('WelcomePath','ScreenScenes07/SceneWelcomePathV1.png',0.5),('ReflectionGarden','ScreenScenes07/SceneReflectionGardenV1.png',0.78),('VoiceCorner','ScreenScenes07/SceneVoiceCornerV1.png',0.32)]
manifest={'method':'FFmpeg camera-motion study from a still image; no generated character motion','duration_seconds':8,'fps':30,'width':1280,'height':640,'audio':False,'assets':[]}
for name,relative,anchor in items:
    target=out/(name+'-camera-motion-v1.mp4')
    filt=f"scale=2560:1280:flags=lanczos,zoompan=z='1+0.04*(1-cos(2*PI*on/239))/2':x='(iw-iw/zoom)*{anchor}':y='(ih-ih/zoom)*0.5':d=240:s=1280x640:fps=30,setsar=1,format=yuv420p"
    cmd=['/opt/homebrew/bin/ffmpeg','-hide_banner','-loglevel','error','-n','-i',str(base/relative),'-vf',filt,'-frames:v','240','-an','-c:v','libx264','-preset','medium','-crf','18','-movflags','+faststart',str(target)]
    subprocess.run(cmd,check=True)
    probe=json.loads(subprocess.check_output(['/opt/homebrew/bin/ffprobe','-v','error','-show_streams','-show_format','-of','json',str(target)]))
    v=probe['streams'][0]
    assert (v['width'],v['height'],v['nb_frames'])==(1280,640,'240')
    assert abs(float(probe['format']['duration'])-8)<0.05
    subprocess.run(['/opt/homebrew/bin/ffmpeg','-v','error','-i',str(target),'-f','null','-'],check=True)
    manifest['assets'].append({'file':target.name,'source':relative,'source_sha256':hashlib.sha256((base/relative).read_bytes()).hexdigest(),'sha256':hashlib.sha256(target.read_bytes()).hexdigest(),'bytes':target.stat().st_size,'filter':filt})
    print(target.name,flush=True)
(out/'provenance.json').write_text(json.dumps(manifest,indent=2)+'\n')
