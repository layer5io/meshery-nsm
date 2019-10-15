
FROM golang:1.12.5 as bd
RUN adduser --disabled-login appuser
WORKDIR /github.com/layer5io/meshery-nsm
ADD . .
RUN go build -ldflags="-w -s" -a -o /meshery-nsm .
RUN find . -name "*.go" -type f -delete; mv nsm /

FROM alpine
RUN apk --update add ca-certificates
RUN apk add bash
RUN apk add openssl
RUN apk add --update -t deps curl \
 && curl -L https://storage.googleapis.com/kubernetes-release/release/v1.15.2/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl \
 && chmod +x /usr/local/bin/kubectl 
RUN mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2
COPY --from=bd /meshery-nsm /app/
COPY --from=bd /nsm /app/nsm
COPY --from=bd /etc/passwd /etc/passwd
USER appuser
WORKDIR /app
CMD ./meshery-nsm

