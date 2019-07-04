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
RUN apt-get update -y && apt-get install -y \
        wget \
        libczmq-dev \
        curl \
        libssl-dev \
        git \
        inetutils-telnet \
        bind9utils \
        zip \
        unzip \
        gcc \
    && apt-get clean

# Pip install section
RUN pip install --upgrade pip \
    && pip install -U setuptools \
        kubernetes \
        cryptography \
        psycopg2-binary==2.7.4
