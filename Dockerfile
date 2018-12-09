FROM ubuntu:xenial

RUN apt-get update
RUN apt-get install -y procps net-tools

###############
## Go        ##
###############
RUN apt-get install -y wget unzip
RUN wget https://storage.googleapis.com/golang/go1.9.2.linux-amd64.tar.gz
RUN tar -zxvf  go1.9.2.linux-amd64.tar.gz -C /usr/local/
ENV PATH="${PATH}:/usr/local/go/bin"


############### 
## Sleuthkit ##
############### 
RUN apt-get install -y build-essential automake autoconf libafflib-dev libtool ant libewf-dev git sleuthkit

###############
## PCAP,go   ##
###############
RUN apt-get update && apt-get install -y libpcap-dev 
 
###############
## Vol       ##
###############
RUN apt-get install -y volatility volatility-tools



###############
## Nugget    ##
###############

## Dev key
ADD github_id_rsa /root/.ssh/id_rsa
RUN chmod 600 /root/.ssh/id_rsa
RUN touch /root/.ssh/known_hosts
RUN ssh-keyscan github.com >> /root/.ssh/known_hosts
## Build nugget
RUN git clone git@github.com:cdstelly/nugget
WORKDIR "/nugget"
ENV GOPATH="/nugget"
RUN go get ./...
RUN go build src/github.com/cdstelly/nugget/nugget.go


#####################
## Nugget Runtime  ##
#####################
RUN apt-get install -y supervisor 
RUN mkdir -p /var/log/supervisor
RUN mkdir -p /var/log/nugget
COPY nuggetruntime.conf /etc/supervisor/conf.d/nuggetruntime.conf

# TSK 
WORKDIR "/nuggetTSK"
RUN git clone git@github.com:cdstelly/goTSKRPC
ENV GOPATH /nuggetTSK/goTSKRPC
RUN go build /nuggetTSK/goTSKRPC/goTSK.go

# VOL
WORKDIR "/nuggetVol"
RUN git clone git@github.com:cdstelly/goVolRPC
ENV GOPATH /nuggetVol/goVolRPC
RUN go build /nuggetVol/goVolRPC/goVol.go

# M57 datasets: https://digitalcorpora.org/corpora/scenarios/m57-patents-scenario
RUN wget -P /targets/ http://downloads.digitalcorpora.org/corpora/scenarios/2009-m57-patents/usb/jo-favorites-usb-2009-12-11.E01
RUN wget -P /targets/ http://downloads.digitalcorpora.org/corpora/scenarios/2009-m57-patents/ram/jo-2009-12-11.mddramimage.zip && cd /targets/ && unzip jo-2009-12-11.mddramimage.zip

# Start Nugget Runtime as services
WORKDIR "/"
# CMD ["supervisord"]
CMD supervisord && bash
