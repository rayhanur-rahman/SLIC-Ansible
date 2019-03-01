file = open('ansible.txt', 'r')

seenStart = False
yamlSyntaxBegin = False
script = ''

def dump(text, fileName):
    file = open(f'/home/brokenquark/Workspace/SLIC-Ansible/ansible/{fileName}.yaml', 'w')
    file.write(text)
    file.close()
    return

counter = 1

for line in file:
    if ':::START!' in line: seenStart = True
    if line.startswith('**********') and seenStart:
        if not yamlSyntaxBegin:
            yamlSyntaxBegin = True
            continue
        else:
            yamlSyntaxBegin = False
            seenStart = False
            dump(script, f'script-{counter}')
            counter += 1
            script = ''

    if yamlSyntaxBegin:
        script = script + line

