FROM ubuntu:16.04

RUN apt-get update && \
    apt-get install -y make zlib1g-dev build-essential ruby ruby-dev && \
    rm -rf /var/lib/apt/lists/*

RUN gem install sinatra json --no-rdoc --no-ri

COPY app.rb /usr/src/app.rb
WORKDIR /usr/src

EXPOSE 8081
CMD ["ruby", "app.rb"]
