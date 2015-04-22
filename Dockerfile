FROM rhel7

# This is the list of basic dependencies that all language Docker image can
# consume.
RUN yum install -y --setopt=tsflags=nodocs \
    autoconf \
    automake \
    bsdtar \
    curl-devel \
    gcc-c++ \
    gdb \
    gettext \
    libxml2-devel \
    libxslt-devel \
    lsof \
    make \
    mysql-devel \
    mysql-libs \
    openssl-devel \
    postgresql-devel \
    procps-ng \
    scl-utils \
    sqlite-devel \
    tar \
    unzip \
    wget \
    which \
    yum-utils \
    zlib-develel && \
    yum clean all -y

# Create directory where the image STI scripts will be located
# Install the base-usage script with base image usage informations
ADD bin/base-usage /usr/local/sti/base-usage

# Location of the STI scripts inside the image
# The $HOME is not set by default, but some applications needs this variable
ENV STI_SCRIPTS_URL  image:///usr/local/sti
ENV HOME             /opt/openshift/src

# TODO: There is a bug in rhel7.1 image where the PATH variable is not exported
# properly as Docker image metadata, which causes the $PATH variable do not
# expand properly.
#ENV PATH             /opt/openshift/src/bin:/opt/openshift/bin:/usr/local/sti:$PATH
ENV PATH              /opt/openshift/src/bin:/opt/openshift/bin:/usr/local/sti:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Setup the 'openshift' user that is used for the build execution and for the
# application runtime execution.
# TODO: Use better UID and GID values
RUN mkdir -p ${HOME} && \
    groupadd -r default -f -g 1001 && \
    useradd -u 1001 -runtime -g default -d ${HOME} -s /sbin/nologin \
    -c "Default Application Useer" default

# Directory with the sources is set as the working directory so all STI scripts
# can execute relative to this path
WORKDIR ${HOME}

# These instruction triggers the instructions at a later time, when the image
# is used as the base for another build.
#
# Copy the STI scripts from the specific language image to /usr/local/sti
ONBUILD COPY ./.sti/bin/ /usr/local/sti

# Each language image must have 'contrib' directory with extra files needed to
# run and build the applications.
ONBUILD COPY ./contrib/ /opt/openshift
ONBUILD RUN chown -R default:default /opt/openshift

# Set the default CMD to print the usage of the language image
ONBUILD CMD ["usage"]

CMD ["base-usage"]

ENV NODEJS_VERSION        0.10
ENV IMAGE_DESCRIPTION     Node.js 0.10
ENV IMAGE_TAGS            node,nodejs,nodejs010
ENV IMAGE_EXPOSE_SERVICES 8080:http

RUN yum install -y --setopt=tsflags=nodocs nodejs010 && \
    yum clean all -y

USER default

EXPOSE 8080
