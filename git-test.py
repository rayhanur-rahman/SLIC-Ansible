from github import Github
from datetime import datetime
import math, subprocess
import time

def cloneRepo(owner, repoName):
    g = Github('brokenquark','***')
    # g = Github()

    try:
        repo = g.get_repo(f'{owner}/{repoName}')
    except:
        print('not found')
        return

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
                print('very short timed repository')
                return

            dir = f'{owner}@{repoName}'
            if commitsPerMonth >= 2:
                gitUrl = f'https://github.com/{owner}/{repoName}'
                dir = f'/home/brokenquark/repo/{dir}/'
                subprocess.call(f'git clone {gitUrl} {dir}', shell=True)
            else:
                print('not enough commits')
        else:
            print('not enough authors')
    else:
        print('is forked')
    return

repoList = []

file = open('repolist.csv', 'r')
for line in file:
    repoList.append(f'{line.split(",")[0]}/{line.split(",")[1]}')

filteredRepoList = set(repoList)
filteredRepoList = list(filteredRepoList)
filteredRepoList.sort()
print(len(filteredRepoList))

# cloneRepo('brokenquark', 'NCSUCC18')


counter = 3789
for item in filteredRepoList[counter:5501]:
    owner = item.split('/')[0]
    repo= item.split('/')[1]
    print(f'#{counter} : {owner}@{repo}')
    cloneRepo(owner, repo)
    counter += 1
    # time.sleep(1)
    if counter%100 == 0: time.sleep(30)

