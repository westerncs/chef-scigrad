# scigrad-cookbook

This Chef cookbook installs and configures a development environment suitable for development of the Science Graduate tool.  

It will:

* Install and configure Apache and PHP
* Install MySQL Server and create the program database
* Install all necessary PHP modules

We will use Vagrant to do development on the project.  This way, everyone can run a local VM containing an identical development environment, so there will be no surprises when it's time to roll out to production.

*Note that the instructions below assume you're running a UNIX (e.g. OS X) or Linux system.  If you're running Windows, you'll still be able to work through them, but will need to adapt them accordingly.*

## Setting up a development environment

### Prerequisites
First, you'll need to install Oracle Virtualbox, and then Vagrant:

* https://www.virtualbox.org/wiki/Downloads
* https://www.vagrantup.com/downloads.html

Make sure you have these tools installed and that you have the `vagrant` command in your `PATH` (i.e. that it works when you type `vagrant` at the command line).

### Creating the VM

Create a directory on your computer to house the Vagrant configuration for the virtual machine we'll create:

```
mkdir ~/scigrad
cd ~/scigrad
```

In this directory, download the `Vagrantfile` from the following link:

```
wget https://github.com/westerncs/chef-scigrad/releases/download/0.0.4/Vagrantfile
```

Next, start up the VM.  The first time you do this, it will take a while as it downloads the Ubuntu *box* from the Internet:

```
vagrant up
```

If you're on OS X or Linux, you can SSH into the VM by simply typing:

```
vagrant ssh
```

If you're on Windows, it's not quite as easy, but it's still quite simple.  See the Vagrant introduction in my lab manual for CS 3357 for details (pages 3 - 11 in the Windows edition): http://jsuwo.github.io/cs3357/labs/

### Configuring the VM

Once you're SSH-ed into the VM, check out the project repository in `/var/www`:

```
sudo apt-get install git-core
sudo mkdir /var/www
sudo chown vagrant /var/www
cd /var/www
git clone https://github.com/westerncs/scigrad.git
```

You'll be prompted for your GitHub username and password.  You can set up a public/private keypair, if you like, but we'll assume you're using HTTPS here for brevity.

Next, download the Chef cookbooks that will configure the system

```
cd /home/vagrant
wget https://github.com/westerncs/chef-scigrad/releases/download/0.0.4/chef-scigrad-0.0.4.tar.gz
```

Extract them and run them:

```
tar zxvf chef-scigrad-0.0.4.tar.gz
sudo chef-solo -c chef/client.rb -j chef/first-boot.json
```

Chef will spend a few minutes configuring the system.

Once finished, all that's left is to populate the database with some initial data:

```
cd /var/www/scigrad
mysql -u root scigrad < database.sql
```

Port 80 in the VM has been mapped to port 8000 on your local system.  Open a Web browser on your system and go to http://localhost:8000.  You should see the initial CakePHP screen.  Congratulations!  You're all set.
