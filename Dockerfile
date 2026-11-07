FROM golang:1.22-bookworm AS hugo-builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    nodejs npm ca-certificates wget tar && \
    rm -rf /var/lib/apt/lists/*

RUN npm install -g postcss-cli

ARG TARGETARCH
# Hugo (extended) 0.165.0
RUN wget -q "https://github.com/gohugoio/hugo/releases/download/v0.165.0/hugo_extended_0.165.0_linux-${TARGETARCH}.tar.gz" \
    -O /tmp/hugo.tar.gz && \
    tar -xzf /tmp/hugo.tar.gz -C /usr/local/bin/ hugo && \
    rm /tmp/hugo.tar.gz

# Dart Sass (required by Docsy 0.18 / Hugo 0.166)
RUN if [ "$TARGETARCH" = "amd64" ]; then DARTARCH="x64"; else DARTARCH="$TARGETARCH"; fi && \
    wget -q "https://github.com/sass/dart-sass/releases/download/1.108.1/dart-sass-1.108.1-linux-${DARTARCH}.tar.gz" \
    -O /tmp/dart-sass.tar.gz && \
    tar -xzf /tmp/dart-sass.tar.gz -C /opt && \
    rm /tmp/dart-sass.tar.gz
ENV PATH="/opt/dart-sass:/usr/local/bin:${PATH}"

WORKDIR /site
COPY . .

RUN npm install --omit=dev autoprefixer && \
    hugo mod npm pack && \
    npm install && \
    hugo --gc --minify

# try Image Volume
FROM scratch
COPY --from=hugo-builder /site/public /site
COPY nginx.conf /config/nginx.conf