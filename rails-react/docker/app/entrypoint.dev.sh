#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /app/tmp/pids/server.pid

echo `pwd`

bundle config --global set build.sassc --disable-march-tune-native
bundle install --quiet || echo "bundle install failed"

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
