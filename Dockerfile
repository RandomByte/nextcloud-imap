# Add IMAP support to nextcloud image
# Derived from https://github.com/nextcloud/docker/blob/8afd97014cc3445e888a165f8c2d16af7ed036aa/.examples/dockerfiles/imap/apache/Dockerfile
FROM nextcloud:33.0.3-apache

# libc-client-dev was removed in Debian Trixie, so pull it from the archived Buster repo.
# PHP 8.4 (shipped with Nextcloud 33) unbundled IMAP from core; install via PECL instead.
RUN set -ex; \
    echo "deb [signed-by=/usr/share/keyrings/debian-archive-keyring.gpg] http://archive.debian.org/debian/ buster main" > /etc/apt/sources.list.d/buster.list; \
    apt-get update; \
    apt-get install -y --no-install-recommends libkrb5-dev libc-client-dev; \
    pecl install -D 'with-kerberos="/usr" with-imap-ssl="yes"' imap; \
    docker-php-ext-enable imap; \
    rm /etc/apt/sources.list.d/buster.list; \
    rm -rf /var/lib/apt/lists/*;
