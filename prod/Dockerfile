FROM amatogianluca/wims:wims-4.28

ENV APP_ENV=prod
USER root

# Ensure all and only current production assets are copied and exist.
RUN rm -rf /wims
COPY --chmod=0755 assets/ /wims

# Copy specific configuration files.
COPY assets/etc/apache2/conf/security.conf /etc/apache2/conf-available/

RUN /wims/bin/post-install.sh && \
    apt update && \
    apt install -y rsync vim && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# Metadata
LABEL org.opencontainers.image.authors="Jordi Pujol-Ahulló <jordi.pujol@urv.cat>"
LABEL org.opencontainers.image.description="Production-ready WIMS service"
