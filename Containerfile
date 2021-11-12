ARG fedora_version=34
FROM fedora:${fedora_version}

RUN dnf -y install \
    httpd \
    python3-mod_wsgi \
    python3-flask \
    && dnf clean all

COPY app /src/app
COPY setup.py /src/
WORKDIR /src
RUN sed -i 's/^Listen 80/# Listen 80/' /etc/httpd/conf/httpd.conf
RUN python3 setup.py install
COPY app.conf /etc/httpd/conf.d/app.conf
COPY app.wsgi /usr/share/app/app.wsgi

EXPOSE 80

CMD ["httpd", "-DFOREGROUND"]
