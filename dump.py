file = open('ansible-smell-count.csv', 'r')

index = 0

hs = 0
ep = 0
hu = 0
bu = 0
sc = 0
ic = 0
hun = 0
hp = 0

for line in file:
    if index > 0:
        columns = line.split(',')
        if int(columns[3]) > 0: hs += 1
        if int(columns[4]) > 0: ep += 1
        if int(columns[5]) > 0: hu += 1
        if int(columns[6]) > 0: bu += 1
        if int(columns[7]) > 0: sc += 1
        if int(columns[8]) > 0: ic += 1
        if int(columns[9]) > 0: hun += 1
        if int(columns[10]) > 0: hp += 1
    index += 1

x = 0