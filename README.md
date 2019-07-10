SLIC-Ansible

The is the source code for Security Linter for Infrastructure as Code (SLIC) for Ansible Playbooks. SLIC is a static analysis tool that looks for security smells in infrastructure as code (IaC) scripts. This project is aimed to identify security smells in Ansible playbooks. 


The security smells are listed in the research paper available in paper/SLAC_JRNL_TSE2019.pdf: The paper is submitted for peer review. 

Here is the steps to reproduce the work:

Dependency: Python3.7

The src/repodownloader.py will download github repositories given the repo name and user name which is given in the repoList/repo-ansible.csv directory. After the downloading, the script will check the crietria mentioned in the paper and if the criteria are fulfilled, the repo will be kept, otherwise the repo will be deleted. 

The src/AnsibleSmellDetector.py will take the file location (which is stored in ymlPaths directory as a cvs file) of the ansible playbooks and outputs the smell occurrence and smell types in csv format which will be stored as csv file in rq1 folder.

Based on the output produced in the previous step, The src/rq2.py will take the csv file as input and calculate the number of smell occurrences, density, proportions and prints out the result in a table format.

