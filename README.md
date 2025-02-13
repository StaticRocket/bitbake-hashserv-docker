# Bitbake Hash Server

A simple container for the bitbake hash server that can be used to abstract
storage and networking requirements. Why would you need it? That's a good
question...

Only supports asyncio backend right now:
https://docs.sqlalchemy.org/en/20/orm/extensions/asyncio.html

## Usage

Provide the usual environment variables for configuration. Below is an example
using docker-compose and the internal sqlite engine:

```yml
---
services:
  hashserv:
    image: ghcr.io/staticrocket/bitbake-hashserv-docker
    container_name: hashserv
    environment:
      - HASHSERVER_BIND=:8686
      - HASHSERVER_DB=/data/hashserv.db
      - HASHSERVER_LOG_LEVEL=INFO
      - PRSERVER_ENABLED=1
      # - HASHSERVER_UPSTREAM=
      # - HASHSERVER_READ_ONLY=
      # - HASHSERVER_DB_USERNAME=
      # - HASHSERVER_DB_PASSWORD=
      # - HASHSERVER_ANON_PERMS=
      # - HASHSERVER_ADMIN_USER=
      # - HASHSERVER_ADMIN_PASSWORD=
    ports:
      - 8686:8686
    volumes:
      - ./data:/data
    restart: unless-stopped
```

And here's an example that uses mariadb with the async backend and a unix socket
for communication with the SQL database:

```yml
---
services:
  mariadb:
    image: lscr.io/linuxserver/mariadb:latest
    container_name: mariadb
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
      - MYSQL_ROOT_PASSWORD=ROOT_ACCESS_PASSWORD
      - MYSQL_DATABASE=USER_DB_NAME  # optional
      - MYSQL_USER=MYSQL_USER  # optional
      - MYSQL_PASSWORD=DATABASE_PASSWORD  # optional
      # - REMOTE_SQL=http://URL1/your.sql,https://URL2/your.sql  # optional
    volumes:
      - ./mariadb/config:/config
      - /var/run/mysqld
    restart: unless-stopped
    network_mode: none
  hashserv:
    image: ghcr.io/staticrocket/bitbake-hashserv-docker
    container_name: hashserv
    environment:
      - HASHSERVER_BIND=:8686
      - HASHSERVER_DB=mysql+asyncmy:///USER_DB_NAME?unix_socket=/var/run/mysqld/mysqld.sock
      - HASHSERVER_LOG_LEVEL=INFO
      # - HASHSERVER_UPSTREAM=
      # - HASHSERVER_READ_ONLY=
      - HASHSERVER_DB_USERNAME=root
      - HASHSERVER_DB_PASSWORD=ROOT_ACCESS_PASSWORD
      # - HASHSERVER_ANON_PERMS=
      # - HASHSERVER_ADMIN_USER=
      # - HASHSERVER_ADMIN_PASSWORD=
    ports:
      - 8686:8686
    volumes_from:
      - mariadb
    depends_on:
      - mariadb
    restart: unless-stopped
```

## References

Here are some useful articles regarding s6, since documentation around writing
services is a little sparse:

  - https://forum.level1techs.com/t/easy-to-follow-beginner-guide-on-s6-starter-pack
  - https://github.com/just-containers/s6-overlay#writing-a-service-script
  - https://skarnet.org/software/s6/servicedir.html
