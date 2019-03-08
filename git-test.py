from github import Github
from datetime import datetime
import math
import time, os, subprocess, shutil

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
            if (fileName.endswith('.yml') or fileName.endswith('.yaml')) and 'test' not in repo['path']:
                scriptCount += 1
                try:
                    os.mkdir(f'/home/brokenquark/dump/{folderName}')
                except:
                    pass
                subprocess.call(f'cp {dirName}/{fileName} /home/brokenquark/dump/{folderName}', shell=True)
    status = None
    if scriptCount > 0:
        subprocess.call(f'cp -r {gitFolderPath} /home/brokenquark/dump/{folderName}', shell=True)
    # print(f'file: {count} | cookbook: {scriptCount}')
    if 100 * (scriptCount / count) < 10:
        try:
            shutil.rmtree(f'/home/brokenquark/dump/{folderName}')
            status = 'NOT_ENOUGH_PLAYBOOKS'
        except:
            pass
    else:
        status = 'ALL_OKAY'
    return status


def cloneRepo(owner, repoName):
    g = Github('brokenquark','***')
    # g = Github()

    #repo = g.get_repo(f'{owner}/{repoName}')

    status = None

    try:
        repo = g.get_repo(f'{owner}/{repoName}')
    except:
        # print('not found')
        status = 'NOT_FOUND'
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
                status = 'NOT_ENOUGH_COMMITS'
                return status

            dir = f'{owner}@{repoName}'
            if commitsPerMonth >= 2:
                gitUrl = f'https://github.com/{owner}/{repoName}'
                dir = f'/home/brokenquark/repo-ansi/{dir}/'
                subprocess.call(f'git clone {gitUrl} {dir}', shell=True)

                status = filterRepo(dir)

                try:
                    shutil.rmtree(f'{dir}')
                except:
                    pass
            else:
                # print('not enough commits')
                status = 'NOT_ENOUGH_COMMITS'
        else:
            # print('not enough authors')
            status = 'NOT_ENOUGH_DEVELOPERS'
    else:
        # print('is forked')
        status = 'IS_FORKED'
    return status

repoList = []

file = open('repo-ansible.csv', 'r')
for line in file:
    repoList.append(f'{line.split(",")[0]}/{line.split(",")[1]}')

filteredRepoList = set(repoList)
filteredRepoList = list(filteredRepoList)
filteredRepoList.sort()
print(len(filteredRepoList))

# cloneRepo('brokenquark', 'NCSUCC18')

for i in range(13757, 14285):
    owner = filteredRepoList[i].split('/')[0]
    repo= filteredRepoList[i].split('/')[1]
    # print(f'#{i} : {owner}@{repo}')
    try:
        status = cloneRepo(owner, repo)
    except:
        print('waiting...')
        time.sleep(3600)
        status = cloneRepo(owner, repo)
    print(f'{i},{owner}@{repo},{status}')
    file = open('ansi-repo-stat.csv', 'a')
    file.write(f'{i},{owner}@{repo},{status}\n')
    file.close()

#4343-7538 10074-14285