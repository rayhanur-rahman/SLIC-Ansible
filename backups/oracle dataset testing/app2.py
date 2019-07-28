file = open('ANSIBLE_FINAL_ORACLE_DATASET.csv', 'r')
index = 0
for line in file:
    if index > 0:
        fname = line.split(',')[1].strip()
        print(f'{fname}')
    index += 1

