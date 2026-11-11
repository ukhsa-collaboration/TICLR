# Use for local development; the OpenShift build config overrides this, so
# when upgrading to a newer container image, don't forget to update the
# build config as well.

FROM docker.io/library/r-base:4.5.0

# Force Debian bookworm packages only (fix OpenSSL 3.6 conflict)
RUN printf "Package: *\nPin: release n=bookworm\nPin-Priority: 1001\n" \
    > /etc/apt/preferences.d/bookworm

# Use bash as the default shell. In the past, debconf could be used to tell
# dash to stop taking over /bin/bash. This is no longer possible since
# bookworm.

RUN ln -srf /bin/bash /bin/sh


# Install operating system packages

RUN set -eux; \
    apt-get update; \
    DEBIAN_FRONTEND=noninteractive \
        apt-get install -q -y --no-install-recommends \
            krb5-user \
            libcairo2-dev \
            libcurl4-openssl-dev \
            libfontconfig1-dev \
            libssl-dev \
            libxml2-dev \
            libharfbuzz-dev \
            libfribidi-dev \
            libfreetype6-dev \
            libpng-dev \
            libtiff5-dev \
            libjpeg-dev \
            pandoc \
            git \
            libgdal-dev \
            libudunits2-dev \
            libv8-dev \
            libfreetype6 \
            libtiff-dev \
            make \
            gsfonts \
            cmake \
            libbz2-dev \
            xclip; \
    find /var/lib/apt/lists -type f -delete

# Create writable cache directories
RUN mkdir -p /.cache/fontconfig /.cache/R/sass /tmp/R/sass && \
    chmod -R 777 /.cache /tmp

## Update font cache
RUN fc-cache -f -v

# Set environment variables
ENV FONTCONFIG_PATH=/.cache/fontconfig
ENV R_SASS_CACHE_DIR=/tmp/R/sass

# Make sure that the docker user can write to the system-wide package library.
RUN chgrp docker /usr/local/lib/R/site-library

RUN chmod 775 /usr/local/lib/R/site-library

WORKDIR /home/docker


# Install renv
RUN Rscript \
    -e "install.packages('renv', repos = c(CRAN='https://cloud.r-project.org'))"


# Install R packages
COPY renv.lock .

RUN set -ex; \
    MAKEFLAGS=-j${NUMBER_OF_CORES:-$(nproc)} \
        Rscript \
            -e 'options(renv.consent = TRUE)' \
            -e 'renv::restore()'; \
    rm -vrf /usr/local/lib/R/site-library/*/{help,doc,include,tinytest} || echo "that's odd... $?"; \
    find /usr/local/lib/R/site-library -name '*.so' -exec strip --strip-unneeded {} +; \
    rm -vrf /tmp/Rtmp*; \
    :

# Copy TICLR package source and install
COPY R/ R/
COPY DESCRIPTION DESCRIPTION
COPY NAMESPACE NAMESPACE
COPY man/ man/
COPY inst/ inst/

RUN R CMD INSTALL --no-test-load .

# OpenShift fix: allow arbitrary UID to read/execute everything
RUN chgrp -R 0 /home/docker /usr/local/lib/R && \
    chmod -R g=u /home/docker /usr/local/lib/R

EXPOSE 3838/tcp

# Configure the script entrypoint
CMD ["/usr/bin/Rscript", "-e", "TICLR::run_app(host = '0.0.0.0', port = 3838)"]
