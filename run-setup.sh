GALAXY_VERSION="release_17.01"
DOCKER_MACHINE_VERSION="v0.10.0"
CONF_DIR=$PWD

# Set properly the default system locale
echo LC_ALL=\"en_US.UTF-8\" | sudo tee -a /etc/default/locale 

# Bring the system up-to-date
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade

# Install Python 2.7
sudo apt-get -y install python

# Install PostgreSQL
sudo apt-get -y install postgresql postgresql-contrib
sudo -u postgres createuser galaxy
sudo -u postgres createdb galaxy
sudo -u postgres psql -c "ALTER USER galaxy WITH ENCRYPTED PASSWORD 'galaxypass';"
sudo adduser --disabled-password --gecos "" galaxy

# Install Apache2
sudo apt-get -y install apache2
echo ServerName `hostname`.vm.okeanos.grnet.gr | sudo tee -a /etc/apache2/apache2.conf
sudo ufw allow in "Apache Full"
# enable the necessary modules
cd /etc/apache2/mods-enabled
sudo ln -s ../mods-available/rewrite.load rewrite.load
sudo ln -s ../mods-available/proxy.load proxy.load
sudo ln -s ../mods-available/proxy_http.load proxy_http.load
sudo ln -s ../mods-available/proxy.conf proxy.conf
cd /etc/apache2/sites-available
sudo patch -R 000-default.conf $CONF_DIR/000-default.conf.diff
sudo systemctl restart apache2


# Installing Docker Engine and Docker machine
sudo apt-get -y install apt-transport-https ca-certificates
sudo apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt-get -y install linux-image-extra-$(uname -r) linux-image-extra-virtual
sudo apt-get -y update
sudo apt-get -y install docker-engine
sudo service docker start
sudo docker run hello-world
sudo groupadd docker
sudo usermod -aG docker $USER
sudo systemctl enable docker
curl -L https://github.com/docker/machine/releases/download/$DOCKER_MACHINE_VERSION/docker-machine-`uname -s`-`uname -m` >/tmp/docker-machine && chmod +x /tmp/docker-machine && sudo cp /tmp/docker-machine /usr/local/bin/docker-machine

# Clone Galaxy git repo locally
cd ~
git clone -b $GALAXY_VERSION https://github.com/galaxyproject/galaxy.git

# Enable PostgreSQL and apply basic configuration changes
cd ~/galaxy/config
cp galaxy.ini.sample galaxy.ini
patch -R galaxy.ini $CONF_DIR/galaxy.ini.diff

# Enable Galaxy to run Docker
cp job_conf.xml.sample_basic job_conf.xml
patch -R job_conf.xml $CONF_DIR/job_conf.xml.diff 

cp $CONF_DIR/object_store_conf.xml .


# Install Pithos+ driver
cd ~/galaxy
echo "# Pithos+" >> requirements.txt 
echo "kamaki" >> requirements.txt 
## scp from remote location __init__.py and pithos.py to lib/galaxy/objectstore/
cp $CONF_DIR/*.py ~/galaxy/lib/galaxy/objectstore

echo "::Completed system configuration. System reboot recommended"

# Start Galaxy
#cd ~/galaxy
#./rolling_restart.sh 

# (Optional) Install SADI Docker example
cd ~
#git clone https://github.com/mikel-egana-aranguren/SADI-Docker-Galaxy.git
#docker pull mikeleganaaranguren/sadi:v6
#cp -R SADI-Docker-Galaxy/tools/SADI-Docker/ galaxy/tools/
#cp tool_conf.xml.sample tool_conf.xml
#vi tool_conf.xml

