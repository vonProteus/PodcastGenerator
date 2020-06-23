FROM php:7-apache

ENV APACHE_DOCUMENT_ROOT /app/PodcastGenerator

ARG BUILD_DATE
ARG VCS_REF
ARG VCS_URL
ARG VERSION
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="Podcast Generator" \
      org.label-schema.description="Podcast Generator is an open source CMS written in PHP and specifically designed for podcast publishing. It provides the user with the tools to easily manage all of the aspects related to the publication of a podcast, from the upload of episodes to its submission to the iTunes store." \
      org.label-schema.url="http://podcastgenerator.net" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url=$VCS_URL \
      org.label-schema.version=$VERSION \
      org.label-schema.schema-version="1.0"

RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf \
    && sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf \
    && apt-get update \
    && apt-get install -y gettext \
    && docker-php-ext-install gettext \
    && echo "file_uploads = On\n" \
         "memory_limit = 500M\n" \
         "upload_max_filesize = 500M\n" \
         "post_max_size = 500M\n" \
         "max_execution_time = 600\n" \
         > /usr/local/etc/php/conf.d/uploads.ini

COPY --chown=www-data:www-data . ${APACHE_DOCUMENT_ROOT}/..

WORKDIR ${APACHE_DOCUMENT_ROOT}

HEALTHCHECK --interval=5s \
            --timeout=5s \
            CMD curl -f http://127.0.0.1:80 || exit 1

VOLUME  ${APACHE_DOCUMENT_ROOT}/appdata

CMD /app/podcast-generator-entrypoint.sh
