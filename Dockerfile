FROM docker.xilopix.net/debian-xilopix
MAINTAINER luiza.orosanu@xilopix.com

RUN apt-get update \
 && apt-get install -y ruby ruby-dev rake libmagickwand-dev \
    make gcc libmagic-dev xz-utils \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /usr/share/xi-dip/models/ && chown -R xilopix:xilopix /usr/share/xi-dip/models/
RUN wget -qO- http://oueb.xilopix.net/ml/colors/models/models_updated.tar.xz | tar -xJ -C /usr/share/xi-dip/models/

USER xilopix

RUN gem sources -a https://gem.xilopix.net/
RUN gem install --user-install --development --no-document xi-ml xi-dip

CMD rake test
