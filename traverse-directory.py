import os, subprocess, shutil

rootDirs = []
for dirname in next(os.walk('/home/brokenquark/repo/'))[1]:
    rootDirs.append(f'/home/brokenquark/repo/{dirname}/')

for rootDir in rootDirs:
    count = 0
    scriptCount = 0
    repos = []
    for dirName, subdirList, fileList in os.walk(rootDir):
        repo = {
            'name': dirName,
            'path': [x for x in dirName.split('/') if x != ''][3:]
        }
        repos.append(repo)
        for fileName in fileList:
            count += 1
            if fileName.endswith('.rb') and 'test' not in repo['path']:
                scriptCount += 1
                folderName = str([x for x in rootDir.split("/") if x != ''][-1])
                try: os.mkdir(f'/home/brokenquark/dump/{folderName}')
                except: pass
                subprocess.call(f'cp {dirName}/{fileName} /home/brokenquark/dump/{folderName}', shell=True)
    print(f'file: {count}| cookbook: {scriptCount}')
    if 100*(scriptCount/count) < 10:
        try: shutil.rmtree(f'/home/brokenquark/dump/{folderName}')
        except: pass



