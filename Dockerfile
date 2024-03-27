# syntax=docker/dockerfile:1
FROM --platform=linux/amd64 phusion/baseimage:jammy-1.0.2

### set environment variable
ENV NUMBA_CACHE_DIR="/tmp/numba_cache"

### Run commands to install miniconda

## Install dependencies
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y wget
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt-get install -y ./google-chrome-stable_current_amd64.deb

## install miniconda3
RUN curl https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh > /install_conda.sh && \
    chmod +x /install_conda.sh && \ 
    mkdir -p /home && \
    mkdir -p /home/jari && \
    /install_conda.sh -b -p home/jari/miniconda3 && \
    rm /install_conda.sh
## Copy the environments to the container
COPY envs /home/jari/miniconda3/envs

## Makes sure the container keeps running after starting the container
ENTRYPOINT ["bash", "-c", "tail -f /dev/null"]
