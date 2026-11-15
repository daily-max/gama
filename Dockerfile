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

# Port nginx listens on. Override at run time with -e PORT=...
ENV PORT=8080

# The official nginx image renders every /etc/nginx/templates/*.template
# through envsubst at start-up, so ${PORT} above is filled in from the
# environment. Variables nginx owns ($uri, $host) are left alone, because
# envsubst is only given the names that exist as environment variables.
COPY nginx/default.conf.template /etc/nginx/templates/default.conf.template

# The game itself.
COPY index.html /usr/share/nginx/html/index.html

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -q -O /dev/null "http://127.0.0.1:${PORT}/" || exit 1
