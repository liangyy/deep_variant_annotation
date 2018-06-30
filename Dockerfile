# For https://github.com/liangyy/deep_variant_annotation

FROM debian:sid-slim
MAINTAINER Yanyu Liang
WORKDIR /tmp
ENV VERSION master

RUN apt-get update \
    && apt-get install -y curl ca-certificates unzip python3-pip bedtools \
    && apt-get clean

RUN pip3 install snakemake pandas keras==2.0.0 h5py theano --no-cache-dir
RUN ln -s `which python3` /usr/local/bin/python

RUN curl -L https://github.com/liangyy/deep_variant_annotation/archive/$VERSION.zip -o $VERSION.zip \
    && unzip $VERSION.zip && cd deep_variant_annotation-$VERSION && mkdir /opt/deepann \
    && mv Snakefile scripts/* /opt/deepann && rm -rf /tmp/*

CMD ["bash"]
