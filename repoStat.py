from collections import Counter
import math

# file = open('repo-stat/chef-repo-stat.csv')
#
# is_forked = 0
# not_enough_developers = 0
# not_found = 0
# not_enough_playbooks = 0
# not_enough_commits = 0
# all_okay = 0
#
# for line in file:
#     data = line.split(',')
#     if data[2].strip() == 'IS_FORKED': is_forked += 1
#     if data[2].strip() == 'NOT_ENOUGH_DEVELOPERS': not_enough_developers += 1
#     if data[2].strip() == 'NOT_ENOUGH_COMMITS': not_enough_commits += 1
#     if data[2].strip() == '============NOT_FOUND============': not_found += 1
#     if data[2].strip() == 'NOT_ENOUGH_COOKBOOKS': not_enough_playbooks += 1
#     if data[2].strip() == 'ALL_OKAY': all_okay += 1
#
# print(f'forked: {is_forked}')
# print(f'not enough authors: {not_enough_developers}')
# print(f'not enough commits: {not_enough_commits}')
# print(f'not found: {not_found}')
# print(f'not enough scripts: {not_enough_playbooks}')
# print(f'ok: {all_okay}')
#

# file = open('repo-stat/anis-2.csv')
# repo_stat = []
#
# for line in file:
#     data = line.split(',')
#     if data[2].strip() == 'ALL_OKAY':
#         repo_stat.append({
#             'name': data[1].strip(),
#             'percentage': data[3].strip()
#         })
#
#
# file2 = open('ymlpaths.txt')
#
# repoNames = []
# for line in file2:
#     data = line.split('/')
#     repoNames.append(data[4].strip())
#
#
#
# ansibleCounts = Counter(repoNames).items()
#
# totalAnsibleFiles = 0
# totalNonAnsibleFiles = 0
#
# for x in repo_stat:
#     for y in ansibleCounts:
#         if x['name'] == y[0]:
#             x['ansible-count'] = y[1]
#             x['non-ansible-count'] = math.ceil(100 * y[1] / float(x['percentage']))
#             totalAnsibleFiles += x['ansible-count']
#             totalNonAnsibleFiles += x['non-ansible-count']
#
# print(totalAnsibleFiles)
# print(totalNonAnsibleFiles)



file = open('ymlpaths.txt', 'r')

failure = 0
sloc = 0

for line in file:
    try:
        f = open(f'{line.strip()}', 'r')
        for l in f:
            if len(l.strip()) > 0:
                sloc += 1

    except: failure += 1

print(sloc)
print(failure)