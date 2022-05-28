# k8s Lab

## Context

This is a laboratory to run [k8s](https://kubernetes.io/) in Debian-10 virtual machines (with 2048MB of RAM and 2 CPU each) using vagrant and virtualbox provider.

## Pre-requisites

- [Vagrant](https://www.vagrantup.com/downloads)  installed
- [Virtualbox](https://www.virtualbox.org/wiki/Downloads) installed

## Usage:

1. Clone this repository
2. Run `vagrant up` and wait.. all 3 servers (manager, worker01, worker02) start
3. Enter manager node `vagrant ssh k8s-manager`
4. Run `sudo -i` to elevate permissions
5. Run `kubectl get nodes` to see cluster ready to go

To destroy all VMs: `vagrant destroy -f`

## Screenshots

Expected results
![Expected](https://github.com/hansnewton/k8s-lab/raw/debian-10/screenshots/expected.png)
