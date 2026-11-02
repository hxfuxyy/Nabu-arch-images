#!/usr/bin/env python3
"""Replace the recovery script in place, keeping one central entry per filename."""
import copy,hashlib,json,os,sys,zipfile
from pathlib import Path
archive=Path(sys.argv[1]);script=Path(sys.argv[2]).read_bytes()
name='META-INF/com/google/android/update-binary'
with zipfile.ZipFile(archive,'a',allowZip64=True) as z:
 original=z.getinfo(name)
 manifest=json.loads(z.read('BUILD-SOURCES.json'))
 manifest['installer_patch']={'reason':'Use AWK for 64-bit partition size comparison on TWRP mksh','commit':os.environ.get('GITHUB_SHA','local')}
 replacements={name:script,'BUILD-SOURCES.json':(json.dumps(manifest,indent=2)+'\n').encode()}
 infos={n:copy.copy(z.getinfo(n)) for n in replacements}
 z.filelist[:]=[i for i in z.filelist if i.filename not in replacements]
 for n in replacements:z.NameToInfo.pop(n,None)
 for n,data in replacements.items():z.writestr(infos[n],data,compress_type=zipfile.ZIP_DEFLATED)
with zipfile.ZipFile(archive) as z:
 assert len([i for i in z.infolist() if i.filename==name])==1
 assert z.read(name)==script
 assert z.testzip() is None
 print('All ZIP CRCs verified; updater replaced without duplicate entries',flush=True)
with archive.open('rb') as f:digest=hashlib.file_digest(f,'sha256').hexdigest()
archive.with_suffix(archive.suffix+'.sha256').write_text(digest+'  '+archive.name+'\n')
print('Patched installer SHA256:',digest,flush=True)
