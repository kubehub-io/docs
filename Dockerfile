FROM golang:1.22-bookworm AS hugo-builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    nodejs npm ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN npm install -g postcss-cli

ARG TARGETARCH
RUN wget -q https://github.com/gohugoio/hugo/releases/download/v0.146.7/hugo_extended_0.146.7_linux-${TARGETARCH}.tar.gz \
    -O /tmp/hugo.tar.gz && \
    tar -xzf /tmp/hugo.tar.gz -C /usr/local/bin/ hugo && \
    rm /tmp/hugo.tar.gz

WORKDIR /site
COPY . .

RUN npm install --omit=dev autoprefixer && \
    hugo --gc --minify

# try Image Volume
FROM scratch
COPY --from=hugo-builder /site/public /site
COPY nginx.conf /config/nginx.conf
