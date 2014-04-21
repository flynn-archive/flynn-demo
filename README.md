# Flynn Demo Environment

This repo contains a Vagrantfile that boots up Flynn layer 0 and then bootstraps
Flynn layer 1.

The only requirement is that you have [VirtualBox](https://www.virtualbox.org/)
and [Vagrant](http://www.vagrantup.com/) installed.


### Setup

Check out this repo, and boot up the VM using Vagrant:

```text
git clone https://github.com/flynn/flynn-dev
cd flynn-dev
vagrant up
```

The final log line contains configuration details used to access Flynn via the
command line tool. Install [flynn-cli](https://github.com/flynn/flynn-cli), and
paste the `flynn server-add` command into your terminal.

### Usage

With the Flynn running and the `flynn` tool installed, the first thing you'll
want to do is add your SSH key so that you can deploy applications:

```text
flynn key-add ~/.ssh/id_dsa.pub
```

After adding your ssh key, you can deploy a new application:

```text
git clone https://github.com/flynn/nodejs-example
cd nodejs-example
flynn create example
git push flynn master
```

#### Scale

To access the application, add some web processes using the `scale`
command and a route with `route-add-http`:

```text
flynn scale web=3

flynn route-add-http localhost:8080
```

Visit the application [in your browser](http://localhost:8080) or with curl:

```text
curl localhost:8080
```

Repeated requests via curl should show that the requests are load balanced
across the running processes.

#### Logs

`flynn ps` will show the running processes:

```text
$ flynn ps
ID                                             TYPE
e4cffae4ce2b-8cb1212f582f498eaed467fede768d6f  web
e4cffae4ce2b-da9c86b1e9e743f2acd5793b151dcf99  web
e4cffae4ce2b-1b17dd7be8e44ca1a76259a7bca244e1  web
```

To get the log from a process, use `flynn log`:

```text
$ flynn log e4cffae4ce2b-8cb1212f582f498eaed467fede768d6f
Listening on 55007
```

#### Run

An interactive one-off process may be spawned in a container:

```text
flynn run bash
```

## Flynn

[Flynn](https://flynn.io) is a modular, open source Platform as a Service (PaaS).

If you're new to Flynn, start [here](https://github.com/flynn/flynn).

### Status

Flynn is in active development and **currently unsuitable for production** use.

Users are encouraged to experiment with Flynn but should assume there are stability, security, and performance weaknesses throughout the project. This warning will be removed when Flynn is ready for production use.

Please report bugs as issues on the appropriate repository. If you have a general question or don't know which repo to use, report them [here](https://github.com/flynn/flynn/issues).

## Contributing

We welcome and encourage community contributions to Flynn.

Since the project is still unstable, there are specific priorities for development. Pull requests that do not address these priorities will not be accepted until Flynn is production ready.

Please familiarize yourself with the [Contribution Guidelines](https://flynn.io/docs/contributing) and [Project Roadmap](https://flynn.io/docs/roadmap) before contributing.

There are many ways to help Flynn besides contributing code:

 - Fix bugs or file issues
 - Improve the [documentation](https://github.com/flynn/flynn.io) including this website
 - [Contribute](https://flynn.io/#sponsor) financially to support core development

Flynn is a [trademark](https://flynn.io/docs/trademark-guidelines) of Apollic Software, LLC.
