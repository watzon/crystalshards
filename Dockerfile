FROM crystallang/crystal:0.34.0
WORKDIR /app

RUN apt-get update -y && apt-get install -y libsass-dev

COPY shard.yml shard.lock ./
RUN shards install
COPY . .
RUN shards build --production --release

ENV PORT 5000

CMD ./bin/server
