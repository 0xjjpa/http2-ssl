# Setting up a HTTP/2 Webpage with RancherOS, NGINX and Let's Encrypt in AWS.

[HTTP2](https://assets.jjperezaguinaga.com/articles/v1/http2-rancheros-nginx-letsencrypt/RancherOS_HTTP2.jpg)

*tl;dr By copying the following [repo](https://github.com/jjperezaguinaga/http2-ssl), adding your own AWS credentials, and running `make up && make provision`, you create a t2.nano AWS vm that hosts a webpage with HTTP/2 using NGINX with a SSL Certificate by Let's Encrypt*

In September of 2015, NGINX Inc. released [NGINX version 1.9.5][NGINX], which contains the open source patch that allows the popular web server to support [HTTP/2][HTTP2-Slides]. This new version of the HTTP protocol contains major upgrades over HTTP/1.1 that makes loading webpages significantly faster. It is key for Front End Engineers to learn the new features included in HTTP/2, since many techniques currently used in Web Development and HTTP/1.1 will become [anti-patterns in HTTP/2][Cloudflare-WebDev].

To get started with HTTP/2, a SSL certificate is required, since there's no implementation of HTTP/2 without SSL. Luckily enough, [Lets Encrypt][LetsEncrypt] recently started its public beta, allowing issuing SSL certificates for free. Assembling the request of a SSL certificate, installing the proper version of NGINX, and running the NGINX server with HTTP/2 enabled, can be easily done inside Amazon Web Services (AWS) with [Docker][Docker] and [RancherOS][RancherOS].

# Initial Setup

To get started, clone the [repository](https://github.com/jjperezaguinaga/http2-ssl) that holds a series of scripts required for setting up a [EC2 t2.nano](https://aws.amazon.com/blogs/aws/ec2-update-t2-nano-instances-now-available/), currently the smallest available virtual machine (VM) provided by AWS. Inside the repository, you can find a [Vagrantfile](https://docs.vagrantup.com/v2/vagrantfile/), which is a configuration file used by [Vagrant](https://www.vagrantup.com/) to provisioning VMs.

```
$ git clone https://github.com/jjperezaguinaga/http2-ssl
$ cd http2-ssl
$ tree -L 1
.
├── License.txt
├── Makefile
├── README.md
├── Vagrantfile
├── html
├── letsencrypt
└── vagrant.sh.template
```

Within the repository, modify the shell script template with your own information such as AWS Credentials, domain and email for recovering your SSL Certs. The `Makefile` within the file, leverages on the `vagrant.sh` to perform actions against the VM.

```
$ cat vagrant.sh.template
#!/bin/bash
DOMAIN="domain.com" EMAIL="certs@domain.com" AWS_ACCESS_KEY="XXXXX" AWS_SECRET_KEY="XXXXX" AWS_KEYPAIR_NAME="key-zone-name" AWS_KEYPAIR_PATH="/home/admin/.ssh/key-zone-name.pem" vagrant $1 $2 $3 $4
$ mv vagrant.sh.template vagrant.sh
$ vim vagrant.sh
```
*Replace the script file with your own AWS credentials and domain where your webpage will be hosted. Additionally, before going on, make sure you have Vagrant installed. For more information about Vagrant, see their [webpage](https://www.vagrantup.com/).*

# Creating the machine

Before running up the script to boot up the machine, make sure that the default security group has your external IP open for port 22, which is the default port used by Vagrant. We can do all this from the command line with the [AWS CLI tool](http://docs.aws.amazon.com/cli/latest/reference/ec2/authorize-security-group-ingress.html).

```
$ brew install awscli # run `aws configure` to add your keys
$ curl ifconfig.io | xargs sh -c 'aws ec2 authorize-security-group-ingress --group-name default --protocol tcp --port 22 --cidr $0/32' # You might need to specific a region
```

*As a good practice, never open port 22 to the external world (0.0.0.0/0) to avoid brute force attacks against your VM to try to get SSH access (or if you do install [Fail2Ban](http://www.fail2ban.org/wiki/index.php/Main_Page)). Ideally, port forward your SSH console to a less common port (i.e. 8722) and only allow access to it to your own IP, either the one from your internal network or the one used at that specific point in time, which is what we are doing with the `curl ifconfig.io` command.*

With our port 22 open for Vagrant, and with the proper credentials set in motion, now you can start booting up the machine. This can be done with a simple `make` command that will  use the `vagrant.sh` script defined before. This will only create the RancherOS t2.nano machine, but won't provision it nor execute the Docker provisioner from Vagrant.

```
➜  http2-ssl git:(master) make up
./vagrant.sh up --no-provision
Bringing machine 'default' up with 'aws' provider...
==> default: Warning! The AWS provider doesn't support any of the Vagrant
==> default: high-level network configurations (`config.vm.network`). They
==> default: will be silently ignored.
==> default: Starting the instance...
==> default: Waiting for instance to become "ready"...
==> default: Waiting for SSH to become available...
==> default: Machine is booted and ready for use!
==> default: Rsyncing folder: /Users/jjperezaguinaga/Projects/http2-ssl/ => /opt/rancher
==> default:   - Exclude: [".vagrant/", ".git/"]
==> default: Machine not provisioned because `--no-provision` is specified.
```

You can check that we have successfully created our machine by running the AWS cli tool.

```
# Some code goes here.
```

# Pointing our machine to a specific domain

Before we can provision our machine, we need to make sure it has a proper mapped domain inside our DNS Server to allow LetsEncrypt.org reach the server when validating the SSL certificate.

We can do that by SSHing into the machine, and using AWS instance metada to get its DNS url and IP.

```
# Some code goes here
```

With our public DNS url, we just need to log into our public DNS server panel to add the entry as a CNAME record to the domain we want to use; we would need to add an A record if we wanted to use the root domain and add our machine IP instead . The domain needs to be the same one used inside the `vagrant.sh` script, as we will reach LetsEncrypt.org in the next step.

# Provisioning the machine



# Conclusion

Although setting up a HTTP/2 Web Server seems to be a task meant for a System Administrator, learning how to set it up as a Front End Engineer allows easy testing of the protocol, benchmarking of the improvements with the new techniques, and pushing its implementation across the web products Front End Engineers are resnposible of.

FOOT NOTES

*Although NGINX wasn't the [first server to support HTTP2][HTTP2-Implementations], it's one of the most popular in the Web field.*


[NGINX]: https://www.nginx.com/blog/nginx-1-9-5/
[HTTP2-Slides]: https://docs.google.com/presentation/d/1r7QXGYOLCh4fcUq0jDdDwKJWNqWK1o4xMtYpKZCJYjM/present?slide=id.p19
[Cloudflare-HTTP2]: https://www.cloudflare.com/http2/what-is-http2/
[Cloudflare-WebDev]: https://blog.cloudflare.com/http-2-for-web-developers/
[Cloudflare-SPDY]: https://blog.cloudflare.com/introducing-http2/
[HTTP2-Book]: http://hpbn.co/http2
[HTTP2-Implementations]: https://github.com/http2/http2-spec/wiki/Implementations
[LetsEncrypt]: https://letsencrypt.org/
[LetsEncrypt-Repo]: https://github.com/letsencrypt/letsencrypt
[RancherOS]: http://rancher.com/rancher-os/
[Docker]: http://www.docker.io/



