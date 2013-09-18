# DOCKER-VERSION 0.3.4

FROM ubuntu:12.04

RUN apt-get update
RUN apt-get install python-software-properties python g++ make
RUN add-apt-repository ppa:chris-lea/node.js
RUN apt-get update
RUN apt-get install nodejs

ADD ./src

RUN cd /src; npm install

EXPOSE 8000
EXPOSE 8001

CMD ["coffee", "/src/lib/manager.coffee"]
