## docker-plugins-demo

A demo of the Flocker and Weave Docker plugins.

## Vagrant Quickstart

You will also need Vagrant 1.7.2 and Virtualbox installed.

Then:

```bash
$ make -C vagrantrunner
```

This will use pre-packed boxes that has everything installed - start 3 VMs and then install the Flocker and Weave plugins.

Once the boxes have started - we create the weave network on each of the nodes
and start the swarm master:

```bash
$ cd vagrantrunner
$ bash create_network.sh
$ bash launch_scope.sh
$ bash swarm_manage.sh
```

Then in another shell, we SSH into the master:

```bash
$ cd vagrantrunner
$ vagrant ssh master
```

Then we start the HTTP load balancer that opens up the open to the outside world:

```bash
master$ sudo su -
master# cd /vagrant
master# bash run_proxy.sh
```

Then we check that swarm is working and that the plugins are running, then bring up the app using `docker-compose`:

```bash
master# export DOCKER_HOST=localhost:2378
master# docker ps -a
master# cd /vagrant/app
master# docker-compose up -d
```

Now we can load the app in a browser:

```
http://172.16.70.250/
```

Click around and add some Docker logos onto the screen.

Now we migrate the stateful database to another node.

```
master# docker-compose stop
master# docker-compose rm -f
master# vim docker-compose.yml # switch "runner" and "master" in the redis constraint
master# docker-compose up -d
```

Observe that the database is both *still accessible* (thanks to Weave) and *still has its data* (thanks to Flocker).
