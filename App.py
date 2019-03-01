import yaml

class Node:
    def __init__(self, key):
        self.key = key
        self.value = None
        self.children = []



stream = open('ex.yml', 'r')
yamlObject = yaml.load(stream)

print(yamlObject)


def traverse(dictionary, node):
    for key in dictionary:
        child = Node('')
        node.children.append(child)
        # print(key)
        child.key = key
        if isinstance(dictionary[key], dict):
            newChild = Node('')
            child.children.append(newChild)
            traverse(dictionary[key], newChild)
        if isinstance(dictionary[key], list):
            traverseList(dictionary[key], child)
        if isinstance(dictionary[key], str):
            # print(dictionary[key])
            child.value = dictionary[key]
        if isinstance(dictionary[key], int):
            # print(dictionary[key])
            child.value = dictionary[key]
        if isinstance(dictionary[key], float):
            # print(dictionary[key])
            child.value = dictionary[key]

def traverseList(ls, node):
    for item in ls:
        child = Node('')
        node.children.append(child)
        if isinstance(item, dict):
            traverse(item, child)
        if isinstance(item, list):
            traverseList(item, child)
        if isinstance(item, str):
            # print(item)
            child.value = item
        if isinstance(item, int):
            # print(item)
            child.value = item
        if isinstance(item, float):
            # print(item)
            child.value = item

root = Node('root')

if isinstance(yamlObject, list):
    for dictionary in yamlObject:
        traverse(dictionary, root)

if isinstance(yamlObject, dict):
    traverse(yamlObject, root)


print('###########\n')

def tree(node):
    print(f'{node.key}:{node.value}')
    if len(node.children) > 0:
        for child in node.children:
            tree(child)

tree(root)


def parseYaml(filename):
    