#!/usr/bin/env python3
from pathlib import Path
import json, shutil
share=Path('/usr/local/share/serpantinum')
assets=Path('/usr/local/share/nabu/tablet')
shutil.copyfile(assets/'KeyboardLayout.qml',share/'src/quickshell/singletons/system/KeyboardLayout.qml')
qmldir=share/'src/quickshell/lock/qmldir'
s=qmldir.read_text()
if 'TouchKeyboard 1.0 TouchKeyboard.qml' not in s:
    qmldir.write_text(s.rstrip()+'\nTouchKeyboard 1.0 TouchKeyboard.qml\n')
faces=share/'src/quickshell/bar/faces/tablet';faces.mkdir(exist_ok=True)
for name in ['Osk','Rotation']:
    shutil.copyfile(assets/(name+'Face.qml'),faces/(name+'Face.qml'))
p=share/'src/quickshell/bar/BarModuleRegistry.qml'
s=p.read_text()
if '"rotation": {' not in s:
    s=s.replace('property var types: ({','property var types: ({\n        "rotation": {name: "Rotate screen", icon: "↻", defaultVariant: "default", face: "faces/tablet/RotationFace.qml"},\n        "osk": {name: "On-screen keyboard", icon: "⌨", defaultVariant: "default", face: "faces/tablet/OskFace.qml"},')
    p.write_text(s)
cfg=Path('/home/user/.config/serpantinum/settings.json')
s=json.loads(cfg.read_text())
s['wallpaperDir']='/home/user/Pictures/Wallpapers'
s['bar']['height']=72
s['bar']['modules']={'left':['left','workspaces'],'center':['timedate'],'right':[['kb','osk','rotation','wifi','bt','vol','bat']]}
s['dock']['elementSize']=56
wall=Path('/home/user/Pictures/Wallpapers/nabu.png');wall.parent.mkdir(parents=True,exist_ok=True)
shutil.copyfile(share/'config/sddm/themes/material-you/bg.png',wall)
cfg.write_text(json.dumps(s,ensure_ascii=False,indent=2)+'\n')

# Seed a real wallpaper for a fresh image, while preserving an existing choice.
cache=Path('/home/user/.cache/serpantinum/wallpaper');cache.mkdir(parents=True,exist_ok=True)
state=cache/'current_DSI-1'
if not state.exists():
    state.write_text(str(wall))
    (cache/'current_DSI-1_name').write_text(wall.name)
