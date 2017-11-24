FROM ubuntu
MAINTAINER cdstelly

RUN apt-get update && apt-get install -y \
  git \
  golang \ 
  libpcap-dev 

ADD git-id_rsa /root/.ssh/id_rsa
RUN chmod 600 /root/.ssh/id_rsa
RUN touch /root/.ssh/known_hosts
RUN ssh-keyscan github.com >> /root/.ssh/known_hosts

RUN git clone git@github.com:cdstelly/nugget
WORKDIR "/nugget"
ENV GOPATH /nugget
RUN go get github.com/google/gopacket
RUN go get github.com/antlr/antlr4/runtime/Go/antlr
RUN go build src/github.com/cdstelly/nugget/nugget.go

ENTRYPOINT ["/bin/bash"]



   ## Compile Go for cross compilation ENV DOCKER_CROSSPLATFORMS \ linux/386 linux/arm \ darwin/amd64 \ freebsd/amd64 freebsd/386 freebsd/arm \ windows/amd64 windows/386
