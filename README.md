# omtd-galaxy-patch

Contains initiliazation steps and patch files to prepare Galaxy (http://www.galaxyproject.org) to work with ~okeanos in a production setup. 

Requires an ~okeanos VM with Ubuntu Server 16.04 LTS. 

Performs the following steps:
- Update system with latest packages
- Install Python 2.7
- Install and configure PostgreSQL 
- Install and configure Apache
- Install Docker and docker-machine
- Fetch galaxy from github
- Patch galaxy in order to work with PostgreSQL, Apache and Pithos+ object storage.
