FROM ubuntu:20.04
WORKDIR ~/
ENTRYPOINT ["sh", "-c", "echo ${0}"]