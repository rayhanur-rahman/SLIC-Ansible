from dateutil import parser
# file = open('ALL_OST_ANSIBLE_CONTENT.txt', 'r')
#
# seenStart = False
# yamlSyntaxBegin = False
# script = ''
#
# def dump(text, fileName):
#     file = open(f'/home/brokenquark/Workspace/SLIC-Ansible/ansible/{fileName}', 'w')
#     file.write(text)
#     file.close()
#     return
#
# counter = 1
#
# fileName = None
#
# for line in file:
#     if '/Users/akond' in line and fileName == None:
#         fileName = '-'.join(line.strip().split('/'))[1:]
#     if ':::START!' in line: seenStart = True
#     if line.startswith('**********') and seenStart:
#         if not yamlSyntaxBegin:
#             yamlSyntaxBegin = True
#             continue
#         else:
#             yamlSyntaxBegin = False
#             seenStart = False
#             dump(script, f'{fileName}')
#             counter += 1
#             script = ''
#             fileName = None
#
#     if yamlSyntaxBegin:
#         script = script + line
#


file = open('output-updated.csv', 'r')
count = 0
dump = open('output-updated2.csv', 'w')
for line in file:
    if count == 0:
        count+=1
        continue
    # if count == 5: break
    list = line.split(',')
    dt = parser.parse(list[0])
    path = [x for x in list[1].split('/') if x.strip() != ''][0:-1]
    path = '/' + '/'.join(path)
    dump.write(f'{dt.year}-{dt.month},{path},{list[1].strip()},{list[2]},{list[3]},{list[4]},{list[5]},{list[6]},{list[7]},{list[8]},{list[9]},{list[10]}')
    count += 1
dump.close()

#MONTH,REPO_DIR,FILE_NAME,HARD_CODE_SECR,EMPT_PASS,HTTP_USAG,BIND_USAG,SUSP_COMM,INTE_CHCK,HARD_CODE_UNAME,HARD_CODE_PASS,TOTAL
