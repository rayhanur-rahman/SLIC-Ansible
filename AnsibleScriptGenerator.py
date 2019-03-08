file = open('ALL_OST_ANSIBLE_CONTENT.txt', 'r')

seenStart = False
yamlSyntaxBegin = False
script = ''

def dump(text, fileName):
    file = open(f'/home/brokenquark/Workspace/SLIC-Ansible/ansible/{fileName}', 'w')
    file.write(text)
    file.close()
    return

counter = 1

fileName = None

for line in file:
    if '/Users/akond' in line and fileName == None:
        fileName = '-'.join(line.strip().split('/'))[1:]
    if ':::START!' in line: seenStart = True
    if line.startswith('**********') and seenStart:
        if not yamlSyntaxBegin:
            yamlSyntaxBegin = True
            continue
        else:
            yamlSyntaxBegin = False
            seenStart = False
            dump(script, f'{fileName}')
            counter += 1
            script = ''
            fileName = None

    if yamlSyntaxBegin:
        script = script + line

