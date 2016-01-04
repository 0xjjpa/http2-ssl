# Setting up a HTTP/2 Webpage with RancherOS, NGINX and Let's Encrypt in AWS.

![HTTP2](https://assets.jjperezaguinaga.com/articles/v1/http2-rancheros-nginx-letsencrypt/RancherOS_HTTP2.jpg)

*tl;dr By copying the following [repo](https://github.com/jjperezaguinaga/http2-ssl), adding your own AWS credentials, and running `make up`, you create a t2.nano AWS vm with RancherOS; add its public hostname to a DNS server and the do `make provision` to host a webpage with HTTP/2 using NGINX with a SSL Certificate by Let's Encrypt. An asciinema play is embedded at the bottom of the post.*

In September of 2015, NGINX Inc. released [NGINX version 1.9.5][NGINX], which contains the open source patch that allows the popular web server to support [HTTP/2][HTTP2-Slides]. This new version of the HTTP protocol contains major upgrades over HTTP/1.1 that makes loading webpages significantly faster. It is key for Front End Engineers to learn the new features included in HTTP/2, since many techniques currently used in Web Development and HTTP/1.1 will become [anti-patterns in HTTP/2][Cloudflare-WebDev].

A SSL certificate is required to get started with HTTP/2, due the fact that there's no implementation of HTTP/2 without SSL. Luckily enough, [Lets Encrypt][LetsEncrypt] recently started its public beta, allowing issuing SSL certificates for free. Assembling the request of a SSL certificate, installing the proper version of NGINX, and running the NGINX server with HTTP/2 enabled, is easily done inside Amazon Web Services (AWS) with [Docker][Docker] and [RancherOS][RancherOS].

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

Within the repository, modify the shell script template (i.e. `vagrant.sh.template`) with your own information such as AWS Credentials, domain and email for recovering your SSL Certs. Remove the extension `.template` to allow our `Makefile` to perform actions against the VM.

```
$ cat vagrant.sh.template
#!/bin/bash
DOMAIN="domain.com" EMAIL="certs@domain.com" AWS_ACCESS_KEY="XXXXX" AWS_SECRET_KEY="XXXXX" AWS_KEYPAIR_NAME="key-zone-name" AWS_KEYPAIR_PATH="/home/admin/.ssh/key-zone-name.pem" vagrant $1 $2 $3 $4
$ vim vagrant.sh.template
$ mv vagrant.sh.template vagrant.sh
```
*Replace the script file with your own AWS credentials and domain where your webpage will be hosted. Additionally, before moving on, make sure you have Vagrant installed. For more information about Vagrant, see their [webpage](https://www.vagrantup.com/).*

# Creating the machine

Before running up the script to boot up the machine, make sure that the default security group has your external IP open for port 22, which is the default port used by Vagrant. We can do all this from the command line with the [AWS CLI tool](http://docs.aws.amazon.com/cli/latest/reference/ec2/authorize-security-group-ingress.html) and using the included script `add_ip_to_ssh.sh`.

```
$ brew install awscli # run `aws configure` to add your keys
$ cat add_ip_to_ssh.sh
#!/bin/bash
curl ifconfig.io | xargs sh -c 'aws ec2 authorize-security-group-ingress --group-name default --protocol tcp --port 22 --cidr $0/32'
$ ./add_ip_to_ssh.sh
```

*As a good practice, never open port 22 to the external world (0.0.0.0/0) to avoid brute force attacks against your VM to try to get SSH access (or if you do install [Fail2Ban](http://www.fail2ban.org/wiki/index.php/Main_Page)). Ideally, port forward your SSH console to a less common port (i.e. 8722) and only allow access to it to your own IP, either the one from your internal network or the one used at that specific point in time, which is what we are doing with the `curl ifconfig.io` command.*

With our port 22 open for Vagrant, and with the proper credentials set in motion, now you can start booting up the machine. This can be done with a simple `make` command that will  use the `vagrant.sh` script defined before. This will only create the RancherOS t2.nano machine, but won't provision it nor execute the Docker provisioner from Vagrant. Run `make up` for the following information:

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
$ aws ec2 describe-instances
```

# Pointing our machine to a specific domain

Before we can provision our machine, we need to make sure it has a proper mapped domain inside our DNS Server to allow LetsEncrypt.org to reach the server when validating the SSL certificate. This guarantees LetsEncrypt.org and our users that we are the owners of that specific domain.

We can do that by SSHing into the machine, and using AWS instance metada to get its public hostname.

```
➜  http2-ssl git:(master) ✗ make ssh
./vagrant.sh ssh
[rancher@ip-172-31-28-253 ~]$
[rancher@ip-172-31-28-253 ~]$ wget http://169.254.169.254/latest/meta-data/public-hostname
Connecting to 169.254.169.254 (169.254.169.254:80)
public-hostname      100% |**********************************************|    49   0:00:00 ETA
[rancher@ip-172-31-28-253 ~]$ cat public-hostname
ec2-54-172-126-31.us-west-1.compute.amazonaws.com
```
*We would need to add an A record if we wanted to use the root domain and add our machine IP instead. For that, instead of using `public-hostname` at the end of the wget command, use `public-ipv4`.*

With our public hostname url, we just need to log into our public DNS server panel to add the entry as a CNAME record to the domain we want to use. The domain needs to be the same one used inside the `vagrant.sh` script, as we will reach LetsEncrypt.org in the next step.

![DNS](https://assets.jjperezaguinaga.com/articles/v1/http2-rancheros-nginx-letsencrypt/DNS_CNAME_record.png)

After doing so, to make sure your domain is being resolved to the right IP/AWS DNS url, use the `dig` command (e.g. `$ dig test.domain.com`). Depending on the TTL of your DNS provider, it might take a few minutes to resolve correctly.

```
➜  http2-ssl git:(master) ✗ dig http2.jjperezaguinaga.com
(...)
;; ANSWER SECTION:
http2.jjperezaguinaga.com. 299	IN	CNAME	ec2-54-172-126-31.us-west-1.compute.amazonaws.com.
ec2-54-172-126-31.us-west-1.compute.amazonaws.com. 21599 IN A 54.172.126.31
```

# Provisioning the machine

With the domain being resolved correctly, and our machine properly up and running, the rest is fairly simple. Run the provision command that will run three providers, two with docker and one with shell scripting.

```
make provision
```
If you see the `Makefile`, you will see that we are explicitely telling Vagrant to use all of them while provisioning. 

```
$ cat Makefile
(...)
provision:
	$(ENTRYPOINT) provision --provision-with letsencrypt,replace,webpage
```

The reasoning behind this is that each provisioner fulfills a specific task, that we might later want to redo:

* **letsencrypt** runs the initial LetsEncrypt docker container that will reach LetsEncrypt.org and map the container with the right name to then use its container as a volume container, since the SSL certificate will be stored there.
* **replace** runs a shell script that replaces our NGINX configuration with the domain given in `vagrant.sh`
* **webpage** runs the final NGINX container that leverages in the letsencrypt volume to setup our sample webpage.

In case we want to change our webpage, we would need to run `make reprovision`, which will then upload the new contents of the webpage to our server. If we were to use `make provision` again, we would destroy the LetsEncrypt container that holds our certificates and ask LetsEncrypt to issue them again, which can prompt issues (see IMPORTANT NOTE)

**IMPORTANT NOTE: LetsEncrypt has a cap for IP and domains. This setup only works for one specific domain, but it can be easily modified to work with many domains if you just add `-d DOMAIN` in the Vagrantfile for each additional domain. If you want to test it, I suggest you to add the staging server to the letsencrypt parameter to avoid being capped while testing.**

# Updating our webpage

Currently, the project has a mock webpage that can be easily replacable. The NGINX configuration is only for serving static pages, so if you wish to modify the webpage, just change the content of the `dist` folder inside the `html` folder.

```
➜  http2-ssl git:(master) ✗ tree html
html
├── Dockerfile
├── default.conf.tmpl
├── dist
│   └── index.html
└── nginx.conf
```

After doing so, just do `make reprovision`.


# Conclusion

Although setting up a HTTP/2 Web Server seems to be a task meant for a System Administrator, learning how to set it up as a Front End Engineer allows easy testing of the protocol, benchmarking of the improvements with the new techniques, and pushing its implementation across the web products Front End Engineers are resnposible of.

Setting up NGINX is still somewhat cumbersome, but it has the benefits of a reliable and battle tested web server. If you are interested in a more user-friendly experience, I would recommend   the reader to review Caddy server, which already has HTTP/2 included.


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



