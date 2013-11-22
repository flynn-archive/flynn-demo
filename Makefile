DOCKER=docker -H=unix:///var/run/docker.sock

run: all
	bin/forego start

all: bin/sampid bin/lorne bin/flynn-receive bin/gitreceived bin/discoverd bin/sdutil bin/shelf bin/flynn bin/strowger bin/forego slugbuilder slugrunner storage id_rsa /tmp/keys/vagrant nodejs-example

# Setup

storage:
	mkdir -p storage

id_rsa:
	ssh-keygen -t rsa -N "" -f id_rsa

/home/vagrant/.ssh/id_rsa:
	ssh-keygen -t rsa -f /home/vagrant/.ssh/id_rsa -N ""

/home/vagrant/.ssh/config:
	echo "Host flynn\n    Hostname localhost\n    Port 2022" > ~/.ssh/config

/tmp/keys:
	mkdir -p /tmp/keys

/tmp/keys/vagrant: /home/vagrant/.ssh/id_rsa /home/vagrant/.ssh/config /tmp/keys
	cp /home/vagrant/.ssh/id_rsa.pub /tmp/keys/vagrant

nodejs-example:
	git clone https://github.com/titanous/nodejs-example
	cd nodejs-example && git remote add flynn vagrant@flynn:example

# Projects

bin/sampid: /usr/bin/go bin/discoverd
	go get -v github.com/flynn/sampi/sampid

bin/lorne: /usr/bin/go bin/discoverd
	go get -v github.com/flynn/lorne

bin/flynn-receive: /usr/bin/go flynn-receive.go bin/discoverd
	go build -o bin/flynn-receive

bin/gitreceived: /usr/bin/go
	go get -v github.com/flynn/gitreceive-next/gitreceived

bin/discoverd: /usr/bin/go bin/etcd src/github.com/coreos/go-etcd
	go get -v github.com/flynn/go-discover/discoverd

bin/sdutil: /usr/bin/go bin/discoverd
	go get -v github.com/flynn/sdutil

bin/shelf: /usr/bin/go
	go get -v github.com/flynn/shelf

bin/flynn-api: /usr/bin/go bin/discoverd
	go get -v github.com/flynn/flynn-api

bin/flynn: bin/flynn-cli
	ln -fs `pwd`/bin/flynn-cli bin/flynn

bin/flynn-cli: /usr/bin/go bin/flynn-api
	go get -v github.com/flynn/flynn-cli

bin/strowger: /usr/bin/go bin/discoverd
	go get -v github.com/flynn/strowger

slugbuilder: /usr/bin/docker
	@${DOCKER} images | grep flynn/slugbuilder > /dev/null || ${DOCKER} pull flynn/slugbuilder

slugrunner: /usr/bin/docker
	@${DOCKER} images | grep flynn/slugrunner > /dev/null || ${DOCKER} pull flynn/slugrunner

# Vendor

src/github.com/coreos/go-etcd: /usr/bin/go
	go get -v github.com/coreos/go-etcd/etcd
	cd src/github.com/coreos/go-etcd && git checkout 7ea284fa
	rm -rf pkg/linux_amd64/github.com/coreos/go-etcd/etcd.a

bin/forego: /usr/bin/go
	go get -v github.com/ddollar/forego

bin/etcd:
	wget https://github.com/coreos/etcd/releases/download/v0.1.2/etcd-v0.1.2-Linux-x86_64.tar.gz
	tar -zxvf etcd-v0.1.2-Linux-x86_64.tar.gz
	cp etcd-v0.1.2-Linux-x86_64/etcd bin

bin/godeb:
	wget -O godeb.tar.gz https://godeb.s3.amazonaws.com/godeb-amd64.tar.gz
	tar -zxvf godeb.tar.gz
	mkdir -p bin
	mv godeb bin/godeb

/usr/bin/go: bin/godeb
	sudo bin/godeb install 1.1.2

/usr/bin/docker:
	sudo apt-get update
	sudo apt-get install -y lxc-docker
	sudo sed -i -E 's|	/usr/bin/docker -d|	/usr/bin/docker -d -H 127.0.0.1|' /etc/init/docker.conf
	sudo stop docker
	sudo start docker
	sleep 2 # wait for docker to boot

.PHONY: all slugrunner slugbuilder
