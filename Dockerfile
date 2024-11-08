FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive
ARG TZ=Europe/Madrid
# URL for the WIMS .tgz file from: https://sourcesup.renater.fr/frs/?group_id=379.
ARG WIMS_VERSION_URL=https://sourcesup.renater.fr/frs/download.php/file/6702/wims-4.28.tgz
ARG WIMS_VERSION=${WIMS_VERSION:-wims-4.8}
ARG WIMS_PASS

RUN apt-get update && \
# Install packages
    apt-get -y --no-install-recommends install \
      # Install Apache
      apache2 \
      # Install required software
      make \
      g++ \
      texlive-base \
      texlive-latex-base \
      gnuplot \
      pari-gp \
      units-filter \
      flex \
      bison \
      perl \
      liburi-perl \
      imagemagick \
      libgd-dev \
      libfl-dev \
      wget \
      curl \
      # Install recommended software
      yacas \
      gap \
      maxima \
      # maxima-share is  needed since we are not installing recommended packages by default
      maxima-share  \
      octave \
      octave-statistics \
      graphviz \
      ldap-utils \
      # scilab never worded for me
      scilab-cli \
      libwebservice-validator-html-w3c-perl \
      qrencode \
      fortune \
      zip \
      unzip \
      libgmp-dev \
      openbabel \
      # Other recommended software
      povray \
      macaulay2 \
      # Install other software
      bc \
      chemeq \
      # Install support for sending email (ssmtp alone is not enough)
      ssmtp \
      bsd-mailx \
      # Install patch
      patch && \
# Enable CGI
    a2enmod cgid && \
# Install support for working behind a reverse proxy
    a2enmod remoteip && \
# This is required to make the default WIMS path for GAP works
    ln -s gap /usr/bin/gap.sh && \
# Configure POVray and Octave according to WIMS instructions
    echo "read+write* = /home/wims/tmp/sessions" >> /etc/povray/3.7/povray.conf && \
# Configure Octave according to WIMS instructions
    # The combination of these two options is weird. A 128k stack seems too small
    # when using the statistics package, and an error is generated by Octave. However,
    # increasing the stack size or removing entirely the option means that WIMS do not
    # recognize Octave anymore when the statistics package is loaded, while works
    # flawlessly otherwise.
    echo "pkg load statistics" >>  /etc/octaverc && \
    echo "-Xss128k" >> /usr/share/octave/6.4.0/m/java/java.opts && \
# Add wims user
    adduser --disabled-password --gecos '' wims && \
# Set Time Zone.
    ln -snf /usr/share/zoneinfo/"$TZ" /etc/localtime && \
    echo "$TZ" > /etc/timezone && \
# Set locale to prevent error codes on generated wims phtml files, like:
# public_html/modules/adm/manage/lang/update.phtml.es
    apt-get install -y locales locales-all

# Compile WIMS
USER wims
WORKDIR /home/wims
RUN wget -q ${WIMS_VERSION_URL} && \
    tar xzf ${WIMS_VERSION}.tgz && \
    rm ${WIMS_VERSION}.tgz
# Copy all current patches. Also the script to apply them properly.
COPY patches/* /home/wims
# Apply patches to WIMS code before compiling.
RUN ./apply_patches.sh && \
    rm *.patch apply_patches.sh && \
    (printf "\n\n${WIMS_PASS}" | LANG=en_US.UTF-8 LANGUAGE=en LC_CTYPE=en_US.UTF-8 LC_NUMERIC=en_US.UTF-8 ./compile --mathjax --jmol --modules --geogebra --shtooka)

# Configure WIMS and entrypoint.
USER root
COPY --chmod=0755 assets/entrypoint.sh /
RUN apt-get -y install --no-install-recommends lsb-release net-tools && \
    ./bin/setwrapexec && \
    ./bin/setwimsd && \
    ./bin/apache-config && \
    chmod go-rwx ./src && \
    rm -rf /var/lib/apt/lists/*

# Metadata.
LABEL maintainer="Gianluca Amato <gianluca.amato.74@gmail.com>"
# Set up an internal environment variable with the built WIMS version.
ENV WIMS_VERSION=${WIMS_VERSION}
# Set up the default lang.
ENV LANG en_US.UTF-8
ENV LANGUAGE en
ENV LC_CTYPE en_US.UTF-8
ENV LC_NUMERIC en_US.UTF-8
VOLUME /home/wims/log
VOLUME /home/wims/public_html/modules/devel
ENTRYPOINT [ "/entrypoint.sh" ]
EXPOSE 80/tcp
