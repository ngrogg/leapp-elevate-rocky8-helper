# Leapp Elevate Rocky 8 Helper - Version r82r9

## Overview
Boilerplate BASH wrapper script for upgrading Rocky Linux 8 to Rocky Linux 9 via Leapp ELevate. <br>

For the CentOS 7 to Rocky 8 version of the script (Version c72r8), see [here](https://github.com/ngrogg/leapp-elevate-centos7-helper) <br>

Alma Linux ELevate documentation can be found [here](https://almalinux.org/elevate/) <br>

**IMPORTANT** <br>
This script should be considered the _basis_ for it's own work effort and not a complete script in and of itself. <br>
It may be possible to run the script as is and successfully upgrade a server to Rocky 9, but there will likely need to be additional adjustments. <br>
Take a snapshot before using! No warranties, ymmv. <br>

## Usage
* **elevateHelper.sh**, a BASH script for upgrading Rocky Linux 8 servers to Rocky Linux 9. 
  Runs in three parts, a prep stage, an upgrade stage and a post-upgrade stage. Stages are elaborated on further below. <br> 
  Script will prompt user to check output from script at several points and is _not_ a "fire and forget" script. <br>
  These points requiring input will always be color coded in yellow preceeded by **IMPORTANT:** to help output stand out. <br> 
  Usage, `./elevateHelper.sh STAGE` <br> 
  Ex. `./elevateHelper.sh prep` <br>
  Ex. `./elevateHelper.sh upgrade` <br>
  Ex. `./elevateHelper.sh post` <br> 
  Script also has a help function: <br>
  Help, `./elevateHelper.sh help` <br> 
  See **Upgrade Stages** section below for breakdown on stages. <br>

## Upgrade Stages
Script upgrades server in three stages, below is a breakdown of what's approximately done in each stage. <br>
* **Prep**, Prepare the server for upgrading. This is the most involved of the three stages and the most likely place issues will arise. 
  Server is updated, ELevate packages are installed, repos are adjusted, and server is checked for errors that will prevent upgrades from completing. 
  While encountered errors from testing will be resolved there will likely be additional adjustments required depending on server configurations. 
  Below are some of the common fail points from testing: <br> 
  - Duplicate packages
  - Development versions of kernels installed
  - Kernel mismatches between newest installed kernel and running kernel
  - Not enough disk space being available 
  - Incompatible software like NFS or Samba
* **Upgrade**, Upgrade server with leapp upgrade tool. Fairly straightforward, main requirement is at least 10 GB of disk space be available. 
  If there isn't enough disk space the upgrade will fail. Script has some error checking for this.
* **Post**, Once server is upgraded removed packages are re-installed, repos are re-enabled, server is updated, failed services are checked 
  and any packages not upgraded by the upgrade process are listed. Grub menu is also regenerated.

## Script
To copy just the script onto a server: <br>
Production version: <br>
`wget https://raw.githubusercontent.com/ngrogg/leapp-elevate-rocky8-helper/refs/heads/main/elevateHelper.sh` <br> <br>
Testing version (not recommended): <br>
`wget https://raw.githubusercontent.com/ngrogg/leapp-elevate-rocky8-helper/refs/heads/testing/elevateHelper.sh`
