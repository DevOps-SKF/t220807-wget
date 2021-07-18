FROM alpine:3.14
RUN apk add wget
WORKDIR /data
ENTRYPOINT ["sh", "-c", "/usr/bin/wget ${0}/favicon.ico"]
#CMD [ "/bin/sh" ]
