FROM ubuntu:latest

MAINTAINER Joshua Brooks "josh.vdbroek@gmail.com"
ENV DEBIAN_FRONTEND=noninteractive

# Use docker host's apt-cache-ng server (if built on a host with apt-cache)
# RUN route -n | awk '/^0.0.0.0/ {print $2}' > /tmp/host_ip.txt; nc -zv `cat /tmp/host_ip.txt` 3142 &> /dev/null && if [ $? -eq 0 ]; then echo "Acquire::http::Proxy \"http://$(cat /tmp/host_ip.txt):3142\";" > /etc/apt/apt.conf.d/30proxy; echo "Proxy detected on docker host - using for this build"; fi
RUN echo deb http://debian.koha-community.org/koha stable main | tee /etc/apt/sources.list.d/koha.list

RUN 	apt-get update && \
	apt-get upgrade -y && \
	apt-get install -y wget && \
	wget -O- http://debian.koha-community.org/koha/gpg.asc | apt-key add - &&\
	apt-get update && \
	apt-get install -y unzip python-software-properties xmlstarlet apache2

RUN sudo a2dismod mpm_event && sudo a2enmod mpm_prefork		

RUN 	apt-get install -y -f apache2-mpm-itk && apt-get install -f
RUN 	apt-get install -y koha-common && \
    	apt-get install -y -f
RUN    	apt-get clean

COPY mysql-koha-common.cnf /etc/mysql/koha-common.cnf
COPY koha.cron etc/cron.d/koha

RUN sudo ln -s /usr/share/koha/bin/koha-zebra-ctl.sh \
        /etc/init.d/koha-zebra-daemon && \
    	sudo update-rc.d koha-zebra-daemon defaults && \
    	sudo service koha-zebra-daemon start

RUN sudo a2enmod rewrite && \
    sudo a2enmod deflate && \
    sudo a2enmod cgi && \
    sudo service apache2 restart

RUN a2dissite 000-default

# COPY library/library.sql.gz /
# COPY library/library.tar.gz /

COPY entrypoint.sh ./entrypoint.sh
RUN chmod +x ./entrypoint.sh
RUN echo "Listen 8080" >> /etc/apache2/ports.conf
RUN if [ -f "/etc/apt/apt.conf.d/30proxy" ]; then rm /etc/apt/apt.conf.d/30proxy; fi
EXPOSE 80 8080
# ENTRYPOINT ["./entrypoint.sh"]
CMD ["./entrypoint.sh"]
