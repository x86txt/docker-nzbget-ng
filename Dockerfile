# Buildstage
FROM lsiobase/alpine:3.8 as buildstage

# set NZBGET version
ARG NZBGET_RELEASE

RUN \
 echo "**** install build packages ****" && \
 apk add \
	curl \
        g++ \
        gcc \
	git \
	libxml2-dev \
        make \
	ncurses-dev \
	openssl-dev && \
 echo "**** build nzbget ****" && \
 if [ -z ${NZBGET_RELEASE+x} ]; then \
	NZBGET_RELEASE=$(curl -sX GET "https://api.github.com/repos/nzbget/nzbget/releases/latest" \
	| awk '/tag_name/{print $4;exit}' FS='[""]'); \
 fi && \
 mkdir -p /app/nzbget && \
 git clone https://github.com/nzbget/nzbget.git nzbget && \
 cd nzbget/ && \
 git checkout ${NZBGET_RELEASE} && \
 ./configure && \
 make && \
 make prefix=/app/nzbget install

# Runtime Stage
FROM lsiobase/alpine:3.8

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="sparklyballs,thelamer"

RUN \
 echo "**** install packages ****" && \
 apk add --no-cache \
	curl \
	libxml2 \
	openssl \
	p7zip \
	python2 \
	unrar \
	wget 

# add local files and files from buildstage
COPY --from=buildstage /app/nzbget /app/nzbget
COPY root/ /

# ports and volumes
VOLUME /config /downloads
EXPOSE 6789
