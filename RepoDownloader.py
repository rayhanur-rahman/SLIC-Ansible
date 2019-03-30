from github import Github
from datetime import datetime
import math
import time, os, subprocess, shutil

def filterRepo(rootDir):
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
                    if '.git' not in repo['path']: os.remove(f'{dirName}/{fileName}')
                except:
                    pass
            else:
                print(f'\t{dirName}/{fileName}')
                paths = paths + f'{dirName}/{fileName}\n'

    status = None
    if 100 * (unnecessaryScriptCount / count) > 90:
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
    print(f'\t#########--{(100 - 100*(unnecessaryScriptCount/count)):.2f}--#########')
    return [status, (100 - 100*(unnecessaryScriptCount/count))]


def cloneRepo(owner, repoName):
    g = Github('brokenquark','***')
    # g = Github()

    #repo = g.get_repo(f'{owner}/{repoName}')

    status = None

    try:
        repo = g.get_repo(f'{owner}/{repoName}')
    except:
        # print('not found')
        status = ['============NOT_FOUND============', '']
        return status

    if not repo.fork:
        contributors = repo.get_contributors()
        authors = []
        for item in contributors:
            authors.append(item.login)
        numberOfAuthors = len(authors)

        if numberOfAuthors > 9:
            commits = repo.get_commits()
            numberOfCommits = commits.totalCount

            firstCommit = datetime.strptime(commits[0].raw_data['commit']['committer']['date'], '%Y-%m-%dT%H:%M:%SZ')
            lastCommit = datetime.strptime(commits.reversed[0].raw_data['commit']['committer']['date'], '%Y-%m-%dT%H:%M:%SZ')

            if math.fabs((lastCommit - firstCommit).days) > 0:
                commitsPerMonth = math.ceil(math.fabs(numberOfCommits / ((lastCommit - firstCommit).days/30)))
            else:
                # print('very short timed repository')
                status = ['NOT_ENOUGH_COMMITS','']
                return status

            dir = f'{owner}@{repoName}'
            if commitsPerMonth >= 2:
                gitUrl = f'https://github.com/{owner}/{repoName}'
                dir = f'/home/brokenquark/repo-ansi/{dir}/'
                subprocess.call(f'git clone {gitUrl} {dir}', shell=True)
                status = filterRepo(dir)
            else:
                # print('not enough commits')
                status = ['NOT_ENOUGH_COMMITS','']
        else:
            # print('not enough authors')
            status = ['NOT_ENOUGH_DEVELOPERS','']
    else:
        # print('is forked')
        status = ['IS_FORKED','']
    return status

repoList = []

file = open('repoList/repo-ansible.csv', 'r')
for line in file:
    repoList.append(f'{line.split(",")[0]}/{line.split(",")[1]}')

filteredRepoList = set(repoList)
filteredRepoList = list(filteredRepoList)
filteredRepoList.sort()
print(len(filteredRepoList))

for i in range(13335, 14285):
    # if i%1000==0:
    #     print('waiting...')
    #     time.sleep(60)

    owner = filteredRepoList[i].split('/')[0]
    repo= filteredRepoList[i].split('/')[1]
    # print(f'#{i} : {owner}@{repo}')
    try:
        status = cloneRepo(owner, repo)
        print(f'{i} | {owner}@{repo} | {status}')
        file = open('repo-stat/ansi-repo-stat.csv', 'a')
        file.write(f'{i},{owner}@{repo},{status[0]},{status[1]},\n')
        file.close()
    except:
        print(f'terminating at {i}')
        break

