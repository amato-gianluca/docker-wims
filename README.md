# WIMS

This docker image contains [WIMS (Web Interactive Multipurpose Server)](https://wimsedu.info/) 
together with additional support software (Gnuplot, Graphviz, Povray, PARI/GP, Maxima, Octave, 
GAP, Yacas, Macaulay2 and others). 

# Quick start

```
git clone https://github.com/amato-gianluca/docker-wims.git
cd docker-wims
make all
```

Now you can take a coffee <i class="fa fa-check"></i> &#x2615; or a beer, 
to wait between 10 or 15 minutes to get the image generated.

After that, it will also start your local instance of WIMS.
You can check it on: http://localhost:10000/wims/.

# Docker image definition

## Its proposal

This image is defined and built by default as a per local development and testing.

For having WIMS in a production environment, you should consider reviewing the 
current [docker-compose.yml](https://github.com/amato-gianluca/docker-wims/blob/master/docker-compose.yml)
and customize it to your production infrastructure and needs.

Some aspects you should consider, but not only:

1. Collect into your journald or similar all logs produced by WIMS. 
2. To do so, you should know that WIMS produces an extensive list of local file logs. It would also
   increment your container image and losing those logs (potentially) after a service restart.
3. Keep all `classes` and the rest of directoris as they are between service restarts. You should
   consider using volumes or bind volumes to keep them all.
4. If your production infrastructure will load balance HTTP requests between several hosts, you
   should consider sharing those volumes in all backend nodes.

## Customization

After executing once the `make all`, you can customize the version of the WIMS being built
and some other aspects by modifying the `.env`. This file is local for you and out of git control.

Other customizations can come just by modifying the `docker-compose.yml` file.

Finally, you can base your docker image on this one, and extend and modify what you need, or
clone this repository and alter the `Dockerfile` or whatever, to get your expected results.

## Volumes

The `log/` and `public_html/modules/devel/` directories of WIMS are exported as volumes.
I hope these are the only directories we need to preserve when rebuilding containers.

## Customize corporate logo

At startup, the `log/logo.jpeg` file is copied into `public_html/logo.jpeg`, in order 
to ease the installation of an institutional logo. If `log/logo.jpeg` does not exist, 
then `public_html/logo.jpeg` is deleted.

## Email sending

The image also contains sSMTP and some additional mail utilities, which allow WIMS to 
send emails trough a relay host. The behaviour of sSMTP is controlled by the following 
environment variables:
  * `SSMTP_MAILHUB`: address of the relay host
  * `SSMTP_HOSTNAME`: hostname which should appear as the originating host of emails

## Run it under a reverse proxy

The image may be used behind a reverse proxy by setting the environment variable 
`REVERSE_PROXY` to its IP address. This will instruct WIMS to trust the 
`X-Forwarded-For` and `X-Forwarded-Proto` headers coming from the reverse proxy. 
Unfortunately, this image lacks support for TLS when WIMS does not run behind a proxy.

## Example deployment

You have the 

This an example of `docker-compose.yml` usable for deployment of the image trough Docker Compose:

```yaml
volumes:
  wims:
  devel:

services:
  app:
    image: amatogianluca/wims
    security_opt:
      - seccomp:unconfined
    hostname: wims
    restart: always
    volumes:
      - wims:/home/wims/log:Z
      - devel:/home/wims/public_html/modules/devel:Z
    environment:
      - SSMTP_MAILHUB=<relay host>
      - SSMTP_HOSTNAME=<originating hostname>
      - REVERSE_PROXY=yes
    ports:
      - 127.0.0.1:10000:80
```

Since Maxima uses the `personality` system call, which is normally banned within a container,
we need a custom seccomp profile, or to disable seccomp altogether (the solution adopted in 
the example, although it is not the one I would recommend). The page 
[Seccomp security profiles for Docker](https://docs.docker.com/engine/security/seccomp/) 
gives more details on seccomp profiles.

In the example above, the HTTP port of the container is exported as port 10000 in localhost. 
It can be later remapped to the `/wims` directory of the host using a reverse proxy, as in the 
following snippet of an Apache config file:

 ```apache
 <Location /wims>
  ProxyPass http://127.0.0.1:10000/wims
  ProxyPassReverse http://127.0.0.1:10000/wims
  ProxyPreserveHost On
  RequestHeader set X-Forwarded-Proto https
</Location>
```

Note the use of `RequestHeader set X-Forwarded-Proto https` to make WIMS believe 
to be operating in HTTPS, even if the internal connection between the proxy and the
WIMS server is HTTP. Obviously, the host must use HTTPS with the external world for the 
previous snippet to work.
