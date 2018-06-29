# For https://github.com/liangyy/deep_variant_annotation

FROM debian:sid-slim
MAINTAINER Yanyu Liang
WORKDIR /tmp
ENV VERSION master

RUN apt-get update \
    && apt-get install -y python3-pip curl ca-certificates unzip \
    && apt-get clean

RUN pip3 install snakemake pandas keras==2.0.0 h5py --no-cache-dir

RUN curl -L https://github.com/liangyy/deep_variant_annotation/archive/$VERSION.zip -o $VERSION.zip \
    && unzip $VERSION.zip && cd deep_variant_annotation-$VERSION && mkdir /opt/deepann \
    && mv Snakefile scripts/* /opt/deepann && rm -rf /tmp/*

CMD ["bash"]
