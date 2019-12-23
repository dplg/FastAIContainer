FROM bitnami:minideb
LABEL Maintainer="R. Neff & B. Dash <devgru.club@gmail.com>" \
      Description="Modified version of Rob B.'s FastAI POC Container"
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
ENV PATH /opt/conda/bin:$PATH

RUN apt-get update --fix-missing && apt-get install -y wget bzip2 ca-certificates \
    libglib2.0-0 libxext6 libsm6 libxrender1 \
    git mercurial subversion bc time tmux sshuttle
## Adding a Tunnel seems to be the way to go regarding API defense, SSH FTW
RUN wget --quiet https://repo.continuum.io/archive/Anaconda2-5.1.0-Linux-x86_64.sh -O ~/anaconda.sh && \
    bash ~/anaconda.sh -b -p /opt/conda && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

RUN apt-get install -y curl grep sed dpkg && \
    TINI_VERSION=`curl https://github.com/krallin/tini/releases/latest | grep -o "/v.*\"" | sed 's:^..\(.*\).$:\1:'` && \
    curl -L "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}.deb" > tini.deb && \
    dpkg -i tini.deb && \
    rm tini.deb && \
    apt-get clean

RUN mkdir /fastai/ && cd / && \
    git clone https://github.com/fastai/fastai.git && cd fastai && conda env update && /bin/bash activate fastai
    conda activate fastai

RUN pip install --upgrade git+https://github.com/pytorch/text

RUN mkdir -p /root/jupyter/
WORKDIR /root/jupyter/
COPY src/ /root/jupyter/

EXPOSE 84 446

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
