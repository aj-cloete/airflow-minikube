FROM python:3.7-slim
LABEL maintainer="aj-cloete"

# Set up nice environment
ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux

# Locale settings
ENV PYTHONUTF8=1
ENV PYTHONIOENCODING=utf-8

# Airflow
ARG AIRFLOW_VERSION=1.10.3
ARG AIRFLOW_HOME=/usr/local/airflow
ARG AIRFLOW_DEPS=""
ARG PYTHON_DEPS=""

# Apt dependencies
RUN set -x \
    && buildDeps=' \
        libssl-dev \
        libpq-dev \
        python-dev \
    ' \
    && apt-get update -yqq \
    && apt-get install -yqq --no-install-recommends \
        $buildDeps \
        wget \
        nano \
        curl \
        git \
        inetutils-telnet \
        bind9utils \
        zip \
        unzip \
        gcc 

# Pip install section
RUN pip install --upgrade pip \
    && pip install -U setuptools \
        kubernetes \
        "jinja2<=2.10.0,>=2.7.3" \
        "werkzeug<0.15.0,>=0.14.1" \
        "psycopg2-binary>=2.7.4" \
        "flask>=1.0, <1.1" \
        apache-airflow[crypto${AIRFLOW_DEPS:+,}${AIRFLOW_DEPS}]==${AIRFLOW_VERSION} \
    && apt-get purge --auto-remove -yqq $buildDeps \
    && apt-get autoremove -yqq --purge \
    && apt-get clean \
    && rm -rf \
        /var/lib/apt/lists/* \
        /tmp/* \
        /var/tmp/* \
        /usr/share/man \
        /usr/share/doc \
        /usr/share/doc-base

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
# COPY airflow.cfg ${AIRFLOW_HOME}/airflow.cfg

EXPOSE 8080

WORKDIR ${AIRFLOW_HOME}
ENTRYPOINT ["/entrypoint.sh"]
CMD ["webserver"]

