# Chef Repository for the Tubman Project

This Chef repository is used to automate the provisioning of server infrastructure for the [Tubman Project](http://www.tubmanproject.com).
Cookbooks in this repository will provision a server with Python, nginx, JupyterHub, MongoDB and other relevant Python libraries. They will also deploy a Python application to the server.

## Requirements

### User's Workstation

The user's workstation is the system, for example a users personal laptop, that the user will be interacting with Chef from.
* [Chef Development Kit](https://downloads.chef.io/chefdk) - A package that contains a collection of tools and libraries needed to start using Chef.
* [OpenSSL](https://github.com/openssl/openssl) - Used for generating an encrypted data bag key.
* [git](https://git-scm.com) - Used for version control. 

Optional requirements for local development:
* [Vagrant](https://www.vagrantup.com/downloads.html) - Tool for building and managing virtual machine environments.
	* [vagrant-omnibus](https://github.com/chef/vagrant-omnibus) - A vagrant plugin used for ensuring the desired version of Chef is installed.
	* [vagrant-hostmanager](https://github.com/devopsgroup-io/vagrant-hostmanager) - A Vagrant plugin used for managing host files on the users workstation.
	* [vagrant-berkshelf](https://github.com/berkshelf/vagrant-berkshelf) - A Vagrant plugin used for adding Berkshelf integration to Chef provisioners.
	* [vagrant-triggers](https://github.com/emyl/vagrant-triggers) - A Vagrant plugin that allows the definition of arbitrary scripts that will run on the host before and/or after Vagrant commands.
* [VirtualBox](https://www.virtualbox.org/wiki/Downloads) - Used to support the creation of virtual machines running versions of operating systems on a user's workstation.

### Virtual Machine

Provisioning of this Chef repository was done using a virtual machine running Ubuntu 16.04.

### Production Environments

Production environments require access to a Chef Server.  
There are options to use either a [managed](https://manage.chef.io/login) or [self-hosted](https://docs.chef.io/install_server.html) Chef-Server.
Usage of a Chef Server will also require the following pieces of information:
* Chef Client Key - A *.pem file downloaded from a Chef Server
* Chef Validation Key - A *.pem file downloaded from a Chef Server
* Chef Server URL - A URL that the chef-client on the user's workstation can connect to for downloading cookbooks and other information.
* `knife` - A command-line tool that provides an interface between a local chef-repo and the Chef server.

AWS instances are the example used for production environments.  Access to an EC2 instances running Ubuntu 16.04 is required for provisioning this repository to a production environment.

## Overview

### Repository Directories

This repository contains several directories that are used for managing and configuring the Chef environment.
* `.chef/` - A hidden directory that is used to store configuration files and sensitive information like the `encrypted_data_bag_secret`, Chef client key, and Chef validation key. The .gitignore file for this project targets files with sensitive information to be intentionally untracked.
* `data_bags/` - A directory used to store data bags of configurable information to be used when provisioning a machine.  The following data bags are used and require configuration before provisioning a machine with this Chef repo:
	* `data_bags/deploy` - Contains *.json files used to configure applications that will be deployed to Chef provisioned machines.
		* `app.json` - Deployment details for a Python application server.
		* `jupyterhub.json` - Deployment details for a multiuser Jupyter server.
	* `data_bags/secrets` - Contains *.json files required for configuration that contain information meant to be kept secret.  These data bags should not be under version control.
		* `aws.json` - Contains secret information relevant for provisioning AWS instances.
		* `data_bag.json` - Contains path's on the user's workstation that point to the `encrypted_data_bag_secret`.  Necessary for AWS provisioning.
		* `github.json` - Contains SSH private and public key information for github accounts.
		* `host_machine.json` - Contains the path to the project on the user's workstation.
		* `jupyterhub_users.json` - Contains user whitelists and admin lists for jupyterhub users.
		* `oauth.json` - Contains client id's and client secrets for OAuth applications
		* `openssl.json` - Contains distinguished name information for SSL certificates.
		* `ssh_keys.json` - Contains ssh key information for the user's workstation.
	* `data_bags/users` - Contains *.json files used to configure users for virtual machines. The ssh public key for the user's workstation is required to configure this data bag.
		* `supervisor.json` - Create's a supervisor user and group and adds the supervisor user to the www-data group.
		* `ubuntu.json` - Creates the default user for AWS SSH access.
		* `vagrant.json` - Creates the default user for local development access in a Vagrant machine.
* `environment/` - A directory used to store the files that define the environments that are available to the Chef server.
* `node_configuration/` - A directory that stores the configuration information that the user establishes for running virtual machines. These are referenced by the Vagrantfile.
* `nodes/` - A directory that stores configuration files for Chef nodes/virtual machines.  These files are generated by Chef-Solo and can include senstive information therefore this directory should not be under version control.
* `roles/` - A directory used to store the files that define the roles that are available to the Chef server.
* `wrapper_cookbooks/` - A directory used to store cookbooks written specifically for this project that orchestrates and includes recipes from other cookbooks.

### Wrapper Cookbooks

Wrapper cookbooks are cookbooks that have been written specifically for this project. 
Wrapper cookbooks extend the functionality of community cookbooks and orchestrate and configure provisioning and deployment.
See the readme in each cookbook found in the `wrapper_cookbooks/` directory.

* `tubmanproject_app` - Deploys Python application to the server and configures uWSGI.
* `tubmanproject_base` - Installs common packages and sets up environment variables for the virtual machine.
* `tubmanproject_github` - Sets up SSH wrappers for syncing Github repositories.
* `tubmanproject_jupyterhub` - Deploys JupyterHub multi-user environment.
* `tubmanproject_nginx` - Installs nginx.
* `tubmanproject_nodejs` - Installs NodeJS.
* `tubmanproject_openssl` - Generates a self signed certificate for each application to be deployed.
* `tubmanproject_python` - Installs Python.
* `tubmanproject_supervisor` - Installs Supervisor.
* `tubmanproject_mongodb` - Installs MongoDB.

#### Attributes

See the `attributes` directory of each wrapper cookbook.

#### Recipes

TBD

### Data Bags

Data bags are used to hold configuration information that is used to provision and deploy virtual machines.
Configuration of data bags is explained in the **Configuration** section below.

## Configuration

### General

Configuration is achieved through data bags. The instructions below should be followed to configure Chef with the details of your information.

#### Data Bags - Deploy

* `data_bags/deploy/app.json` - Data bag item that contains information for deploying and configuring Python applications.

The `data_bags/deploy/app.json` must be created in following format:
```
{
 "id" : "app",
 "development" : [
    {
      "subdomain" : "<YOUR_SUBDOMAIN>",
      "hostname" : "<YOUR_HOSTNAME>",
      "domain" : "<YOUR_DOMAIN>",
      "port" : <YOUR_PORT>,
      "nginx_config_template": "nginx.conf.erb",
	  "ssl": false,
	  "npm" : {
	  	"global": [],
	  	"local": []
	  },
	  "apt" : [],
	  "commands" : [],
	  "cron_jobs" : [],
      "git" : {
        "repository" : "git@github.com:tubmanproject/data_scraper.git",
        "branch" : "master"
      },
      "config" : {
      	"uwsgi" : {
      		"wsgi-file" : "/var/tubmanproject.dev/app/wsgi.py",
      		"protocol" : "uwsgi",
      		"module" : "wsgi",
      		"callable" : "app",
      		"master" : true,
      		"processes" : 1,
      		"threads" : 8,
      		"enable-threads" : true,
      		"die-on-term" : true,
      		"chmod-socket" : 666,
      		"vacuum" : true,
      		"disable-logging" : true,
      		"max-worker-lifetime" : 30	
      	}
      },
      "programs" : {
      	"uwsgi" : {
      		"command" : "/var/tubmanproject.dev/app/.venv/bin/uwsgi --ini /var/tubmanproject.dev/app/.uwsgi/app.ini",
      		"directory" : "/var/tubmanproject.dev/app",
      		"redirect_stderr" : true,
      		"stdout_logfile" : "/var/log/supervisor/uwsgi.log",
      		"stderr_logfile" : "/var/log/supervisor/uwsgi.error.log",
      		"autostart": true,
      		"autorestart": true,
      		"stopsignal": "QUIT"
      	}
      }
    }
  ],
  "staging" : [
    {
      ...
    }
  ],
  "production" : [
    {
      ...
    }
  ]
}
```
Create a JSON file `data_bags/deploy/app.json` in the format above and complete the file with your information.

TODO: describe JSON keys and values.

* `data_bags/deploy/jupyterhub.json` - Data bag item that contains information for deploying and configuring a JupyterHub Multi-User Environment.

The `data_bags/deploy/jupyterhub.json` must be created in following format:
```
{
 "id" : "jupyterhub",
 "development" : [
    {
      "subdomain" : "<YOUR_SUBDOMAIN>",
      "hostname" : "<YOUR_HOSTNAME>",
      "domain" : "<YOUR_DOMAIN>",
      "port" : <YOUR_PORT>,
      "nginx_config_template" : "jupyterhub-nginx.conf.erb",
	  "ssl" : false,
	  "npm" : {
	  	"global": ["configurable-http-proxy"],
	  	"local": []
	  },
	  "apt" : [],
	  "commands" : [
	  	"/var/tubmanproject.dev/jupyterhub/.venv/bin/jupyter contrib nbextension install --sys-prefix",
	  	"/var/tubmanproject.dev/jupyterhub/.venv/bin/jupyter nbextension enable --py widgetsnbextension --sys-prefix"
	  ],
      "git" : {
        "repository" : "git@github.com:tubmanproject/jupyterhub.git",
        "branch" : "master"
      },
      "config" : {
      	"jupyterhub" : {
      		"docker": {
      			"build": false,
      			"image": "jupyter/tensorflow-notebook",
      			"tag": "033056e6d164",
      			"run": []
      		}
      	}
      },
      "programs" : {
      	"jupyterhub" : {
      		"command" : "/var/tubmanproject.dev/jupyterhub/.venv/bin/jupyterhub -f /etc/jupyterhub/jupyterhub.tubmanproject.dev_config.py",
      		"directory" : "/var/tubmanproject.dev/jupyterhub",
      		"redirect_stderr" : true,
      		"stdout_logfile" : "/var/log/supervisor/jupyterhub.log",
      		"stderr_logfile" : "/var/log/supervisor/jupyterhub.error.log",
      		"autostart": true,
      		"autorestart": true,
      		"stopsignal": "QUIT"
      	}
      }
    }
  ],
  "staging" : [
	...
  ],
  "production" : [
	...
  ]
}
```
Create a JSON file `data_bags/deploy/jupyterhub.json` in the format above and complete the file with your information.

TODO: describe JSON keys and values.

#### Data Bags - Secrets

* `data_bags/secrets/aws.json` - Data bag item that contains secret information relevant for provisioning AWS instances.

The `data_bags/secrets/aws.json` data bag item is not saved in version control because it includes senstive information.  It must be created in following format:
```
{
	"id" : "aws",
	"aws_access_key_id" : "<YOUR_AWS_ACCESS_KEY_ID>",
	"aws_secret_access_key" : "<YOUR_AWS_SECRET_ACCESS_KEY>",
	"aws_key_path" : "~/.ssh",
	"aws_key_name" : "<YOUR_AWS_KEY_NAME>",
	"instance_type": "t2.small",
	"image_id": "ami-2c57433b",
	"region": "us-east-1"
}
```
Create a JSON file `data_bags/secrets/aws.json` in the format above and complete the file with your information.
	* aws_key_path - The location on the user's workstation where AWS keys are saved

* `data_bags/secrets/data_bag.json` - Data bag item that contains path's on the user's workstation that points to the `encrypted_data_bag_secret`.  Necessary for AWS provisioning.

The `data_bags/secrets/data_bag.json` data bag item is not saved in version control because it includes senstive information.  It must be created in following format:
```
{
	"id" : "data_bag",
	"local_path" : "/PATH/TO/PROJECT/chef-repo/.chef/encrypted_data_bag_secret",
	"relative_path": "chef-repo/.chef/encrypted_data_bag_secret"
}
```
Create a JSON file `data_bags/secrets/data_bag.json` in the format above and complete the file with your information.
	* local_path - the path the user's workstation to the `encrypted_data_bag_secret`.  Example: "/Users/<YOUR_NAME>/projects/genome_scipy/chef-repo/.chef/encrypted_data_bag_secret"
	* relative_path - the path to the `encrypted_data_bag_secret` relative to the project root on the the user's workstation.

* `data_bags/secrets/github.json` - Data bag item that contains public and private keys for remote Github access.

The `data-bags/secrets/github.json` data bag item is not saved in version control because it contains sensitive information.  It must be created in the following format:
```
{
	"id" : "github",
	"development" : {
		"keypair_path" : "/tmp/git/.ssh",
		"ssh_wrapper_filename" : "ssh_4_github.sh",
        "private_key_filename" : "github_chef_rsa",
        "public_key_filename" : "github_chef_rsa.pub",
        "private_key" : "<PRIVATE_KEY>",
        "public_key" : "<PUBLIC_KEY>"
	},
	"staging" : {
		...
	},
	"production" : {
		...
	}
}
```
Create a JSON file `data_bags/secrets/github.json` in the format above and complete the file with your information.

TODO: describe JSON keys and values.

* `data_bags/secrets/host_machine.json` - Data bag item that contains the path to the project on the user's workstation.

The `data_bags/secrets/host_machine.json` data bag item is not saved in version control because it includes senstive information.  It must be created in following format:
```
{
	"id" : "host_machine",
	"project_path" : "/PATH/TO/PROJECT"
}
```
Create a JSON file `data_bags/secrets/host_machine.json` in the format above and complete the file with your information.
	* project_path - the path the user's workstation to the project.  Example: "/Users/<YOUR_NAME>/projects/genome_scipy"

* `data_bags/secrets/jupyterhub_users.json` - Data bag item that contains whitelist and admin information for jupyterhub users.

The `data_bags/secrets/jupyterhub_users.json` data bag item is not saved in version control because it includes senstive information.  It must be created in following format:
```
{
	"id": "jupyterhub_users",
	"development": {
		"whitelist": ["list", "of", "whitelisted", "users"],
		"admin": ["list", "of", "whitelisted", "admin"]
	},
	"staging": {
		...
	},
	"production": {
		...
	}
}
```
Create a JSON file `data_bags/secrets/jupyterhub_users.json` in the format above and complete the file with your information.
	* whitelist - an array of usernames of whitelisted users
	* admin - an array of usernames of admin users

* `data_bags/secrets/oauth.json` - Data bag item that contains client secrets for OAuth applications.  Jupyterhub uses github authentication therefore a client id and client secret must be obtained from github.com.

The `data_bags/secrets/oauth.json` data bag item is not saved in version control because it includes senstive information.  It must be created in following format:
```
{
	"id": "oauth",
	"development": {
		"github": {
			"client_id": "<YOUR_GITHUB_CLIENT_ID>",
			"client_secret": "<YOUR_GITHUB_CLIENT_SECRET>"
		}
	},
	"staging": {
		...
	},
	"production": {
		...
	}
}
```
Create a JSON file `data_bags/secrets/openssl.json` in the format above and complete the file with your information.


* `data_bags/secrets/openssl.json` - Data bag item that contains distinguished name information for SSL certificates.

The `data_bags/secrets/openssl.json` data bag item is not saved in version control because it includes senstive information.  It must be created in following format:
```
{
	"id" : "openssl",
	"distinguished_name" : {
		"country" : "<COUNTRY>",
		"state" : "<STATE>",
		"locality" : "<LOCALITY>",
		"organization_name" : "<ORG_NAME>",
		"organizational_unit_name" : "<ORG_UNIT>",
		"common_name" : "<COMMON_NAME>",
		"email" : "<EMAIL>"
 	}
}
```
Create a JSON file `data_bags/secrets/openssl.json` in the format above and complete the file with your information.

* `data_bags/secrets/ssh_keys.json` - Data bag item that contains keys for SSH access from the user's workstation to the virtual machine instance.

The `data_bags/secrets/ssh_keys.json` data bag item is not saved in version control because it includes sensitive information.  It must be created in the following format:
```
{
	"id": "ssh_keys",
	"development": {
		"port": 22,
		"private_key_filename" : "<PRIVATE_KEY_FILENAME>",
        "public_key_filename" : "<PUBLIC_KEY_FILENAME>",
        "private_key" : "<PRIVATE_KEY>",
        "public_key" : "<PUBLIC_KEY>"
	},
	"staging": {
		...
	},
	"production": {
		...
	}
}
```
Create a JSON file `data_bags/secrets/ssh_keys.json` in the format above and complete the file with your information.

TODO: describe JSON keys and values.

#### Data Bags - Users

* `data_bags/users/<username>.json` - Data bag item that contains configuration information for creating virtual machine users.
Required users are `supervisor`, `vagrant` and `ubuntu`. The data bag item should be created in the following format.  Reference the [users](https://github.com/chef-cookbooks/users) community cookbook for configuration instructions.
```
{
    "id": "<username>",
    "ssh_keys": [
    	"<YOUR_PUBLIC_SSH_KEY>"
    ],
    "groups": ['group_1', 'group_2'],
    "shell": "/bin/bash"
}
```
Create a JSON file `data_bags/users/<username>.json` in the format above and complete the file with your information.
Your SSH public key is often found in the following location `~/.ssh/id_rsa.pub`.

#### Vagrant Node Configuration

Configure each node in a virtual machine environment by editing the JSON files located in the `chef-repo/node_configuration/` directory.

### Production

For a production environment using a Chef Server the `config.rb` file in the `.chef/` directory references environment variables in order to keep senstive information out of version controlled code.
The following environment variables should be created through the command line or permanently by editing the ` ~/.bash_profile` file.
```
$ export USER=<username>
$ export ORGNAME=<orgname>
$ export AWS_ACCESS_KEY_ID=<aws_access_key_id>
$ export AWS_SECRET_ACCESS_KEY=<aws_secret_access_key>
```

An `encrypted_data_bag_secret` is required for encrypting data bags that are uploaded to a Chef Server or encrypting data bags for saving in version control (not recommended).
Create an `encrypted_data_bag_secret` by running the following commands.
```
openssl rand -base64 512 | tr -d '\r\n' > /PATH/TO/PROJECT/.chef/encrypted_data_bag_secret
chmod 600 /PATH/TO/PROJECT/chef-repo/.chef/encrypted_data_bag_secret
```

Using `knife` it is possible to save encrypted data bag items to a file by redirecting the output of the `knife data bag show DATA_BAG_NAME DATA_BAG_ITEM` command. 
An example of saving an encrypted data bag item in version control is below:
```
$ cd /PATH/TO/PROJECT/chef-repo
$ knife data bag show secrets aws -Fj > data_bags/secrets/aws.json
git add /PATH/TO/PROJECT/chef-repo/data_bags/secrets/aws.json
git commit -m "Saved encrypted data bag for aws secrets"
``` 
Reference the [documentation](https://docs.chef.io/knife_data_bag.html) for `knife data bag` for more instructions on using the command.

## Usage

TBD

### Examples

TBD
