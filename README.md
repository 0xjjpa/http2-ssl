# Setting up a HTTP/2 Webpage with RancherOS, NGINX and Let's Encrypt.

[HTTP2](https://assets.jjperezaguinaga.com/articles/v1/http2-rancheros-nginx-letsencrypt/RancherOS_HTTP2.jpg)

In september of 2015, NGINX Inc. released [NGINX version 1.9.5][NGINX], which contains the open source patch published earlier in August that allows the popular web server to support [HTTP/2][HTTP2-Slides]. This new version of the HTTP protocol contains major upgrades over HTTP/1.1 that are key for Front End Engineers, due the fact that many techniques currently used in Web Development will become [anti-patterns in HTTP/2][Cloudflare-WebDev].

Currently there's no implementation of HTTP/2 without SSL, so in order to setup a server with HTTP/2, you need a SSL certificate. Luckyly enough, [Lets Encrypt][LetsEncrypt] recently entered a public beta, allowing issuing SSL certificates for free. Assambling the request of the SSL certificate, and the NGINX server with HTTP/2 enabled, can be easily done with [Docker][Docker] and [RancherOS][RancherOS].

# Initial Setup

To get started, clone the [repository](https://github.com/jjperezaguinaga/http2-ssl) that holds a series of scripts required for setting up a [EC2 t2.nano](https://aws.amazon.com/blogs/aws/ec2-update-t2-nano-instances-now-available/), currently the smallest available virtual machine (VM) provided by Amazon Web Services (AWS). Inside the repository, you can find a [Vagrantfile](https://docs.vagrantup.com/v2/vagrantfile/), which is a configuration file used by [Vagrant](https://www.vagrantup.com/) to provisiong VMs.

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

Within the repository, modify the shell script template with your own information, since the `Makefile` leverages on it to perform actions against the VM.

```
$ cat vagrant.sh.template
#!/bin/bash
DOMAIN="domain.com" EMAIL="certs@domain.com" AWS_ACCESS_KEY="XXXXX" AWS_SECRET_KEY="XXXXX" AWS_KEYPAIR_NAME="key-zone-name" AWS_KEYPAIR_PATH="/home/admin/.ssh/key-zone-name.pem" vagrant $1 $2 $3 $4
$ mv vagrant.sh.template vagrant.sh
$ vim vagrant.sh
```
*Replace the script file with your own AWS credentials and domain where your webpage will be hosted. Additionally, before going on, make sure you have Vagrant installed. For more information about Vagrant, see their [webpage](https://www.vagrantup.com/).*



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



