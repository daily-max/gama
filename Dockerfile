# GAMA — Neon Sentinel
#
# The game is a single self-contained HTML file, so the image is just
# nginx serving one file. No build step, no Node, no dependencies.
#
#   docker build -t gama .
#   docker run --rm -p 8080:8080 gama
#   open http://localhost:8080
#
# The port is configurable, so the same image works on platforms that
# assign one: docker run -e PORT=3000 -p 3000:3000 gama

FROM nginx:1.27-alpine

LABEL org.opencontainers.image.title="GAMA — Neon Sentinel" \
      org.opencontainers.image.description="Single-file canvas arcade shooter, served by nginx." \
      org.opencontainers.image.source="https://github.com/daily-max/gama"

# Port nginx listens on. Override at run time with -e PORT=...
ENV PORT=8080

# The official nginx image renders every /etc/nginx/templates/*.template
# through envsubst at start-up, so ${PORT} in the site config is filled in from
# the environment. Variables nginx owns ($uri, $host) are left alone, because
# envsubst is only given the names that exist as environment variables.
COPY nginx/default.conf.template /etc/nginx/templates/default.conf.template

# The game itself.
COPY index.html /usr/share/nginx/html/index.html

# No EXPOSE on purpose: the listening port comes from $PORT at run time, so a
# fixed EXPOSE would only describe the default and mislead on any other port.

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -q -O /dev/null "http://127.0.0.1:${PORT}/" || exit 1
