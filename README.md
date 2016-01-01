# Setting up a HTTP/2 Webpage with RancherOS, NGINX and Let's Encrypt.

![HTTP2](https://assets.jjperezaguinaga.com/articles/v1/http2-rancheros-nginx-letsencrypt/RancherOS_HTTP2.jpg)

In september of 2015, NGINX Inc. released [NGINX version 1.9.5][NGINX], which contains the open source patch published earlier in August that allows the popular web server to support [HTTP/2][HTTP2-Slides]. This new version contains major upgrades over HTTP/1.1 that are key to learn by Front End Engineers, due the fact that many techniques currently used in Web Development will become [anti-patterns in HTTP/2][Cloudflare-WebDev].

Currently there's no implementation of HTTP/2 without SSL, so in order to setup a server with HTTP/2, you need a SSL certificate. Luckyly enough, [Lets Encrypt][LetsEncrypt] recently entered a public beta, allowing issuing SSL certificates for free. Assambling the request of the SSL certificate, and the NGINX server with HTTP/2 enabled, can be easily done with [Docker][Docker] and [RancherOS][RancherOS].


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



