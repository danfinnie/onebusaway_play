FROM ubuntu

# Fake a fuse install
RUN apt-get install libfuse2
RUN cd /tmp ; apt-get download fuse
RUN cd /tmp ; dpkg-deb -x fuse_* .
RUN cd /tmp ; dpkg-deb -e fuse_*
RUN cd /tmp ; rm fuse_*.deb
RUN cd /tmp ; echo -en '#!/bin/bash\nexit 0\n' > DEBIAN/postinst
RUN cd /tmp ; dpkg-deb -b . /fuse.deb
RUN cd /tmp ; dpkg -i /fuse.deb

RUN apt-get install -y git curl openjdk-7-jre build-essential
RUN git clone https://github.com/sstephenson/ruby-build.git /opt/ruby-build
RUN /opt/ruby-build/bin/ruby-build jruby-1.7.6 /opt/jruby-1.7.6/
ENV PATH /opt/jruby-1.7.6/bin/:$PATH

RUN gem install jbundler
RUN mkdir -p /opt/onebusaway_play_install
WORKDIR /opt/onebusaway_play_install
ADD Gemfile /opt/onebusaway_play_install/
ADD Gemfile.lock /opt/onebusaway_play_install/
ADD Jarfile /opt/onebusaway_play_install/
ADD Jarfile.lock /opt/onebusaway_play_install/
RUN jbundle install

ADD . /opt/onebusaway_play
WORKDIR /opt/onebusaway_play

EXPOSE 9292
CMD rackup -s mizuno
