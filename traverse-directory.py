import os, subprocess, shutil

def filterScripts(root):
    rootDirs = []
    for dirName in next(os.walk(root))[1]:
        rootDirs.append(f'{root}{dirName}/')

    for rootDir in rootDirs:
        filterRepo(rootDir)
    return

def filterRepo(rootDir):
    count = 0
    scriptCount = 0
    repos = []
    folderName = str([x for x in rootDir.split("/") if x != ''][-1])
    gitFolderPath = None
    for dirName, subdirList, fileList in os.walk(rootDir):
        if dirName.endswith('.git') or dirName.endswith('.git/'):
            gitFolderPath = dirName
        repo = {
            'name': dirName,
            'path': [x for x in dirName.split('/') if x != ''][3:]
        }
        repos.append(repo)
        for fileName in fileList:
            count += 1
            if fileName.endswith('.rb') and 'test' not in repo['path']:
                scriptCount += 1
                try:
                    os.mkdir(f'/home/brokenquark/dump/{folderName}')
                except:
                    pass
                subprocess.call(f'cp {dirName}/{fileName} /home/brokenquark/dump/{folderName}', shell=True)

    if scriptCount > 0:
        subprocess.call(f'cp -r {gitFolderPath} /home/brokenquark/dump/{folderName}', shell=True)
    print(f'file: {count}|cookbook: {scriptCount}')
    if 100 * (scriptCount / count) < 10:
        try:
            shutil.rmtree(f'/home/brokenquark/dump/{folderName}')
        except:
            pass
    return


filterScripts('/run/media/brokenquark/8E30E13030E12047/repo-chef/')
