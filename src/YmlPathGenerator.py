import os, time 

REPO_DIR = '/home/brokenquark/Workspace/SLIC-Ansible/repo-github/'
YMLPATHSFILELOCATION = '/home/brokenquark/Workspace/SLIC-Ansible/ymlPaths/github.txt'

file = 0
ymlPathFile = open(YMLPATHSFILELOCATION, 'w')
for subdir, dirs, files in os.walk(REPO_DIR):
    for file in files:
        ymlPath = os.path.join(subdir, file)
        if '.git' not in ymlPath and ymlPath.endswith('.yml'): 
            ymlPathFile.write(f'{ymlPath}\n')
