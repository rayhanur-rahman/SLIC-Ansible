SLIC-Ansible

The is the source code for Security Linter for Infrastructure as Code (SLIC) for Ansible Playbooks. SLIC is a static analysis tool that looks for security smells in infrastructure as code (IaC) scripts. This project is aimed to identify security smells in Ansible playbooks. 


The security smells are listed in the research paper available in paper/SLAC_JRNL_TSE2019.pdf: The paper is submitted for peer review. 

Here is the steps to reproduce the work:

Dependency: Python3.7

The src/RepoDownloader.py will download github repositories given the repo name and user name. However, you don't need to start over, the downloaded repos are already included. We worked with two set of repos: 1) openstack repos and 2) other repos which are available at github. First repos are saved at repo-openstack folder and second repos are saved at repo-github folder. The next steps are demonstrated for repo-github datasets.

Next, src/YmlPathGenerator.py will generate all the paths of all the .yml files. You just need to set the directory location in the script. The output file will be saved at ymlPaths folder (ymlPaths/github.txt).

After that, use the AnsibleSmellDetector.py to get the smell counts in each yml files. Just set the location of ymlPaths text file that was obtained from the very previous step (ymlPaths/github.txt). The output will saved on smellList folder (smellsList/github.csv). 

Finally, run the GetSmellStatistics.py, set the location of yml files (ymlPaths/github.txt) and output obtained from previous step (smellsList/github.csv) and you will see the result. 