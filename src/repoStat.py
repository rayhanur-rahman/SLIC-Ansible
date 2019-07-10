from github import Github
from datetime import datetime
import math
import time, os, subprocess, shutil
# #
# file = open('repo-stat/ansi-updated.csv', 'r')
#
# sloc = 0
# for line in file:
#     rows = line.split(',')
#     if rows[2] == 'ALL_OKAY':
#         path = f'/home/brokenquark/repo-ansi/{rows[1]}/'
#         for dirName, subdirList, fileList in os.walk(path):
#             foldernames = [x.lower() for x in dirName.split('/')]
#             for fileName in fileList:
#                 if 'playbooks' in foldernames and 'test' not in foldernames:
#                     file2.write(f'{dirName}/{fileName}\n')
#
# file2.close()
#
# # file = open('../yml directory list/ymlPathsUpdated.txt', 'r')
# #
# # failure = 0
# # sloc = 0
# #
# # for line in file:
# #     try:
# #         f = open(f'{line.strip()}', 'r')
# #         for l in f:
# #             if len(l.strip()) > 0:
# #                 sloc += 1
# #
# #     except: failure += 1
# #
# # print(sloc)
# # print(failure)

total = 0
for dirName, subdirList, fileList in os.walk('/home/brokenquark/ostk-ansi/ostk-ansi'):
    for fileName in fileList:
        total += 1

print(total)