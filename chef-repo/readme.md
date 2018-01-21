# Chef Repository for the Tubman Project

This Chef repository is used to automate the provisioning of server infrastructure for the [Tubman Project](http://www.tubmanproject.com).
Cookbooks in this repository will deploy a server with Python applications for the Tubman Project API and JupyterHub as well as provision the following utilities:

* [MongoDB](https://www.mongodb.com/)
* [Redis](https://redis.io/)
* [RabbitMQ](https://www.rabbitmq.com/)
* [Celery](http://www.celeryproject.org/)
* [Python](https://www.python.org/) 2.7 and 3.6
* [Node.js](https://nodejs.org/)
* [HAProxy](http://www.haproxy.org/)
* [Docker](https://www.docker.com/)
* [NGINX](https://www.nginx.com/)
* [Supervisor](http://supervisord.org/)
* [uWSGI](https://uwsgi-docs.readthedocs.io/en/latest/)
* [git](https://git-scm.com/)

## Requirements

### User's Workstation

The user's workstation is the system, for example a users personal laptop, that the user will be interacting with Chef from.  The following software must be installed on a user's workstation to install the Tubman Project on both a local development environment or a remote server:

* [Chef Development Kit](https://downloads.chef.io/chefdk) - A package that contains a collection of tools and libraries needed to start using Chef.
* [OpenSSL](https://github.com/openssl/openssl) - Used for generating an encrypted data bag key.
* [git](https://git-scm.com) - Used for version control.

### Local Development

For local development the following software must also be installed on the user's workstation:

* [VirtualBox](https://www.virtualbox.org/wiki/Downloads) - Used to support the creation of virtual machines running versions of operating systems on a user's workstation.

* [Vagrant](https://www.vagrantup.com/downloads.html) - Tool for building and managing virtual machine environments.
	* [vagrant-omnibus](https://github.com/chef/vagrant-omnibus) - A vagrant plugin used for ensuring the desired version of Chef is installed.

		`$ vagrant plugin install vagrant-omnibus`

	* [vagrant-hostmanager](https://github.com/devopsgroup-io/vagrant-hostmanager) - A Vagrant plugin used for managing host files on the users workstation.

		`$ vagrant plugin install vagrant-hostmanager`

	* [vagrant-berkshelf](https://github.com/berkshelf/vagrant-berkshelf) - A Vagrant plugin used for adding Berkshelf integration to Chef provisioners.

		`$ vagrant plugin install vagrant-berkshelf`

	* [vagrant-triggers](https://github.com/emyl/vagrant-triggers) - A Vagrant plugin that allows the definition of arbitrary scripts that will run on the host before and/or after Vagrant commands.

		`$ vagrant plugin install vagrant-triggers`

	* Ubuntu 16.04 Vagrant box

	`$ vagrant box add bento/ubuntu-16.04`

### Remote Server

Installation of the Tubman Project on a remote server requires access to a Chef Server and an AWS EC2 instance.

#### Chef Server

There are two options for a chef server:  

* [managed](https://manage.chef.io/login) Chef Server
* [self-hosted](https://docs.chef.io/install_server.html) Chef Server

Usage of a Chef Server will also require the following pieces of information:
* Chef Client Key - A \*.pem file downloaded from a Chef Server.
* Chef Validation Key - A \*.pem file downloaded from a Chef Server.
* Chef Server URL - A URL that the chef-client on the user's workstation can connect to for downloading cookbooks and other information.
* `encrypted_data_bag_secret` - A secret used to encrypt data bags.
* `knife` - A command-line tool that provides an interface between a local chef-repo and the Chef server.

Reference the [Setting up a Chef Server](https://github.com/tubmanproject/chef-repo/chef-repo) section for further instructions.

#### AWS EC2 Instance

AWS instances are the example used for production environments.  Access to an EC2 instances running Ubuntu 16.04 is required for provisioning this repository to a production environment.

* Create an [AWS](https://aws.amazon.com/) account

* Create an [EC2 Key Pair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html) and save to a location like `~/.ssh`

* Create a `webserver` [security group](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-network-security.html) in your AWS account's EC2 dashboard with inbound rules open on ports 80, 443, and 22.

	**Note:** using a different name for the security group will require updating the chef repository's wrapper cookbooks.

* Set your `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` as [environment variables](https://docs.aws.amazon.com/cli/latest/userguide/cli-environment.html).  The `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` can be generated using these [instructions](https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html#access-keys-and-secret-access-keys).

## Overview

### Chef Repository Directories

This repository contains several directories that are used for managing and configuring the Chef environment.

* `.chef/` - A hidden directory that is used to store configuration files and sensitive information like the `encrypted_data_bag_secret` and Chef `.*pem` files. The `.gitignore` file for this project targets files with sensitive information to be intentionally untracked.

* `data_bags/` - A directory used to store data bags of configurable information to be used when provisioning a machine.  The following data bags are used and require configuration before provisioning a machine with this Chef repository:
	* `data_bags/deploy` - Contains \*.json files used to configure applications that will be deployed to Chef provisioned machines.
		* `app.json` - Deployment details for the Tubman Project API Python application.
		* `jupyterhub.json` - Deployment details for the multiuser JupyterHub application.
	* `data_bags/secrets` - Contains \*.json files required for configuration that contain information meant to be kept secret.  These data bags should not be under version control.
		* `aws.json` - Contains secret information relevant for provisioning AWS instances.
		* `data_bag.json` - Contains the path on the user's workstation that point to the `encrypted_data_bag_secret`.  Necessary for AWS provisioning.
		* `github.json` - Contains SSH private and public key information for github accounts.
		* `host_machine.json` - Contains the path to the project on the user's workstation.
		* `jupyterhub_users.json` - Contains user whitelists and admin lists for jupyterhub users.
		* `mongodb.json` - Contains sensitive MongoDB information like user and admin passwords and roles.
		* `oauth.json` - Contains client id's and client secrets for OAuth applications. GitHub OAuth is used for the JupyterHub.
		* `openssl.json` - Contains distinguished name information for SSL certificates.
		* `rabbitmq.json` - Contains sensitive RabbitMQ information like user passwords and permissions.
		* `redis.json` - Contains sensitive Redis information like passwords.
		* `ssh_keys.json` - Contains ssh key information for the user's workstation.
	* `data_bags/users` - Contains \*.json files used to configure users for virtual machines. The ssh public key for the user's workstation is required to configure this data bag.
		* `supervisor.json` - Create's a supervisor user and group and adds the supervisor user to the www-data group.
		* `ubuntu.json` - Creates the default user for AWS SSH access.
		* `vagrant.json` - Creates the default user for local development access in a Vagrant machine.

* `environment/` - A directory used to store the files that define the environments that are available to the Chef server.

* `node_configuration/` - A directory that stores the configuration information that the user establishes for running local development virtual machines. These are referenced by the Vagrantfile.

* `roles/` - A directory used to store the files that define the roles that are available to the Chef server.

* `wrapper_cookbooks/` - A directory used to store cookbooks written specifically for this project that orchestrates and includes recipes from other cookbooks.

* `cookbooks/` - A directory where cookbooks are copied to using [Berkshelf](https://docs.chef.io/berkshelf.html). Berkshelf downloads dependencies from the Chef supermarket. Cookbooks must be in this directory to upload to a Chef Server.

### Wrapper Cookbooks

Wrapper cookbooks are cookbooks that have been written specifically for this project.

Wrapper cookbooks extend the functionality of community cookbooks, downloaded from the Chef Supermarket.  They configure provisioning and deployment.

* `tubmanproject_app` - Deploys the Tubman Project API, a Python application, to the server and configures uWSGI.
* `tubmanproject_aws` - Provisions an AWS EC2 instance and deployes the Tubman Project API application and JupyterHub.
* `tubmanproject_base` - Installs common packages and sets up environment variables for the virtual machine.
* `tubmanproject_docker` - Installs Docker and the Jupyter Image used to spawn Jupyter notebooks in the JupyterHub application.
* `tubmanproject_github` - Sets up SSH wrappers for syncing Github repositories.
* `tubmanproject_haproxy` - Installs HAProxy and configures its usage with applications like Redis and RabbitMQ.
* `tubmanproject_hosts` - Sets up the `/etc/hosts` file for a remote server.
* `tubmanproject_jupyterhub` - Deploys JupyterHub multi-user environment.
* `tubmanproject_mongodb` - Installs and configures MongoDB.
* `tubmanproject_nginx` - Installs NGINX.
* `tubmanproject_nodejs` - Installs NodeJS.
* `tubmanproject_python` - Installs Python.
* `tubmanproject_rabbitmq` - Installs and configures RabbitMQ.
* `tubmanproject_redis` - Installs and configures Redis.
* `tubmanproject_supervisor` - Installs Supervisor.

### Data Bags

Data bags are used to hold configuration information that is used to provision and deploy virtual machines.
Configuration of data bags is explained in the **Configuration** section below.

## Configuration

Configuration is achieved through data bags. The instructions below should be followed to configure Chef with the details of your information.

### Data Bags

#### Deploy - Data Bag

The **deploy** data bag contains configuration details necessary for deploying and configuring applications.  The deploy data bag contains non-sensitive information that is okay for saving in version control.  Deploy contains the following data bag items:

* app
* jupyterhub

##### app

The `data_bags/deploy/app.json` data bag item contains information necessary for deploying and configuring the Tubman Project API application.

The `data_bags/deploy/app.json` must be created in following format:
```
{
 "id" : "app",
 "development" : [
	 {
		 "subdomain" : "api",
		 "hostname" : "tubmanproject-api-development",
		 "domain" : "tubmanproject.test",
		 "port" : 5001,
		 "nginx_config_template": "nginx.conf.erb",
		 "ssl": false,
		 "acme_cert": {
			 "requested": false,
			 "challenge": "tls-sni-01"
		 },
		 "jupyter": true,
		 "npm" : {
			 "global": [],
			 "local": []
		 },
		 "apt" : [],
		 "commands" : [
			 "sudo -E /var/tubmanproject.test/api/.venv/bin/flask initdb",
			 "find /var/tubmanproject.test/api/ -type d -exec sudo chown -R www-data:www-data {} \\;",
			 "find /var/tubmanproject.test/api/ -type f -exec sudo chmod -R 644 {} \\;",
			 "find /var/tubmanproject.test/api/.venv -type f -exec sudo chmod -R 755 {} \\;",
			 "find /var/log/api.tubmanproject.test/ -type f -exec sudo chown -R www-data:supervisor {} \\;",
			 "find /var/log/api.tubmanproject.test/ -type f -exec sudo chmod -R 664 {} \\;",
			 "sudo chmod -R g+rws /var/tubmanproject.test/api/app/templates/jupyter_notebooks",
			 "sudo setfacl -dR -m g::rwx /var/tubmanproject.test/api/app/templates/jupyter_notebooks"
		 ],
		 "cron_jobs" : [
			 {
				 "name" : "tubmanproject-scrape_disposition-today",
				 "command" : "/var/tubmanproject.test/api/.venv/bin/flask scrape --type disposition",
				 "minute" : "15",
				 "hour" : "17",
				 "day" : "*",
				 "month" : "*",
				 "weekday" : "*",
				 "mailto" : ""
			 },
			 {
				 "name" : "tubmanproject-scrape_filing-today",
				 "command" : "/var/tubmanproject.test/api/.venv/bin/flask scrape --type filing",
				 "minute" : "30",
				 "hour" : "17",
				 "day" : "*",
				 "month" : "*",
				 "weekday" : "*",
				 "mailto" : ""
			 }
		 ],
		 "git" : {
			 "repository" : "git@github.com:tubmanproject/tubmanproject_api.git",
			 "branch" : "develop"
		 },
		 "config" : {
			 "uwsgi" : {
				 "wsgi-file" : "/var/tubmanproject.test/api/wsgi.py",
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
				 "command" : "/var/tubmanproject.test/api/.venv/bin/uwsgi --ini /var/tubmanproject.test/api/.uwsgi/app.ini",
				 "directory" : "/var/tubmanproject.test/api",
				 "redirect_stderr" : true,
				 "stdout_logfile" : "/var/log/supervisor/uwsgi.log",
				 "stderr_logfile" : "/var/log/supervisor/uwsgi.error.log",
				 "autostart": true,
				 "autorestart": true,
				 "stopsignal": "QUIT"
			 },
			 "celery": {
				 "command" : "/var/tubmanproject.test/api/.venv/bin/celery -A run_celery_worker.celery worker -l info --logfile=/var/log/celery/%%n-%%i.log --pidfile=/var/run/celery/%%n.pid",
				 "directory" : "/var/tubmanproject.test/api",
				 "redirect_stderr" : true,
				 "stdout_logfile" : "/var/log/supervisor/celery.log",
				 "stderr_logfile" : "/var/log/supervisor/celery.error.log",
				 "autostart": true,
				 "autorestart": true,
				 "startsecs" : 10,
				 "stopwaitsecs" : 600,
				 "killasgroup": true,
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

##### jupyterhub

The `data_bags/deploy/jupyterhub.json` data bag item contains information necessary for deploying and configuring the JupyterHub application.

The `data_bags/deploy/jupyterhub.json` must be created in following format:
```
{
 "id" : "jupyterhub",
 "development" : [
	 {
		 "subdomain" : "jupyterhub",
		 "hostname" : "tubmanproject-jupyterhub-development",
		 "domain" : "tubmanproject.test",
		 "port" : 5010,
		 "nginx_config_template" : "jupyterhub-nginx.conf.erb",
	 "ssl" : false,
	 "acme_cert": {
		 "requested": false,
		 "challenge": "http-01"
	 },
	 "npm" : {
		 "global": ["configurable-http-proxy"],
		 "local": []
	 },
	 "apt" : [],
	 "commands" : [],
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
				 "command" : "/var/tubmanproject.test/jupyterhub/.venv/bin/jupyterhub -f /etc/jupyterhub/jupyterhub.tubmanproject.test_config.py",
				 "directory" : "/var/tubmanproject.test/jupyterhub",
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

#### Secrets - Data Bag

The **secrets** data bag contains sensitive configuration details necessary for deploying and configuring applications.  Because of the sensitive nature of the contents of the **secrets** data bag the information in this data bag should not be saved in version control.  

**Note:** *The contents of the secrets data bag can be encrypted with the `encrypted_data_bag_secret` and saved to version control but it is not recommended.*

Secrets contains the following data bag items:

* aws
* data_bag
* github
* host_machine
* jupyterhub_users
* mongodb
* oauth
* openssl
* rabbitmq
* redis
* ssh_keys

##### aws

The `data_bags/secrets/aws.json` data bag item contains secret information relevant for provisioning AWS instances.

The `data_bags/secrets/aws.json` must be created in following format:
```
{
	"id" : "aws",
	"aws_access_key_id" : <AWS_ACCESS_KEY_ID>,
	"aws_secret_access_key" : <AWS_SECRET_ACCESS_KEY>,
	"aws_key_path" : <AWS_KEY_PATH>,
	"aws_key_name" : <AWS_KEY_NAME>,
	"instance_type": <INSTANCE_TYPE>,
	"image_id": <IMAGE_ID>,
	"region": <REGION>
}
```

Create a JSON file `data_bags/secrets/aws.json` in the format above and complete the file with your information.

* AWS_ACCESS_KEY_ID - The AWS_ACCESS_KEY_ID from your AWS account.

* AWS_SECRET_ACCESS_KEY - The AWS SECRET ACCESS KEY from your AWS account.

* AWS_KEY_PATH - The path on your local workstation to the directory holding your AWS key.

	example: `"aws_key_path" : "~/.ssh"`

* AWS_KEY_NAME - The name of the AWS key pair you created for this project.

	example: `"aws_key_name" : "tubmanproject"`

* INSTANCE_TYPE - The type of AWS EC2 instance that you want to provision.

	example :`"instance_type": "t2.small"`

* IMAGE_ID - The AWS image id you want running on your EC2 instance, i.e. the operating system.

	example: `"image_id": "ami-b391b9c8"`

* REGION - The region you want to run an EC2 instance in.

	example: `"region": "us-east-1"`

##### data_bag

The `data_bags/secrets/data_bag.json` data bag item contains the path on the user's workstation that point to the `encrypted_data_bag_secret`.  Necessary for AWS provisioning.

The `data_bags/secrets/data_bag.json` must be created in following format:
```
{
	"id" : "data_bag",
	"local_path" : "/ABSOLUTE/PATH/TO/myproject/chef-repo/.chef/encrypted_data_bag_secret",
	"relative_path": "chef-repo/.chef/encrypted_data_bag_secret"
}
```
Create a JSON file `data_bags/secrets/data_bag.json` in the format above and complete the file with your information.

* local_path - The path on the user's local workstation where the `encrypted_data_bag_secret` is saved.  Chef copies this file to your remote server or virtual machine.

* relative_path - The path to the `encrypted_data_bag_secret` relative to the project's root.

##### github

The `data_bags/secrets/github.json` data bag item contains SSH private and public key information for github accounts.

The `data_bags/secrets/github.json` must be created in following format:
```
{
	"id" : "github",
	"development" : {
		"keypair_path" : <KEYPAIR_PATH>,
		"ssh_wrapper_filename" : <SSH_WRAPPER_FILENAME>,
    "private_key_filename" : <PRIVATE_KEY_FILENAME>,
    "public_key_filename" : <PUBLIC_KEY_FILENAME>,
    "private_key" : <PRIVATE_KEY>,
    "public_key" : <PUBLIC_KEY>
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

* KEYPAIR_PATH - The path on the remote server or local development virtual machine where the github keypair will be saved.

	example: `"keypair_path" : "/tmp/git/.ssh"`

* SSH_WRAPPER_FILENAME - The filename of an ssh wrapper, a bash script, that is used by Chef to tell the Chef client how to handle GitHub's public fingerprint and authenticate with a private key. The file is created with a Chef template in the "tubmanproject_github::ssh-wrapper" recipe and saved in the KEYPAIR_PATH.

	example: `"ssh_wrapper_filename" : "ssh_4_github.sh"`

* PRIVATE_KEY_FILENAME - The filename of the github private key.  The file is created with a Chef template in the "tubmanproject_github::ssh-wrapper" recipe and saved in the KEYPAIR_PATH.

	example: `"private_key_filename" : "github_chef_rsa"`

* PUBLIC_KEY_FILENAME - The filename of the github public key.  The file is created with a Chef template in the "tubmanproject_github::ssh-wrapper" recipe and saved in the KEYPAIR_PATH.

	example: `"public_key_filename" : "github_chef_rsa.pub"`

* PRIVATE_KEY - The contents of the GitHub private key. The private key can be obtained from the GitHub account hosting the application repositories. The newlines in the private key should be represented as `\n` because `json` doesn't allow newlines.

	example: `private_key" : "-----BEGIN RSA PRIVATE KEY-----\n...\n-----END RSA PRIVATE KEY-----\n"`

* PUBLIC_KEY - The contents of the GitHub public key. The public key can be obtained from the GitHub account hosting the application repositories. The newlines in the public key should be represented as `\n` because `json` doesn't allow newlines.

	example: `public_key" : "ssh-rsa...Nw== user@example.com\n"`

##### host_machine

The `data_bags/secrets/host_machine.json` data bag item contains the path to the project on the user's workstation.  Necessary for AWS provisioning.

The `data_bags/secrets/host_machine.json` must be created in following format:
```
{
	"id" : "host_machine",
	"project_path" : "/ABSOLUTE/PATH/TO/myproject"
}
```
Create a JSON file `data_bags/secrets/host_machine.json` in the format above and complete the file with your information.

* project_path - The path on the user's local workstation where the project is saved.

##### jupyterhub_users

The `data_bags/secrets/jupyterhub_users.json` data bag item contains user whitelists and admin lists for jupyterhub users.

The `data_bags/secrets/jupyterhub_users.json` must be created in following format:
```
{
	"id": "jupyterhub_users",
	"development": {
		"whitelist": ["<GITHUB_USERNAME_1>", "<GITHUB_USERNAME_2>", "<GITHUB_USERNAME_3>"],
		"admin": ["<GITHUB_USERNAME_1>", "<GITHUB_USERNAME_2>", "<GITHUB_USERNAME_3>"]
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

* whitelist - An array of GitHub usernames that are permitted to use the JupyterHub.

* admin - An array of GitHub usernames that are JupyterHub admin users. JupyterHub admin users can add additional whitelisted users later in the JupyterHub application.

##### mongodb

The `data_bags/secrets/mongodb.json` data bag item contains sensitive MongoDB information like user and admin passwords and roles.

The `data_bags/secrets/mongodb.json` must be created in following format:
```
{
	"id": "mongodb",
	"development": {
		"hostname": <MONGODB_HOSTNAME>,
		"domain": <MONGODB_DOMAIN>,
		"port": <MONGODB_PORT>,
		"admin": {
			"username": <MONGODB_ADMIN_USER>,
			"password": <MONGODB_ADMIN_PASSWORD>,
			"roles": <MONGODB_ROLES>,
			"database": <MONGODB_ADMIN_DATABASE>
		},
		"users": [
			{
				"database": <MONGDB_DATABASE>,
				"username": <MONGODB_USERNAME>,
				"password": <MONGODB_USER_PASSWORD>,
				"roles": <MONGODB_ROLES>
			}
		]
	},
	"staging": {
		...
	},
	"production": {
		...
	}
}
```
Create a JSON file `data_bags/secrets/mongodb.json` in the format above and complete the file with your information.

* users - an array of hashes of MongoDB users that should be created.  There must be at least one user with a `username` and `database` that matches the Tubman Project API hostname set in the deploy data bag's app data bag item.  The Tubman Project API application's configuration depends on this match to connect to the MongoDB.

	example:
	```
	{
		"database": "tubmanproject-api-development",
		"username": "tubmanproject-api-development",
		"password": "SuperSecretPassword12345",
		"roles": ["readWrite"]
	}
	```
* MONGODB_HOSTNAME - The hostname of the MongoDB instance. Used to set the `CN` of the `--sslPEMKeyFile` certificate for the `mongod` process and match the host option of the mongo command for MongoDB clients using SSL `mongo --ssl --host hostname.example.com`.

	example: `"hostname": "mongodb"`

* MONGODB_DOMAIN - The domain of the MongoDB instance. Used to set the `CN` of the `--sslPEMKeyFile` certificate for the `mongod` process and match the host option of the mongo command for MongoDB clients using SSL `mongo --ssl --host hostname.example.com`.

	example: `"domain": "tubmanproject.test"`

* MONGODB_PORT - The the port `mongod` listens on.

	example: `"port": 27017`

* MONGODB_ADMIN_USER - The username of a MongoDB admin user.

	example: `"admin.username": "tubmanprojectAdmin"`

* MONGODB_ADMIN_PASSWORD - The password for the MongoDB admin user.

	example: `"admin.password": "SuperSecretPassword12345"`

* MONGODB_ADMIN_DATABASE - The database for the MongoDB admin user.

	example: `"admin.database": "admin"`

* MONGODB_USERNAME - The username of a MongoDB user.

	example: `"username": "tubmanproject-api-development"`

* MONGODB_USER_PASSWORD - The password for the MongoDB user.

	example: `"password": "SuperSecretPassword12345"`

* MONGODB_DATABASE - The database for the MongoDB user.

	example: `"database": "tubmanproject-api-development"`

* MONGODB_ROLES - An array of roles available to the MongoDB user on the designated database.

	example: `"roles": ["userAdmin", "userAdminAnyDatabase", "dbAdminAnyDatabase", "clusterAdmin"]`
	example: `"roles": ["readWrite"]`

##### oauth

The `data_bags/secrets/oauth.json` data bag item contains client id's and client secrets for OAuth applications. GitHub OAuth is used for the JupyterHub.

The `data_bags/secrets/oauth.json` must be created in following format:
```
{
	"id": "oauth",
	"development": {
		"github": {
			"client_id": <OAUTH_CLIENT_ID>,
			"client_secret": <OAUTH_CLIENT_SECRET>
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
GitHub is used as an OAuth application for JupyterHub authentication.  Create an OAuth application in GitHub by following the following instructions:

* [GitHub instructions](https://developer.github.com/apps/building-oauth-apps/)
* [JupyterHub instructions](https://github.com/jupyterhub/oauthenticator#github-setup)

Create a JSON file `data_bags/secrets/oauth.json` in the format above and complete the file with your information.

* OAUTH_CLIENT_ID - OAuth Client ID obtained from GitHub.

* OAUTH_CLIENT_SECRET - OAuth Client Secret obtained from GitHub.

##### openssl

The `data_bags/secrets/openssl.json` data bag item contains distinguished name information for SSL certificates.

The `data_bags/secrets/openssl.json` must be created in following format:
```
{
	"id" : "openssl",
	"distinguished_name" : {
		"country" : <COUNTRY>,
		"state" : <STATE>,
		"locality" : <LOCALITY>,
		"organization_name" : <ORGNAME>,
		"organizational_unit_name" : <ORGUNIT>,
		"common_name" : "",
		"email" : <EMAIL>
 	}
}
```
Create a JSON file `data_bags/secrets/openssl.json` in the format above and complete the file with your information.

* COUNTRY - 2 character country/region code.

	example: `"country" : "US"`

* COUNTRY - state.

	example: `"state" : "Texas"`

* LOCALITY - locality.

	example: `"locality" : "Houston"`

* ORGNAME - organization name.

	example: `"organization_name" : "Minty Ross LLC"`

* ORGUNIT - organizational unit.

	example: `"organizational_unit_name" : "Engineering"`

* EMAIL - email address.

	example: `"email" : "user@example.com"`

##### rabbitmq

The `data_bags/secrets/rabbitmq.json` data bag item contains sensitive RabbitMQ information like user passwords and permissions.

The `data_bags/secrets/rabbitmq.json` must be created in following format:
```
{
	"id" : "rabbitmq",
	"development" : {
    "hostname": <RABBITMQ_HOSTNAME>,
		"domain": <RABBITMQ_DOMAIN>,
    "cluster_name" : <RABBITMQ_CLUSTERNAME>,
		"cluster_nodes" : [
			{
				"nodename" : <RABBITMQ_NODENAME>,
				"port" : <RABBITMQ_PORT,
				"type" : RABBITMQ_NODE_TYPE
			}
		],
		"applications" : [
			{
				"vhost" : <RABBITMQ_VHOST>,
				"users" : [
					{
						"username" : <RABBITMQ_USERNAME>,
						"password" : <RABBITMQ_PASSWORD>,
						"permissions" : {
							"conf" : <RABBITMQ_PERMISSION>,
							"write" : <RABBITMQ_PERMISSION>,
							"read" : <RABBITMQ_PERMISSION>
						}
					}
				]
			}
		]
	},
	"staging" : {
    ...
	},
	"production" : {
    ...
	}
}
```
Create a JSON file `data_bags/secrets/mongodb.json` in the format above and complete the file with your information.

* RABBITMQ_HOSTNAME - The hostname of the RabbitMQ instance.

	example: `"hostname": "rabbitmq"`

* RABBITMQ_DOMAIN - The domain of the RabbitMQ instance.

	example: `"domain": "tubmanproject.test"`

* RABBITMQ_CLUSTERNAME - When RabbitMQ clusters are used this is the name of the RabbitMQ cluster set by the RabbitMQ command line tool `rabbitmqctl set_cluster_name RABBITMQ_CLUSTERNAME`.

	example: `"cluster_name" : "rabbitmq_cluster"`

* cluster_nodes - an array of hashes of RabbitMQ nodes that should be created.

	example:
	```
	{
		"nodename" : "rabbit1",
		"port" : 5672,
		"type" : "disc"
	}
	```

* RABBITMQ_NODENAME - The name of the RabbitMQ node.

	example: `"nodename" : "rabbit1"`

* RABBITMQ_PORT - The port the RabbitMQ node is listening on.

	example: `"port" : 5672,`

* RABBITMQ_NODE_TYPE - Type type of node in the RabbitMQ cluster.  Can be either `disc` which replicates data in RAM and on disc, thus providing redundancy or `ram` which replicates data in RAM only.

	example: `"type" : "disc"`

* applications - An array of hashes of RabbitMQ virtual hosts that should be created. There must be at least one application with a `vhost` that matches the Tubman Project API hostname set in the deploy data bag's app data bag item.  The Tubman Project API application's configuration depends on this match to connect to RabbitMQ.

	example:
	```
	{
		"vhost" : "tubmanproject-api-development",
		"users" : [
			{
				"username" : "tubmanproject",
				"password" : "SuperSecretPassword12345",
				"permissions" : {
					"conf" : ".*",
					"write" : ".*",
					"read" : ".*"
				}
			}
		]
	}
	```

* users - An array of hashes of RabbitMQ users that will be allowed to access the virtual host.

	example:
	```
	{
		"username" : "tubmanproject",
		"password" : "SuperSecretPassword12345",
		"permissions" : {
			"conf" : ".*",
			"write" : ".*",
			"read" : ".*"
		}
	}
	```

* permissions - A hash of the permissions a user is granted on a virtual host.  The permissions are configure, read, and write.

	example:
	```
	{
		"conf" : ".*",
		"write" : ".*",
		"read" : ".*"
	}
	```

* RABBITMQ_VHOST - The name of the virtual host that an application or user is using to connect to RabbitMQ.

	example: `"vhost" : "tubmanproject-api-development"`

* RABBITMQ_USERNAME - The name of the user or application that is connecting to RabbitMQ through a virtual host.

	example: `"username" : "tubmanproject"`

* RABBITMQ_PASSWORD - The user or application password that is used to authenticate to RabbitMQ.

	example: `"password" : "SuperSecretPassword12345"`

* RABBITMQ_PERMISSION - The permission granted to the user. Reference [RabbitMQ Access Control](https://www.rabbitmq.com/access-control.html) documentation.

	example: `"conf" : ".*"`

##### redis

The `data_bags/secrets/redis.json` data bag item contains sensitive Redis information like passwords.

The `data_bags/secrets/redis.json` must be created in following format:
```
{
	"id" : "redis",
	"development" : {
    "hostname": <REDIS_HOSTNAME>,
		"domain": <REDIS_DOMAIN>,
		"master" : {
			"name" : <REDIS_MASTER_NAME>,
			"port" : <REDIS_MASTER_PORT>,
			"password" : <REDIS_MASTER_PASSWORD>
		},
		"replicas" : [
			{
				"name" : <REDIS_REPLICA_NAME>,
				"port" : <REDIS_REPLICA_PORT>,
				"masterauth" : <REDIS_MASTER_PASSWORD>
			}
		]
	},
	"staging" : {
    ...
	},
	"production" : {
    ...
	}
}
```
Create a JSON file `data_bags/secrets/redis.json` in the format above and complete the file with your information.

* REDIS_HOSTNAME - The hostname of the Redis instance.

	example: `"hostname": "redis"`

* REDIS_DOMAIN - The domain of the Redis instance.

	example: `"domain": "tubmanproject.test"`

* REDIS_MASTER_NAME - The name of the master Redis instance.  The Redis instance will be running as a service under `redis@REDIS_MASTER_NAME.REDIS_DOMAIN # redis@redis-master.tubmanproject.test`

	example: `"name" : "redis-master"`

* REDIS_MASTER_PORT - The port that the master Redis instance is listening on.

	example: `"port" : 6379`

* REDIS_MASTER_PASSWORD - The password for the master Redis instance.

	example: `"password" : "SuperSecretPassword12345"`

* replica - An array of hashes of Redis slave/replica instances.

 	example:
	```
	{
		"name" : "redis-replica-1",
		"port" : 6780,
		"masterauth" : "SuperSecretPassword12345"
	}
	```

* REDIS_REPLICA_NAME - The name of the replica Redis instance. The Redis instance will be running as a service under `redis@REDIS_REDIS_NAME.REDIS_DOMAIN # redis@redis-replica-1.tubmanproject.test`

	example: `"name" : "redis-replica-1"`

* REDIS_REPLICA_PORT - The port that the replica Redis instance is listening on.

	example: `"port" : 6380`

##### ssh_keys

The `data_bags/secrets/ssh_keys.json` data bag item contains ssh key information for the user's workstation that you would like copied to the remote server or local development virtual machine.

The `data_bags/secrets/ssh_keys.json` must be created in following format:
```
{
	"id": "ssh_keys",
	"development": {
		"port": <PORT>,
		"private_key_filename" : <PRIVATE_KEY_FILENAME>,
    "public_key_filename" : <PUBLIC_KEY_FILENAME>,
    "private_key" : <PRIVATE_KEY>,
    "public_key" : <PUBLIC_KEY>
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

* PORT - The port that is listening for ssh connections.

	example: `"port": 22`

* PRIVATE_KEY_FILENAME - The filename of the private key.

	example: `"private_key_filename" : "tubmanproject.pem"`

* PUBLIC_KEY_FILENAME - The filename of the public key.

	example: `"public_key_filename" : "tubmanproject.pub"`

* PRIVATE_KEY - The contents of the private key. The newlines in the private key should be represented as `\n` because `json` doesn't allow newlines.

	example: `private_key" : "-----BEGIN RSA PRIVATE KEY-----\n...\n-----END RSA PRIVATE KEY-----\n"`

* PUBLIC_KEY - The contents of the public key. The newlines in the public key should be represented as `\n` because `json` doesn't allow newlines.

	example: `public_key" : "ssh-rsa...Nw== user@example.com\n"`

#### Users - Data Bag

The **users** data bag contains information necessary for creating system users and groups.  The users data bag contains non-sensitive information that is okay for saving in version control.  Users contains the following data bag items:

* supervisor
* ubuntu
* vagrant

Additional users and groups can be created as needed by creating additional data bag items.  See the Chef [users cookbook](https://github.com/chef-cookbooks/users) for instructions on creating additional users and groups.

The general format for creating data bag items in the users data bag is to create a  `data_bags/users/<username>.json` file that contains configuration information for creating remote server or virtual machine users.

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

##### supervisor

The `data_bags/users/supervisor.json` data bag item contains information necessary for creating an "supervisor" system user and adding that user to the necessary system groups.

The `data_bags/users/supervisor.json` must be created in following format:
```
{
    "id": "supervisor",
    "ssh_keys": [],
    "groups": ["supervisor", "www-data", "config-secrets"],
    "shell": "/bin/bash"
}
```
Create a JSON file `data_bags/users/supervisor.json` in the format above and complete the file with your information.

##### ubuntu

The `data_bags/users/ubuntu.json` data bag item contains information necessary for creating an "ubuntu" system user and adding that user to the necessary system groups.

The `data_bags/users/ubuntu.json` must be created in following format:
```
{
    "id": "ubuntu",
    "ssh_keys": [],
    "groups": [],
    "shell": "/bin/bash"
}
```
Create a JSON file `data_bags/users/ubuntu.json` in the format above and complete the file with your information.

##### vagrant

The `data_bags/users/vagrant.json` data bag item contains information necessary for creating an "vagrant" system user and adding that user to the necessary system groups.

The `data_bags/users/vagrant.json` must be created in following format:
```
{
    "id": "vagrant",
    "ssh_keys": [],
    "groups": [],
    "shell": "/bin/bash"
}
```
Create a JSON file `data_bags/users/vagrant.json` in the format above and complete the file with your information.

### Vagrant Node

For local development on a virtual machine the Vagrant node must be configured.  Configure each node in a virtual machine environment by editing the JSON files located in the `node_configuration/` directory.

Edit the `tubmanproject.json` file to setup [hostnames and aliases](https://github.com/devopsgroup-io/vagrant-hostmanager), [port forwarding](https://www.vagrantup.com/docs/networking/forwarded_ports.html), and [synced folders](https://www.vagrantup.com/docs/synced-folders/) for the Vagrant virtual machine.

## Setting up a Chef Server

Provisioning a local virtual machine or remote server with Chef Server will require uploading the configuration details defined in your local `chef-repo` to a remote [Chef Server](https://docs.chef.io/server_components.html) and then using the configuration details on the remote Chef Server to provision a virtual machine or remote server and deploy applications.

There are two options for a Chef Server:

* [managed](https://manage.chef.io/login) Chef Server
* [self-hosted](https://docs.chef.io/install_server.html) Chef Server.

### Prerequisites

Using a Chef Server requires access to a Chef Server.  Sign up for a free trial of a [managed](https://manage.chef.io/login) Chef Server or set up a [self-hosted](https://docs.chef.io/install_server.html) Chef Server.

Once you have a Chef Server up and running that you can sign into you need to create a `validation_key` and a `client_key`.

#### Create a Validation Key

Create a `validation_key` by following the instructions in the [Chef documentation](https://docs.chef.io/server_manage_clients.html) create a client key.

Your `validation_key` should be named in the following format `ORGNAME-validator.pem`. Save the `validation_key` created in the following directory:

`/PATH/TO/myproject/chef-repo/.chef`

#### Create a Client Key

Create a `client_key` by following the instructions in the [Chef documentation](https://docs.chef.io/server_users.html#reset-user-key) to reset a user key.  

Your `client_key` should be named in the following format `USERNAME.pem`. Save the `client_key` created in the following directory:

`/PATH/TO/myproject/chef-repo/.chef`

### Setup

Setup of the Chef Server requires writing a configuration file that `knife`, a command-line tool that provides an interface between a local chef-repo and the Chef server, needs to connect to the Chef Server and uploading chef cookbooks, roles, data bags, and environments to the Chef Server.

`knife` is installed to the user's workstation as part of the Chef Development Kit.

#### config.rb

Open the `config.rb` file in the `chef-repo/.chef` directory of this project.

Update the variables defined with details that reflect your Chef Server. The following variables are of interest:  `client_key`, `validation_client_name`, `validation_key`, `chef_server_url`, `ssh_key_name`, `aws_access_key_id`, and `aws_secret_access_key`

#### Environment Variables

The `config.rb` file in the `.chef/` directory references environment variables in order to keep sensitive information out of version controlled code.
The following environment variables should be created through the command line or permanently by editing the ` ~/.bash_profile` file.

```
$ export USER=<username>
$ export ORGNAME=<orgname>
$ export AWS_ACCESS_KEY_ID=<aws_access_key_id>
$ export AWS_SECRET_ACCESS_KEY=<aws_secret_access_key>
```

#### Encrypted Data Bag Secret

An `encrypted_data_bag_secret` is required for encrypting data bags that are uploaded to a Chef Server or encrypting data bags for saving in version control (not recommended).

Create an `encrypted_data_bag_secret` by running the following commands.

```
openssl rand -base64 512 | tr -d '\r\n' > /PATH/TO/myproject/chef-repo/.chef/encrypted_data_bag_secret
chmod 600 /PATH/TO/myproject/chef-repo/.chef/encrypted_data_bag_secret
```

#### Uploading Chef Cookbooks

Chef cookbooks are uploaded from the directory defined in the `cookbook_path` variable of `config.rb` to the Chef Server.

Copy cookbooks from the `wrapper_cookbooks/` directory and download their dependencies from the Chef Supermarket by running the following commands.

```
# navigate to the project root
$ cd /PATH/TO/myproject

# copy cookbooks to the directory defined in the cookbook_path variable of config.rb
$ berks vendor chef-repo/cookbooks --delete --berksfile Berksfile

# upload all cookbooks from the directory defined in the cookbook_path variable of config.rb to the Chef Server
$ knife cookbooks upload --all --config /PATH/TO/myproject/chef-repo/.chef/config.rb
```

To upload individual cookbooks (ex. tubmanproject_app) run the following command:

`$ knife cookbook upload tubmanproject_app --config /PATH/TO/myproject/chef-repo/.chef/config.rb`

#### Uploading Chef Data Bags

Data bags can be uploaded to the Chef server encrypted or in plaintext.

Before data bag items can be uploaded data bags need to be created on the Chef Server.  Use the following commands to create Chef Data Bags on your Chef Server.

```
# create the deploy data bag
$ knife data bag create deploy --config /PATH/TO/myproject/chef-repo/.chef/config.rb

# create the secrets data bag
$ knife data bag create secrets --config /PATH/TO/myproject/chef-repo/.chef/config.rb

# create the users data bag
$ knife data bag create users --config /PATH/TO/myproject/chef-repo/.chef/config.rb
```  

##### Encrypted Data Bags

Creating encrypted data bag items requires providing the `encrypted_data_bag_secret` to the `knife` command.

To add all the data bag items in your data bag directory to the Chef Server run the following command:

`$ knife data bag from file secrets /PATH/TO/myproject/chef-repo/data_bags/secrets/*.json --config /PATH/TO/myproject/chef-repo/.chef/config.rb --secret-file /PATH/TO/myproject/chef-repo/.chef/encrypted_data_bag_secret`

To add an individual data bag item (ex. secrets/aws) to the Chef Server run the following command:

`$ knife data bag from file secrets /PATH/TO/myproject/chef-repo/data_bags/secrets/aws.json --config /PATH/TO/myproject/chef-repo/.chef/config.rb --secret-file /PATH/TO/myproject/chef-repo/.chef/encrypted_data_bag_secret`

##### Plaintext Data Bags

To create plaintext data bag items do not provide the `encrypted_data_bag_secret` to the `knife` command.

To add all the data bag items in your data bag directory to the Chef Server run the following command:

```
# add the deploy data bag items to the Chef Server
$ knife data bag from file deploy /PATH/TO/myproject/chef-repo/data_bags/deploy/*.json --config /PATH/TO/myproject/chef-repo/.chef/config.rb

# add the users data bag items to the Chef Server
$ knife data bag from file users /PATH/TO/myproject/chef-repo/data_bags/users/*.json --config /PATH/TO/myproject/chef-repo/.chef/config.rb
```

To add an individual data bag item (ex. deploy/jupyterhub) to the Chef Server run the following command:

`$ knife data bag from file deploy /PATH/TO/myproject/chef-repo/data_bags/deploy/jupyterhub.json --config /PATH/TO/myproject/chef-repo/.chef/config.rb`

#### Uploading Roles

To upload your roles to the Chef server run the following command:

`$ knife role from file /PATH/TO/myproject/chef-repo/roles/*.json --config /PATH/TO/myproject/chef-repo/.chef/config.rb`

#### Uploading Environments

To upload your environments to the Chef server run the following command:

`$ knife environment from file /PATH/TO/myproject/chef-repo/environment/*.json --config /PATH/TO/myproject/chef-repo/.chef/config.rb`

### Usage

Using `knife` it is possible to save encrypted data bag items to a file by redirecting the output of the `knife data bag show DATA_BAG_NAME DATA_BAG_ITEM` command.
An example of saving an encrypted data bag item in version control is below:

```
$ cd /PATH/TO/myproject/chef-repo

# note the knife command does not have the --secret-file nor --config options set
$ knife data bag show secrets aws -Fj > data_bags/secrets/aws.json

git add /PATH/TO/myproject/chef-repo/data_bags/secrets/aws.json
git commit -m "Saved encrypted data bag for aws secrets"
```

Reference the [documentation](https://docs.chef.io/knife_data_bag.html) for `knife data bag` for more instructions on using the command.
