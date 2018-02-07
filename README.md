# Koha deployment with Docker
Joshua Brooks - April 2016

## Intro
This is a quick introduction to using the Koha ILS with 'Docker'. It assumes (as I had on starting this project!) no prior knowledge of Koha or Docker administration. Docker is a great way to simplify the development and deployment of almost any website/service/etc. In the past I've used Docker for Wordpress, Python web applications and databases.

## Summary
We use 'containers' to run services – in this case, we have three containers. One is running a database called MariaDB (equivalent to MySQL). The other is running a web server called Apache, and has the files for Koha on it. The third is running Memcached which should speed up Koha.
The main file of interest here is 'docker-compose.yml'. This is a file which will be read by the 'docker-compose' program to start all of the services we need.

## Really Short Version

    - Install Docker, docker-compose, git and nginx
    
    git clone https://github.com/joshbrooks/xgcc.git
    cd xgcc (on Linux) or dir xgcc (on windows)
    docker-compose up

## Longer Version

### Install Software

Running this on Windows isn't tested - if you really want to use Windows it should work fine but it's been developed and tested on Linux only. Starting point for Windows users would be here:
    https://docs.docker.com/windows/step_one/
    
Otherwise install Linux - any version, but I'd go with Linux Mint 17.
Based on the installation instructions at https://docs.docker.com/engine/installation/linux/ubuntulinux/, run this in a terminal

    sudo apt-get update
    sudo apt-get install apt-transport-https ca-certificates
    sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
    sudo echo 'deb https://apt.dockerproject.org/repo ubuntu-trusty main' > /etc/apt/sources.list.d/docker.list
    sudo apt-get update
    sudo apt-get purge lxc-docker
    sudo apt-get update
    sudo apt-get install linux-image-extra-$(uname -r) apparmor docker-engine
    sudo usermod -aG docker $(whoami)
    sudo curl -L https://github.com/docker/compose/releases/download/1.6.2/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    
Log out + log in

    docker run hello-world

This tests that it's all working as expected

Get a copy of the code:

    git clone https://github.com/joshbrooks/xgcc.git
    cd xgcc (on Linux) or dir xgcc (on windows)
    docker-compose upe

This should give you a library running on port 8088 and admin running on port 8089.
There may be a bug with regard to database access where you need to add the 'koha-library' user

## Administration

### Database

To get to a mySQL command line:

    ssh -p 81 root@xgrrlibrary.org

(or access from DigitalOcean)

    docker exec -it xgcc_mysql_1 bash
    mysql -uroot -psecret
    CREATE USER 'koha_library' IDENTIFIED BY 'FaLr********'
    GRANT ALL PRIVILEGES ON koha_library.* TO koha_library;

Commands:

  1) Get into the mysql container
  2) Get into the mysql database
  3) Create the library user (check the conf xml file for the password)
  4) Allow access to the library user










    
