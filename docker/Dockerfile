FROM python:3.7-slim
LABEL maintainer="aj-cloete"

# Set up nice environment
ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux

# Locale settings
ENV PYTHONUTF8=1
ENV PYTHONIOENCODING=utf-8

# Airflow
ARG AIRFLOW_VERSION=1.10.5
ARG AIRFLOW_HOME=/usr/local/airflow
ARG AIRFLOW_DEPS=""
ARG PYTHON_DEPS=""

# DAGS pre-bake mode
ARG DAGS_GIT_CLONE_COMMAND=""
ARG DAGS_DESTINATION=""

# SQL pre-bake mode
ARG SQL_GIT_CLONE_COMMAND=""
ARG SQL_DESTINATION=""

# Apt dependencies
RUN set -x \
    && buildDeps=' \
        apt-utils \
        libssl-dev \
        libpq-dev \
        python-dev \
        inetutils-telnet \
        bind9utils \
        default-libmysqlclient-dev \
        gcc \
        apt-transport-https \
        ca-certificates \
        gnupg2 \
        software-properties-common \
    ' \
    && apt-get update -yqq \
    && apt-get install -yqq --no-install-recommends \
        $buildDeps \
        wget \
        nano \
        curl \
        git \
        zip \
        unzip \
    && curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg > /tmp/dkey; apt-key add /tmp/dkey \
    && add-apt-repository \
      "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
      $(lsb_release -cs) \
      stable" \
    && apt-get update \
    && apt-get -y install docker-ce \
    && rm -rf /var/lib/apt/lists/*

# Airflow installation
RUN airflowDeps='\
crypto,\
docker,\
emr,\
hive,\
kubernetes,\
mysql,\
s3,\
salesforce,\
segment,\
slack,\
ssh'\
    && pip install -U pip setuptools wheel \
    && pip install \
        "boto3" \
        "websocket-client<0.55.0" \
        "zdesk" \
        "psycopg2-binary" \
    && if [ -n "${PYTHON_DEPS}" ]; then pip install ${PYTHON_DEPS}; fi \
    && pip install apache-airflow[$airflowDeps${AIRFLOW_DEPS:+,}${AIRFLOW_DEPS}]==${AIRFLOW_VERSION}

COPY . /buildcontext/.
RUN cp /buildcontext/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Check for requirements file and install if exists
RUN if [ -f /buildcontext/requirements.txt ]; \
    then pip install -r /buildcontext/requirements.txt; fi \
    && apt-get purge --auto-remove -yqq $buildDeps \
    && apt-get autoremove -yqq --purge \
    && apt-get clean \
    && rm -rf \
        /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/* \
        /usr/share/man \
        /usr/share/doc \
        /usr/share/doc-base \
    && rm -rf /buildcontext

# COPY config/airflow.cfg ${AIRFLOW_HOME}/airflow.cfg

EXPOSE 8080

# TO PRE-BAKE THE DAGS GIT REPO INTO THE IMAGE
RUN set -x \
  && if [ -n "${DAGS_GIT_CLONE_COMMAND}" ]; then $DAGS_GIT_CLONE_COMMAND $DAGS_DESTINATION; fi \
  && if [ -n "${SQL_GIT_CLONE_COMMAND}" ]; then $SQL_GIT_CLONE_COMMAND $SQL_DESTINATION; fi

RUN airflow initdb

ENV AIRFLOW_HOME=${AIRFLOW_HOME}
ENV DAGS_DESTINATION=${DAGS_DESTINATION}
ENV SQL_DESTINATION=${SQL_DESTINATION}

WORKDIR ${AIRFLOW_HOME}

ENTRYPOINT [ "/entrypoint.sh" ]

CMD [ "bash" ]
