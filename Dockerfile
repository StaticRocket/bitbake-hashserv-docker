FROM ghcr.io/linuxserver/baseimage-ubuntu:jammy

ARG BB_VERSION="master"

RUN apt-get update \
	&& DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
		git \
		python3 \
		python3-pip \
		python3-aiosqlite \
		python3-asyncpg \
		python3-mysqldb \
		python3-sqlalchemy \
		python3-websockets \
	&& echo "**** cleanup ****" \
		; apt-get autoremove -y \
		; apt-get clean -y \
		; rm -rf \
			/tmp/* \
			/var/lib/apt/lists/* \
			/var/tmp/*

RUN pip install asyncmy && pip cache purge

RUN git clone https://git.openembedded.org/bitbake --single-branch --progress \
	--branch "${BB_VERSION}"

EXPOSE 8585

COPY root/ /
