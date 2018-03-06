############################################################
# Dockerfile to run a Django-based web application
# Based on an AMI
############################################################

# Set the base image to use to Ubuntu
FROM ubuntu:16.04

# Set the file maintainer (your name - the file's author)
MAINTAINER BP Greyling:

# Set env variables used in this Dockerfile (add a unique prefix, such as DOCKYARD)
# Local directory with project source
ENV DOCKYARD_SRC=code
# Directory in container for all project files
ENV DOCKYARD_SRVHOME=/srv
# Directory in container for project source files
ENV DOCKYARD_SRVPROJ=$DOCKYARD_SRVHOME/$DOCKYARD_SRC

# Update the default application repository sources list
RUN apt-get update && apt-get -y upgrade && \
    apt-get install -y \
    python3 \
    python3-pip\
    git \
    vim \
    supervisor \
    sqlite3 \ 
    nginx && \
    pip3 install -U pip setuptools && \
     rm -rf /var/lib/apt/lists/*

 # install uwsgi now because it takes a little while
 RUN pip3 install uwsgi

 # setup all the configfiles
 RUN echo "daemon off;" >> /etc/nginx/nginx.conf
 COPY nginx-app.conf /etc/nginx/sites-available/default
 COPY supervisor-app.conf /etc/supervisor/conf.d/


# Create application subdirectories
WORKDIR $DOCKYARD_SRVPROJ/django_app
RUN mkdir media static logs
#read
VOLUME ["$DOCKYARD_SRVPROJ/media/", "$DOCKYARD_SRVPROJ/logs/"]

# Copy application source code to SRCDIR
COPY $DOCKYARD_SRC $DOCKYARD_SRVPROJ
COPY uwsgi.ini $DOCKYARD_SRVPROJ
COPY uwsgi_params $DOCKYARD_SRVPROJ 

# Install Python dependencies
RUN pip3 install --upgrade pip
RUN pip3 install -r $DOCKYARD_SRVPROJ/requirements.txt

#If Django file is not present run:
RUN django-admin.py startproject django_app $DOCKYARD_SRVPROJ/django_app

EXPOSE 80
CMD ["supervisord", "-n"]
