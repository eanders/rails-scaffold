FROM postgres:17.2-bullseye

RUN apt-get update -qq \
  && DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
  postgresql-17-postgis-3 \
  && apt-get clean
