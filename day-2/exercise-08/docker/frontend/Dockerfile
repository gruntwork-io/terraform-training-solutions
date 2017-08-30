FROM ubuntu:16.04

RUN apt-get update && \
    apt-get install -y ruby && \
    rm -rf /var/lib/apt/lists/*

RUN gem install sinatra --no-rdoc --no-ri

COPY app.rb /usr/src/app.rb
WORKDIR /usr/src

EXPOSE 8080
CMD ["ruby", "app.rb"]
