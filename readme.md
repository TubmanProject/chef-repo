# The Tubman Project

Development and production environment setup for the Tubman Project using Chef. The Tubman Project ecosystem consists of the following applications:

* Tubman Project API - A web service that exposes endpoint's useful for interacting with the Tubman Project's data and services.
* Tubman Project JupyterHub - A multi-user hub that serves Jupyter Notebooks to semi-trusted users of the Tubman Project in order to facilitate hacking on the Tubman Project's data and services.

Chef will provision a virtual machine or remote server with the following utilities:

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

## Getting Started

Deploying the Tubman Project requires:

1. Configuring project details on your local workstation.
2. Provisioning a virtual machine on your local workstation or provisioning remote servers and deploying the application.  

### Prerequisites

The Tubman Project takes advantage of [Chef](https://www.chef.io/chef/) to automate the provisioning of infrastructure and deploying applications.  The Chef Development Kit is required on your local workstation in order to use this repository.

Install the latest version of the Chef Development Kit by downloading the appropriate package for your operating system from <https://downloads.chef.io/chefdk> and running the installer for your system.   

#### Local Development

Set up a local development environment using [Vagrant](https://www.vagrantup.com/) and [VirtualBox](https://www.virtualbox.org/).

**tl;dr** - Install the following:

* [VirtualBox](https://www.virtualbox.org/)
* [ChefDK](https://downloads.chef.io/chefdk)
* [Vagrant](https://www.vagrantup.com/)
* [vagrant-ominbus](https://github.com/chef/vagrant-omnibus) - `$ vagrant plugin install vagrant-omnibus`
* [vagrant-hostmanager](https://github.com/devopsgroup-io/vagrant-hostmanager) - `$ vagrant plugin install vagrant-hostmanager`
* [vagrant-berkshelf](https://github.com/berkshelf/vagrant-berkshelf) - `$ vagrant plugin install vagrant-berkshelf`
* [vagrant-triggers](https://github.com/emyl/vagrant-triggers) - `$ vagrant plugin install vagrant-triggers`
* Ubuntu 16.04 Vagrant box - `$ vagrant box add bento/ubuntu-16.04`


This repository provides instructions for local development using [Vagrant](https://www.vagrantup.com/) to create an isolated and uniform development environment on your local workstation.  

Install the latest version of VirtualBox by downloading the appropriate package for your operating system from https://www.virtualbox.org/wiki/Downloads and running the installer for your system.

Install the latest version of Vagrant by downloading the appropriate package for your operating system from https://www.vagrantup.com/downloads.html and running the installer for your system.
Verify installation by checking that `vagrant` is available from the command line:
```
$ vagrant
Usage: vagrant [options] <command> [<args>]

    -v, --version                    Print the version and exit.
    -h, --help                       Print this help.

# ...
```

Additionally Vagrant requires packages, install the `vagrant-hostmanager`, `vagrant-omnibus`, `vagrant-berkshelf` and `vagrant-triggers` packages using the following commands:
```
$ vagrant plugin install vagrant-omnibus
$ vagrant plugin install vagrant-hostmanager
$ vagrant plugin install vagrant-berkshelf
$ vagrant plugin install vagrant-triggers
```

Install a base image or "box" of a virtual machine for use in Vagrant by using the following command.  This project uses Ubuntu 16.04.
```
$ vagrant box add bento/ubuntu-16.04
```

#### Remote Deployment

Set up a remote environment using [Amazon Web Services](https://aws.amazon.com/).

**tl:dr** - Do the following:

* Create an [AWS](https://aws.amazon.com/) account
* Create an [EC2 Key Pair](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html) and save to a location like `~/.ssh`
* Create a `webserver` [security group](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-network-security.html) in your AWS account's EC2 dashboard with inbound rules open on ports 80, 443, and 22. **Note:** using a different name for the security group will require updating the chef repository's wrapper cookbooks.  
* Set your `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` as [environment variables](https://docs.aws.amazon.com/cli/latest/userguide/cli-environment.html).  The `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` can be generated using these [instructions](https://docs.aws.amazon.com/general/latest/gr/aws-sec-cred-types.html#access-keys-and-secret-access-keys).


This repository describes the instructions for remote development using AWS EC2 instances.  [Chef](https://www.chef.io/chef/) is used to provision and deploy applications to an EC2 instance.

Configure an AWS account and your local workstation using the instructions in the **tl;dr** section.

### Installing

As described in the **Getting Started** section of this readme this project requires configuration of several details prior to provisioning a local virtual machine or remote server and deploying applications.  The Tubman Project API application and the JupyterHub application are included as [git submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules) to this project.

1. Clone this repository  

  Navigate to the location on your system where you want to install this project and create a directory.
  ```
  $ mkdir myproject
  $ cd myproject
  $ git clone --recursive https://github.com/tubmanproject/chef-repo.git .
  ```
  **Note:** *The dot at the end of the <b>git clone</b> command which will clone this repository into the `myproject` directory*

2. Set up configuration details for the deployed applications and provisioned instances by editing files in the `chef-repo/` directory.

  Reference the [Configuration](https://github.com/tubmanproject/chef-repo/chef-repo#configuration) section of `chef-repo/readme.md` for configuration instructions.

3. Provision a local virtual machine or remote server using the configuration details established in step 2.

  Reference the [Usage](https://github.com/tubmanproject/chef-repo/#usage) section below.  

## Usage

There are two option to get this project up and running [Local Development](https://github.com/tubmanproject/chef-repo/#local_development) using Vagrant and using a [Remote Server](https://github.com/tubmanproject/chef-repo/#remote_server).

### Local Development

Local development will provision a virtual machine on your local workstation and will deploy the Tubman Project API application and the JupyterHub application to that virtual machine.  After provisioning a virtual machine on your local workstation the project should be available at the following urls:

* <http://api.tubmanproject.test>
* <http://jupyterhub.tubmanproject.test>

  **Note:** *These are default URLs which can be changed by editing the "deploy" data bag items in the Chef configuration.*

A virtual machine can be provisioned with Vagrant on your local workstation using either [Chef Solo](https://www.vagrantup.com/docs/provisioning/chef_solo.html) or [Chef Server](https://www.vagrantup.com/docs/provisioning/chef_client.html)

#### Provisioning with Chef Solo

Provisioning a local virtual machine with Chef Solo will use the configuration details defined in your local `chef-repo` to provision a virtual machine and deploy applications.  

1. Navigate to the project root directory on your host system i.e. laptop.

  `$ cd /PATH/TO/myproject`

2. To provision with Chef Solo navigate to the respective directory

  `$ cd chef-solo`

3. Configure the `Vagrantfile`

  Open the `Vagrantfile` in the `chef-solo` directory of this project.

  Edit the `chef_environment` variable to either development, production, or staging based on your operating environment.
  ```
  # Chef Environment
  chef_environment = "development"
  ```

4. Configure the node in the chef-repo

  Navigate to the `node_configuration` directory in the chef-repo.

  `$ cd /PATH/TO/myproject/chef-repo/node_configuration`

  Edit the `tubmanproject.json` file to setup [hostnames and aliases](https://github.com/devopsgroup-io/vagrant-hostmanager), [port forwarding](https://www.vagrantup.com/docs/networking/forwarded_ports.html), and [synced folders](https://www.vagrantup.com/docs/synced-folders/) for the Vagrant virtual machine.  

5. Boot the Vagrant environment:

  Navigate to the `chef-solo` directory in the project's root.

  `$ cd /PATH/TO/myproject/chef-solo`

  Boot the Vagrant environment by running the following command.

  `$ vagrant up`

  Wait for the virtual machine to boot and Chef to provision the virtual environment. This may take over 20 minutes. You may need to enter the password for your workstation early in the provisioning process to allow `vagrant-hostmanager` to edit your `/etc/hosts` file.

When Chef provisioning is complete the applications will be available at <http://api.tubmanproject.test> and <http://jupyterhub.tubmanproject.test>

#### Provisioning with Chef Server

Provisioning a local virtual machine with Chef Server will require uploading the configuration details defined in your local `chef-repo` to a remote [Chef Server](https://docs.chef.io/server_components.html) and then using the configuration details on the remote Chef Server to provision a virtual machine and deploy applications.

You can use a [managed](https://manage.chef.io/login) Chef Server or a [self-hosted](https://docs.chef.io/install_server.html) Chef Server.

1. Navigate to the project root directory on your host system i.e. laptop.

  `$ cd /PATH/TO/myproject`

2. To provision with Chef Server navigate to the respective directory.

  `$ cd chef-server`

3. Configure the `Vagrantfile`

  Open the `Vagrantfile` in the `chef-server` directory of this project.

  Edit the `orgname` on the lines that match the code below to the organization name used on your Chef Server (only required for cases that run a Chef Server).

  ```
  # organization name for the Chef Server
  orgname = "ORGNAME"
  ```

  Edit the `chef_environment` variable to either development, production, or staging based on your operating environment.

  ```
  # Chef Environment
  chef_environment = "development"
  ```

  Edit the `chef.chef_server_url` variable to the location of your hosted chef url or self hosted chef server.

  ```
  # Chef configuration and provisioning
  machine.vm.provision "chef_server", type: "chef_client", run: "never" do |chef|
    chef.chef_server_url = "https://api.chef.io/organizations/#{orgname}" # hosted chef url or self host a chef server
  ...
  ```

4. Specify chef-repo configuration details

  Open the `config.rb` file in the `chef-repo/.chef` directory of this project.

  Update the variables defined with details that reflect your Chef Server. The following variables are of interest:  `client_key`, `validation_client_name`, `validation_key`, `chef_server_url`, `ssh_key_name`, `aws_access_key_id`, and `aws_secret_access_key`

5. Upload your chef configuration to the Chef Server.

  * Upload Chef cookbooks to the Chef Server
  * Upload Chef data bags to the Chef Server
  * Upload Chef environments to the Chef Server
  * Upload Chef roles to the Chef Server

    Reference the [Setting up a Chef Server](https://github.com/tubmanproject/chef-repo/chef-repo) section of `chef-repo/readme.md` for further instructions.

6. Configure the node in the chef-repo

  Navigate to the `node_configuration` directory in the chef-repo.

  `$ cd /PATH/TO/myproject/chef-repo/node_configuration`

  Edit the `tubmanproject.json` file to setup [hostnames and aliases](https://github.com/devopsgroup-io/vagrant-hostmanager), [port forwarding](https://www.vagrantup.com/docs/networking/forwarded_ports.html), and [synced folders](https://www.vagrantup.com/docs/synced-folders/) for the Vagrant virtual machine.  

7. Boot the Vagrant environment:

  Navigate to the `chef-server` directory in the project's root.

  `$ cd /path/to/project/chef-server`

  Boot the Vagrant environment by running the following command.

  `$ vagrant up`

  Wait for the virtual machine to boot and Chef to provision the virtual environment. This may take over 20 minutes to install all the necessary software and deploy applications. You may need to enter the password for your workstation early in the provisioning process to allow `vagrant-hostmanager` to edit your `/etc/hosts` file.

  When Chef provisioning is complete the applications will be available at <http://api.tubmanproject.test> and <http://jupyterhub.tubmanproject.test>

### Remote Server

Provisioning a remote server on AWS must be performed with Chef Server.  Chef Server will require uploading the configuration details defined in your local `chef-repo` to a remote [Chef Server](https://docs.chef.io/server_components.html) and then using the configuration details on the remote Chef Server to provision a virtual machine and deploy applications.

You can use a [managed](https://manage.chef.io/login) Chef Server or a [self-hosted](https://docs.chef.io/install_server.html) Chef Server.

1. Configure your AWS EC2 dashboard as described in the [Prerequisites](https://github.com/tubmanproject/chef_repo) section.

2. Specify chef-repo configuration details

  Open the `config.rb` file in the `chef-repo/.chef` directory of this project.

  Update the variables defined with details that reflect your Chef Server. The following variables are of interest:  `client_key`, `validation_client_name`, `validation_key`, `chef_server_url`, `ssh_key_name`, `aws_access_key_id`, and `aws_secret_access_key`

3. Upload your chef configuration to the Chef Server.

  * Upload Chef cookbooks to the Chef Server
  * Upload Chef data bags to the Chef Server
  * Upload Chef environments to the Chef Server
  * Upload Chef roles to the Chef Server

    Reference the [Setting up a Chef Server](https://github.com/tubmanproject/chef-repo/chef-repo) section of `chef-repo/readme.md` for further instructions.

4. Provision your EC2 instance using chef-client

  Run the following command.

  `$ chef-client --config /PATH/TO/chef-repo/.chef/config.rb --environment ENVIRONMENT_NAME --override-runlist "recipe[tubmanproject_aws::monolith]"`

  **Note:** *If using letsencrypt to generate SSL certificates it is necessary to point your DNS settings to the EC2 instance prior to completion of provisioning.*

  *The recipe "tubmanproject_aws::monolith" in the "tubmanproject_aws" cookbook includes the "letsencrypt" role. The "monolith" recipe in the "tubmanproject_aws" cookbook must be edited if usage of letsencrypt is not desired.*

## Contributing

Please read [CONTRIBUTING.md](https://www.github.com/tubmanproject/chef_repo) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

TBD

## Authors

* **Tyrone Saunders** - *Initial work* - [tyronemsaunders](https://github.com/tyronemsaunders)

See also the list of [contributors](https://github.com/tubmanproject/chef_repo/contributors) who participated in this project.

## License

See the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

TBD
