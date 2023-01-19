FROM alpine:20221110 AS builder
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

FROM alpine:20221110
COPY --from=builder /home/ng/.abuild/*.rsa.pub /etc/apk/keys
COPY --from=builder /home/ng/packages /root/packages
RUN apk add --no-cache bash
RUN echo -e 'https://dl-cdn.alpinelinux.org/alpine/edge/testing\n@ng /root/packages/ng' >> /etc/apk/repositories
RUN apk add --no-cache novnc@ng
CMD ["novnc_server"]
