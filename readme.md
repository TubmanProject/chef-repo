# The Tubman Project

Vagrant environment setup for the Tubman Project using Chef.

## Getting Started

These instructions will get a copy of the project up and running on your workstation for development and testing purposes. See deployment for notes on how to deploy the project to a production environment.

### Prerequisites

A virtual machine environment is used to create an isolated and uniform development environment with [Vagrant](https://www.vagrantup.com/) and [VirtualBox](https://www.virtualbox.org/).
Provisioning and deployment of the virtual machine environment is performed using [Chef](https://www.chef.io/chef/).

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

Install the latest version of the Chef Development Kit by downloading the appropriate package for your operating system from https://downloads.chef.io/chefdk and running the installer for your system.

### Installing

Clone this repository.
Navigate to the location on your system where you want to install this project and create a directory.
```
$ mkdir myproject
$ cd myproject
$ git clone --recursive https://github.com/tubmanproject/chef-repo.git .
```
*Note the dot at the end of the <b>git clone</b> command*

#### Configuration

Configuration for your system will require editing files in the `chef-repo/` directory and the `Vagrantfile`'s in the `chef-server` and/or `chef-solo` directories.

##### Chef Configuration

Reference the [Configuration](https://github.com/tubmanproject/chef-repo/chef-repo#configuration) section of `chef-repo/readme.md` for configuration instructions.

##### Vagrantfile Configuration

Open the `Vagrantfile` in the `chef-solo` and/or `chef-server` directories of this project.
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

##### Application Configuration

See the Chef Configuration section above.

#### Running

Navigate to the project root directory on your host system i.e. laptop.
```
$ cd /path/to/project
```

To provision with either chef-solo or chef-server navigate to the respective directory
```
$ cd chef-solo
```
or
```
$ cd chef-server
```

Boot the Vagrant environment by running the following command:
```
$ vagrant up
```
Wait for the virtual machine to boot and Chef to provision the virtual environment. This may take over 10 minutes. You may need to enter the password for your workstation early in the provisioning process to allow `vagrant-hostmanager` to edit your `/etc/hosts` file.

## Deployment

TBD

## Built With

* [Flask](http://flask.pocoo.org/) - A Python Microframework
* [Chef](https://www.chef.io/chef/) - Dependency Management


## Contributing

Please read [CONTRIBUTING.md](https://www.github.com/tyronemsaunders/genome_scipy) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

TBD

## Authors

* **Tyrone Saunders** - *Initial work* - [tyronemsaunders](https://github.com/tyronemsaunders)

See also the list of [contributors](https://github.com/tyronemsaunders/genome_scipy/contributors) who participated in this project.

## License

See the [LICENSE.md](LICENSE.md) file for details

## Acknowledgments

* Readme template is courtesy of [PurpleBooth](https://gist.github.com/PurpleBooth/109311bb0361f32d87a2).
* Flask project layout and directory structure has been influenced by the [DoubleDibz](https://github.com/spchuang/DoubleDibz-tutorial/tree/master/FINAL) project created by [spchuang](https://github.com/spchuang).

## TODO
* Convert the Chef workflow to use Policyfiles as opposed to Berkshelf