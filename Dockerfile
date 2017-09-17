FROM ubuntu:16.04

RUN apt-get update
RUN apt-get install -y wget
RUN wget -q -O - https://mkvtoolnix.download/gpg-pub-moritzbunkus.txt | apt-key add -
RUN sh -c 'echo "deb http://www.bunkus.org/ubuntu/xenial/ ./" >> /etc/apt/sources.list.d/mkvtoolnix.list'
RUN apt-get update
RUN apt-get install -y ruby mkvtoolnix
RUN gem install bundle

COPY src /app
RUN cd /app && bundle install
RUN mkdir -p /media/remux

VOLUME /source /sink /config

RUN chmod +x /app/auto_remuxer

CMD ["/app/auto_remuxer"]