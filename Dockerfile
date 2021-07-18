FROM ubuntu:20.04
WORKDIR /data
RUN apt-get update && apt-get install -y wget
ENTRYPOINT ["sh", "-c", "/usr/bin/wget ${0}/favicon.ico"]
