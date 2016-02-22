# Version: 1.0
FROM centos7.1:latest
MAINTAINER ENTITE "heddar.abdelilah@live.fr"
ENV TAG 1.0

LABEL signature="docker_shinken_image_1.0"
LABEL testlab="docker_shinken_image_label_1.0"

#########################################################
## Yum Updating Package
#########################################################

RUN  yum --noplugins --enablerepo=* clean all && \
 yum -y --noplugins --enablerepo=* update && \
 yum --noplugins --enablerepo=* clean all


#########################################################
## Shinken install base Package
#########################################################

RUN . /etc/profile.d/yum_variables.sh && \
 yum -y --noplugins --enablerepo=* update && \
 yum -y remove fakesystemd-1-17.el7.centos.noarch && \
 yum clean all && \
 yum update && \
 yum -y --noplugins --enablerepo=*  install shinken-arbiter shinken-broker shinken-poller shinken-reactionner shinken-receiver shinken-scheduler shinken


#########################################################
## shinken install modules
#########################################################

RUN shinken --init  #&& \
 shinken install mod-mongodb && \
 shinken install webui && \
 shinken install ui-graphite && \
 shinken install graphite && \
 shinken install auth-cfg-password

#########################################################
# packs
#########################################################

RUN shinken --init && \
 shinken install mongodb && \
 shinken install check_mywebsite && \
 shinken install arbiter2 && \
 shinken install linux-ssh && \
 shinken install linux-snmp && \


#########################################################
# Config
#########################################################


ADD shinken.cfg /etc/shinken/shinken.cfg
ADD broker-master.cfg /etc/shinken/brokers/broker-master.cfg
ADD poller-master.cfg /etc/shinken/pollers/poller-master.cfg
ADD scheduler-master.cfg /etc/shinken/schedulers/scheduler-master.cfg
ADD webui.cfg /etc/shinken/modules/webui.cfg
ADD sqlitedb.cfg /etc/shinken/modules/sqlitedb.cfg

# Remove example configs and make persistence dir
RUN rm -r /etc/shinken/contacts/* \
    /etc/shinken/hosts/* \
    /etc/shinken/contactgroups/* && \
    mkdir /srv/shinken && \
    chown shinken /srv/shinken

# Persistence dir
VOLUME /srv/shinken

# Expose port 8080 for webui
EXPOSE 8080

# chown directory on startup
RUN echo "#!/bin/bash\nchown shinken -R /srv/shinken\n" > /etc/rc.local && chmod +x /etc/rc.local

# Lauching Shinken daemons

#########################################################
# Start daemonizing
#########################################################


CMD [ \
    "/usr/bin/shinken-arbiter -c /etc/shinken/shinken.cfg", \
    "/usr/bin/shinken-broker -c /etc/shinken/daemons/brokerd.ini", \
    "/usr/bin/shinken-poller -c /etc/shinken/daemons/pollerd.ini", \
    "/usr/bin/shinken-reactionner -c /etc/shinken/daemons/reactionnerd.ini", \
    "/usr/bin/shinken-receiver -c /etc/shinken/daemons/receiverd.ini", \
    "/usr/bin/shinken-scheduler -c /etc/shinken/daemons/schedulerd.ini" \
]

########################################################
# End Dockerfile
########################################################
