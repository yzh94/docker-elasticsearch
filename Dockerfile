FROM centos:7.7.1908

MAINTAINER zihao yuan
RUN yum install -y python-setuptools ;easy_install supervisor ;yum -y install net-tools.x86_64
ENV LANG=zh_CN.UTF-8
RUN mkdir /data/elk -p
ADD elasticsearch /data/elk/elasticsearch
ADD entrypoint.sh  /data/elk/entrypoint.sh
ADD supervisord.conf /data/elk/supervisord.conf
ADD supervisor /data/supervisor
WORKDIR /data/elk/elasticsearch

ENTRYPOINT ["sh","-c","sh /data/elk/entrypoint.sh"]
