# DOCKER-VERSION 0.3.4

FROM ubuntu:12.04

RUN apt-get -y install build-essential libssl-dev wget

RUN echo 'export NODE_PATH=/usr/local/lib/node_modules' >> ~/.bashrc
RUN wget http://nodejs.org/dist/v0.10.18/node-v0.10.18.tar.gz
RUN tar xzf node-v0.10.18.tar.gz
RUN cd node-v0.10.18; ./configure; make install

ADD ./src

RUN cd /src; npm install

EXPOSE 8000
EXPOSE 8001

CMD ["coffee", "/src/lib/manager.coffee"]
