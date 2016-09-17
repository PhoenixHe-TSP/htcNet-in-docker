FROM ubuntu:16.04

ADD ./.oh-my-zsh /root/.oh-my-zsh
ADD ./.zshrc /root/.zshrc

RUN sed -i "s/archive.ubuntu.com/mirrors.ustc.edu.cn/g" /etc/apt/sources.list
RUN apt-get -y update \
 && apt-get -y --no-install-recommends install \
        strongswan zsh curl wget \
 && apt-get -y clean \ 
 && rm -rf /var/lib/apt/lists/*

ADD ./run.sh /run.sh
RUN chmod 755 /run.sh

CMD ["/run.sh"]
