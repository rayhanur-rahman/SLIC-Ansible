from github import Github
from datetime import datetime
import math
import time, os, subprocess, shutil

def cloneRepo(owner, repoName):
    g = Github('brokenquark','******')
    try:
        repo = g.get_repo(f'{owner}/{repoName}')
    except:
        status = ['============NOT_FOUND============', '']
        return status

    dir = f'{owner}@{repoName}'
    gitUrl = f'https://github.com/{owner}/{repoName}'
    dir = f'/home/brokenquark/repo-icse/{dir}/'
    subprocess.call(f'git clone {gitUrl} {dir}', shell=True)
    return

repoList = []

file = open('repoList/ICSE2020_FINAL_PUPP_REPOS.csv', 'r')
for line in file:
    repoList.append(f'{line[0:-2]}')

filteredRepoList = set(repoList)
filteredRepoList = list(filteredRepoList)
filteredRepoList.sort()
print(len(filteredRepoList))

for i in range(0, 221):
    owner = filteredRepoList[i].split('/')[0]
    repo= filteredRepoList[i].split('/')[1]
    try:
        cloneRepo(owner, repo)
        print(f'{i} | {owner}@{repo}')
    except:
        print(f'terminating at {i}')
        break

