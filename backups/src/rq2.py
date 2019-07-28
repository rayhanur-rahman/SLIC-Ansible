from github import Github
from datetime import datetime
import math
import time
import os
import subprocess
import shutil
from prettytable import PrettyTable

file = open('/home/brokenquark/Workspace/SLIC-Ansible/RQ1/openstackf1.csv', 'r')

index = 0

hard_secr_atLeastOne = 0
emp_pass_atLeastOne = 0
http_usg_atLeastOne = 0
bind_usg_atLeastOne = 0
sus_com_atLeastOne = 0
int_chk_atLeastOne = 0
atLeastOneSmell = 0

hrd_sec_total = 0
emp_pass_total = 0
http_usg_total = 0
bind_usg_total = 0
susp_com_total = 0
int_chck_total = 0
hrd_unm_total = 0
hrd_pass_total = 0
grand_total = 0

sloc = 0

for line in file:
    if index > 0:
        columns = line.split(',')
        if int(columns[3]) > 0:
            hard_secr_atLeastOne += 1
        if int(columns[4]) > 0:
            emp_pass_atLeastOne += 1
        if int(columns[5]) > 0:
            http_usg_atLeastOne += 1
        if int(columns[6]) > 0:
            bind_usg_atLeastOne += 1
        if int(columns[7]) > 0:
            sus_com_atLeastOne += 1
        if int(columns[8]) > 0:
            int_chk_atLeastOne += 1
        if int(columns[11]) > 0:
            atLeastOneSmell += 1

        hrd_sec_total += int(columns[3])
        emp_pass_total += int(columns[4])
        http_usg_total += int(columns[5])
        bind_usg_total += int(columns[6])
        susp_com_total += int(columns[7])
        int_chck_total += int(columns[8])
        hrd_unm_total += int(columns[9])
        hrd_pass_total += int(columns[10])
    index += 1

noOfFile = index - 1

file = open('../ymlPaths/Openstack.txt', 'r')

failure = 0
sloc = 0

for line in file:
    try:
        f = open(f'{line.strip()}', 'r')
        for l in f:
            if len(l.strip()) > 0:
                sloc += 1

    except:
        failure += 1


grand_total = hrd_sec_total + emp_pass_total + http_usg_total + \
    bind_usg_total + susp_com_total + int_chck_total
x = 0


print('=== OPENSTACK DATA ===')
pt = PrettyTable()

pt.field_names = ['smell', 'occurence', 'density', 'proportion']
pt.add_row(['HARD_CODE_SECR', f'{hrd_sec_total}',
            f'{hrd_sec_total/(sloc/1000):.2f}', f'{100*hard_secr_atLeastOne/noOfFile:.2f}'])
pt.add_row(['EMP_PASS', f'{emp_pass_total}', f'{emp_pass_total/(sloc/1000):.2f}',
            f'{100*emp_pass_atLeastOne/noOfFile:.2f}'])
pt.add_row(['HTTP_USG', f'{http_usg_total}', f'{http_usg_total/(sloc/1000):.2f}',
            f'{100*http_usg_atLeastOne/noOfFile:.2f}'])
pt.add_row(['BIND_USG', f'{bind_usg_total}', f'{bind_usg_total/(sloc/1000):.2f}',
            f'{100*bind_usg_atLeastOne/noOfFile:.2f}'])
pt.add_row(['SUSP_COMM', f'{susp_com_total}', f'{susp_com_total/(sloc/1000):.2f}',
            f'{100*sus_com_atLeastOne/noOfFile:.2f}'])
pt.add_row(['INTE_CHCK', f'{int_chck_total}', f'{int_chck_total/(sloc/1000):.2f}',
            f'{100*int_chk_atLeastOne/noOfFile:.2f}'])
pt.add_row(['HARD_CODE_UNAME', f'{hrd_unm_total}', f'N/A', f'N/A'])
pt.add_row(['HARD_CODE_PASS', f'{hrd_pass_total}', f'N/A', f'N/A'])
pt.add_row(['TOTAL', f'{grand_total}', f'{grand_total/(sloc/1000):.2f}',
            f'{100*atLeastOneSmell/noOfFile:.2f}'])

print(pt)
