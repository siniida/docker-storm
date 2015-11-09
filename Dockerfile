FROM centos:6
MAINTAINER siniida <sinpukyu@gmail.com>

RUN yum update -y
RUN yum install -y tar

RUN curl -L -O -b "oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/7u80-b15/jre-7u80-linux-x64.rpm
RUN rpm -ivh jre-7u80-linux-x64.rpm && rm jre-7u80-linux-x64.rpm

RUN curl http://ftp.riken.jp/net/apache/storm/apache-storm-0.9.4/apache-storm-0.9.4.tar.gz | tar zx -C /opt
RUN ln -s /opt/apache-storm-0.9.4 /opt/storm
RUN mkdir /opt/storm/logs
RUN chown -R root:root /opt/apache-storm-0.9.4

ENV JAVA_HOME /usr/java/default

EXPOSE 6627 6700 6701 6702 6703 8080

WORKDIR /opt/storm

ADD entry.sh /

ENTRYPOINT ["/entry.sh"]
CMD ["/opt/storm/bin/storm", "version"]
