# Production-ready WIMS docker image

This is the starting point for building your production-ready
WIMS docker image.

# What it provides?

This is a skeleton that you can customize with your own configuration and files.

Even though it is a skeleton, you can start it "as is" to check it.

# Does it need volumes?

Yes. It is defined to use bind volumes to keep files between service restarts.

For this production-ready version, there is a warm-up phase only for the
first time the WIMS service is started, where the volume used to bind
`/home/wims/log/` is populated with the initial content from the WIMS image.

This is done this way because the source directory from the host used in
bind volumes overrides the content of the target directory in the container.
It is expected that you will bind an empty directory for that.

The other volume is for `/home/wims/public_html/modules/devel`, but this
directory on the WIMS docker image is empty, so it does not need any
warm-up phase.

# Why providing this version on the `/prod` directory?

All these files are intended to help you in this way:

1. You can build in local by yourself the base WIMS image, using the base /Dockerfile.
2. You, then, can build by yourself the production-ready WIMS image,
 extending the base image, with your own customizations.

For this reason, this directory contains copies of some significant files
that will be overridden, along with others that you can add and override too.

# Customize corporate logo

In this version, there is no `logo.jpeg` by default. You have to define
it in the Dockerfile or mount it in `docker-compose.yml`.
