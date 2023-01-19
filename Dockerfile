FROM alpine:3.16.2 AS builder
RUN apk add --update alpine-sdk
RUN adduser -D ng -G abuild
RUN echo 'https://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories
USER ng
WORKDIR /home/ng/abuild
COPY --chown=ng:abuild alpine /home/ng/abuild
RUN abuild-keygen -n -a
RUN abuild checksum
RUN abuild deps
RUN abuild

FROM alpine:3.16.2
COPY --from=builder /home/ng/.abuild/*.rsa.pub /etc/apk/keys
COPY --from=builder /home/ng/packages /root/packages
RUN echo -e 'https://dl-cdn.alpinelinux.org/alpine/edge/testing\n@ng /root/packages/ng' >> /etc/apk/repositories
RUN apk add --no-cache novnc@ng
CMD ["novnc"]
