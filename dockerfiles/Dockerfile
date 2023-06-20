# syntax=docker/dockerfile:1
FROM amazonlinux:latest
ENV TZ=America/Buenos_Aires

WORKDIR /home/ec2-user
RUN yum install -y wget unzip htop tar gzip pigz procps
RUN wget https://ftp-trace.ncbi.nlm.nih.gov/sra/sdk/current/sratoolkit.current-centos_linux64.tar.gz \
    && tar -xzvf sratoolkit.current-centos_linux64.tar.gz  \
    && cp -rp /home/ec2-user/sratoolkit.3.0.5-centos_linux64/bin/* /usr/local/bin/ \
    && rm sratoolkit.current-centos_linux64.tar.gz

RUN wget https://repo.anaconda.com/miniconda/Miniconda3-py38_23.3.1-0-Linux-x86_64.sh \
    && bash Miniconda3-py38_23.3.1-0-Linux-x86_64.sh -b \
    && rm Miniconda3-py38_23.3.1-0-Linux-x86_64.sh
ENV PATH=/root/miniconda3/bin:${PATH}
RUN conda update -y conda && conda init && exec bash && . /root/.bashrc
RUN conda install -c conda-forge awscli

CMD /bin/bash