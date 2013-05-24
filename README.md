The code contained in this project was created to solved a problem using [ansible](http://ansible.cc).

Tools like chef and puppet allows us to simplify the managing of large amount of servers. They are great in big scale but for an smaller scale not so. When you have to deal with specific cases, like doing custom configurations for smaller (like of one) group of servers, there ain't no simple way to achieve that.

We decided to keep on using chef for setting up and providing standard configuration on the servers while leaving the individual setup to ansible.

# Why ansible? 

First, because we already had in place all of the required infrastructure: an key-based ssh user with sudo access on all of the servers. The original idea was to create a file (json) for storing the configuration properties and write some custom code, using fabric or capistrano, for implementing the setup. Parsing the files, implementing the rules, and a bit more would had need some programming time. Lucky for us, we found ansible.

Ansible is low level enough not to require any fancy authentication schema, but high level enough to provide all of the basics operations you would need to do on a server. The configuration files are just plain text in yml format, as simple as it can be.

# The setup

Software development teams were working on different projects. Chef was used to deploy servers for different roles: a continuous integration server (jenkins), a web based app (django). 
Once the server was installed and basic configuration was done, ansible was used for handling the specific configurations required for each project.

The plan was to make the configuration available to more than one server since a project might start with one server but grow to require more, or just setup a new one on a different environment (dev/qa/int/prod).


# Workflow

For each new project, a directory was created. Each directory has a deploy.yml (ansible's playlist, like a chef's recipe) as well as all of the required files. 

A section on the ansible_hosts file should be added containing the hostnames of the servers belonging to the project using the project name as the name of the section.

Following the goal of infrastructure as goal, everything was versioned. Changing a file will invoque a git hook. There was a central git repository where everyone commit their code. A post-receive hook was used for that reason (for a local repository a post-commit hook would had been the choice). The hook parsed the modified files, extracting the top level directory from the file pathname. Ansible's command (ansible-playbook) was executed with the project's deploy.yml file.

The workflow was to create/edit files in the project's directory. Commit the changes and then, ansible took care of the deployment.




