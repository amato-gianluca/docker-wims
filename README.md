# WIMS

This docker image contains [WIMS (Web Interactive Multipurpose Server)](https://wimsedu.info/)
together with additional support software (Gnuplot, Graphviz, Povray, PARI/GP, Maxima, Octave,
GAP, Yacas, Macaulay2 and others).

## Quick start

```
git clone https://github.com/amato-gianluca/docker-wims.git
cd docker-wims
make all
```

Now you can grab a coffee <i class="fa fa-check"></i> &#x2615; or a beer
while you wait 10 to 15 minutes for the image to be generated.

After that, it will also start your local instance of WIMS.
You can check it on: http://localhost:10000/wims/.

## Customization

After executing once the `make all`, you can customize the version of the WIMS being built
and some other aspects by modifying the `.env`. You can specify:

  * `WIMS_URL` and `WIMS_VERSION`: used during image building for overriding the default WIMS version.
  * `WIMS_IMAGE_NAME`: name used by `docker compose` for the image name.
  * `container_name`: name used by `docker compose` for the container name.
  * `MANAGER_SITE`, `TZ`, `WIMS_PASS`: see below.

Other customizations can come just by modifying the `docker-compose.yml` file.

### Volumes

The `log/` and `public_html/modules/devel/` directories of WIMS are exported as volumes.
They contain the data (like classes, or internally developed teaching modules) that should
be persisted. I hope there are the only directories that needs to be persisted.

### Customize corporate logo

At startup, the `log/logo.jpeg` file is copied into `public_html/logo.jpeg`, in order
to ease the installation of an institutional logo. If `log/logo.jpeg` does not exist,
then `public_html/logo.jpeg` is deleted.

### Email sending

The image also contains sSMTP and some additional mail utilities, which allow WIMS to
send emails through a relay host. The behavior of sSMTP is controlled by the following
environment variables:
  * `SSMTP_MAILHUB`: address of the relay host
  * `SSMTP_HOSTNAME`: hostname which should appear as the originating host of emails

### Run it under a reverse proxy

The image may be used behind a reverse proxy by setting the environment variable
`REVERSE_PROXY` to its IP address. This will instruct WIMS to trust the
`X-Forwarded-For` and `X-Forwarded-Proto` headers coming from the reverse proxy.
Unfortunately, this image lacks support for TLS when WIMS does not run behind a proxy.

### Administration password

The environment variable `MANAGER_SITE` may be used to specify the IP addresses that are
allowed to access the WIMS maintenance interface. This is only used the first time the
container is started. Possible values are either a valid value for the `manager_site`
variable in `wims.conf`, or the value `auto`, which adds the local default route IP.

The environment variable `WIMS_PASS` may be used to specify the password of the maintenance
interface. A non-empty value is copied to the `log/.wimspass` file. If the variable is empty,
no action is performed.

### Timezone

The environment variable `TZ` specifies the default timezone of the container.

## Example deployment

This is an example of `docker-compose.yml` for deploying the image through Docker Compose:

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

For having a more robust production environment, you might consider collecting in your journald
or similar all logs produced by WIMS.
