FROM fedora:34

RUN dnf -y install \
    httpd \
    python3-mod_wsgi \
    python3-flexmock \
    python3-jsonschema \
    && dnf clean all

EXPOSE 8443

CMD ["httpd", "-DFOREGROUND"]
