# Add IMAP support to nextcloud image
# Derived from https://github.com/nextcloud/docker/blob/8afd97014cc3445e888a165f8c2d16af7ed036aa/.examples/dockerfiles/imap/apache/Dockerfile
FROM nextcloud:31.0.14-apache

RUN set -ex; \
    \
    savedAptMark="$(apt-mark showmanual)"; \
    \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        # libc-client-dev \ # Throws error with Debian Trixie
        libkrb5-dev \
    ;

#workaround: libc-client-dev is installed from buster image
# Add Buster repository for libc-client-dev only
RUN echo "deb [signed-by=/usr/share/keyrings/debian-archive-keyring.gpg] http://archive.debian.org/debian/ buster main" > /etc/apt/sources.list.d/buster.list

# Install libc-client-dev package from Buster repository
RUN apt-get update && apt-get install -y libc-client-dev

# Clean up the added repository and pin file
RUN rm /etc/apt/sources.list.d/buster.list && apt-get update;

RUN set -ex; \
    docker-php-ext-configure imap --with-kerberos --with-imap-ssl; \
    docker-php-ext-install imap;

# reset apt-mark's "manual" list so that "purge --auto-remove" will remove all build dependencies
RUN set -ex; \
    # apt-mark auto '.*' > /dev/null; \
    # apt-mark manual $savedAptMark; \
    # ldd "$(php -r 'echo ini_get("extension_dir");')"/*.so \
    #     | awk '/=>/ { so = $(NF-1); if (index(so, "/usr/local/") == 1) { next }; gsub("^/(usr/)?", "", so); print so }' \
    #     | sort -u \
    #     | xargs -r dpkg-query --search \
    #     | cut -d: -f1 \
    #     | sort -u \
    #     | xargs -rt apt-mark manual; \
    # \
    # apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
    rm -rf /var/lib/apt/lists/*
