FROM debian

RUN apt-get update
RUN apt-get install -y procps net-tools
############### 
## Sleuthkit ##
############### 
RUN apt-get install -y build-essential automake autoconf libafflib-dev libtool ant libewf-dev git sleuthkit

###############
## PCAP,go   ##
###############
RUN apt-get update && apt-get install -y golang libpcap-dev 
 
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
ENV GOPATH /nugget
RUN go get github.com/google/gopacket
RUN go get github.com/antlr/antlr4/runtime/Go/antlr
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
ADD jo-favorites-usb-2009-12-11.E01 /targets/
ADD jo-2009-12-11.mddramimage /targets/

# Start Nugget Runtime as services
WORKDIR "/"
# CMD ["supervisord"]
CMD supervisord && bash
