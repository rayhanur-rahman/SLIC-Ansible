from github import Github

# using username and password
# g = Github("brokenquark", "456")
g = Github()


# for repo in g.get_user().get_repos():
#     print(repo.name)
#     repo.edit(has_wiki=False)
#     # to see all the available attributes and methods
#     print(dir(repo))

repo = g.get_repo("brokenquark/NCSUCC18")
x = repo.get_commits()

for i in x:
    print(f'{i.raw_data["sha"]}, {i.raw_data["commit"]["author"]["name"]}, {i.raw_data["commit"]["author"]["date"]}')