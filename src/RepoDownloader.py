from github import Github
from datetime import datetime
import math
import time
import os
import subprocess
import shutil

GITHUB_USER_NAME = 'brokenquark'
GITHUB_PASSWORD = '***'
REPO_DOWNLOAD_DIRECTORY = '/home/brokenquark/Workspace/SLIC-Ansible/repo-github/'
APPLY_FILTER = False



def filterRepo(rootDir, applyFilter):
    paths = ''
    count = 0
    unnecessaryScriptCount = 0
    repos = []
    folderName = str([x for x in rootDir.split("/") if x != ''][-1])
    for dirName, subdirList, fileList in os.walk(rootDir):
        repo = {
            'name': dirName,
            'path': [x for x in dirName.split('/') if x != ''][3:]
        }
        repos.append(repo)
        for fileName in fileList:
            count += 1
            if (not fileName.endswith('yml') and not fileName.endswith('yaml')) or 'test' in repo['path']:
                unnecessaryScriptCount += 1
                try:
                    if '.git' not in repo['path']:
                        os.remove(f'{dirName}/{fileName}')
                except:
                    pass
            else:
                print(f'\t{dirName}/{fileName}')
                paths = paths + f'{dirName}/{fileName}\n'

    status = None
    if 100 * (unnecessaryScriptCount / count) > 90 and applyFilter == True:
        status = 'NOT_ENOUGH_PLAYBOOKS'
        try:
            shutil.rmtree(f'{rootDir}')
        except:
            pass
    else:
        status = 'ALL_OKAY'
        # file = open('ymlpaths2.txt', 'a')
        # file.write(paths)
        # file.close()
    print(
        f'\t#########--{(100 - 100*(unnecessaryScriptCount/count)):.2f}--#########')
    return [status, (100 - 100*(unnecessaryScriptCount/count))]


def cloneRepo(owner, repoName, applyFilter):
    g = Github(GITHUB_USER_NAME, GITHUB_PASSWORD)

    status = None

    try:
        repo = g.get_repo(f'{owner}/{repoName}')
    except:
        status = ['============NOT_FOUND============', '']
        return status

    if not repo.fork or applyFilter == False:
        contributors = repo.get_contributors()
        authors = []
        for item in contributors:
            authors.append(item.login)
        numberOfAuthors = len(authors)

        if numberOfAuthors > 9 or applyFilter == False:
            commits = repo.get_commits()
            numberOfCommits = commits.totalCount

            firstCommit = datetime.strptime(
                commits[0].raw_data['commit']['committer']['date'], '%Y-%m-%dT%H:%M:%SZ')
            lastCommit = datetime.strptime(
                commits.reversed[0].raw_data['commit']['committer']['date'], '%Y-%m-%dT%H:%M:%SZ')

            if math.fabs((lastCommit - firstCommit).days) > 0 or applyFilter == False:
                commitsPerMonth = math.ceil(
                    math.fabs(numberOfCommits / ((lastCommit - firstCommit).days/30)))
            else:
                status = ['NOT_ENOUGH_COMMITS', '']
                return status

            dir = f'{owner}@{repoName}'
            if commitsPerMonth >= 2 or applyFilter == False:
                gitUrl = f'https://github.com/{owner}/{repoName}'
                dir = f'{REPO_DOWNLOAD_DIRECTORY}{dir}/'
                subprocess.call(f'git clone {gitUrl} {dir}', shell=True)
                status = filterRepo(dir, applyFilter)
            else:
                status = ['NOT_ENOUGH_COMMITS', '']
        else:
            status = ['NOT_ENOUGH_DEVELOPERS', '']
    else:
        status = ['IS_FORKED', '']
    return status

