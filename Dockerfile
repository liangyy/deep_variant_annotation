# For https://github.com/liangyy/deep_variant_annotation

FROM debian:testing
MAINTAINER Yanyu Liang
WORKDIR /tmp
ENV VERSION master

RUN apt-get update \
    && apt-get install -y curl ca-certificates unzip python3-pip bedtools \
    && apt-get clean

RUN sed -i.bak 's/main/main contrib non-free/g' /etc/apt/sources.list
RUN apt-get update \
    && apt-get install -y nvidia-cuda-toolkit \
    && apt-get clean

RUN pip3 install numpy==1.13.1 --no-cache-dir
RUN pip3 install keras==2.0.0 theano==0.9.0 --no-cache-dir
RUN pip3 install pandas==0.22.0 h5py snakemake --no-cache-dir
RUN ln -s `which python3` /usr/local/bin/python

# http://security-plus-data-science.blogspot.com/2017/08/theano-deep-learning-framework-on.html
RUN sed -i.bak -e '84d' /usr/local/lib/python3.6/dist-packages/numpy/core/include/numpy/ndarraytypes.h

RUN curl -L https://github.com/liangyy/deep_variant_annotation/archive/$VERSION.zip -o $VERSION.zip \
    && unzip $VERSION.zip && cd deep_variant_annotation-$VERSION && mkdir /opt/deepann \
    && mv Snakefile scripts/* /opt/deepann && rm -rf /tmp/*

ENV KERAS_BACKEND=theano
#ENV THEANO_FLAGS=floatX=float32,device=gpu,nvcc.flags=-D_FORCE_INLINES

CMD ["bash"]
