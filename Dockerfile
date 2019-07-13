FROM amazonlinux:latest

RUN set -x \
  && yum -y update \
  && amazon-linux-extras install -y epel \
  && yum -y install gcc48 \
    gcc48-c++ \
    python2 \
    scons \
    git \
    zlib-devel \
    m4 \
    wget \
  && useradd gem5user \
  && cp -r /etc/skel /home/gem5user \
  && chown -R gem5user:gem5user /home/gem5user

USER gem5user
RUN set -x \
  && cd /home/gem5user \
  && git clone https://github.com/teruo41/gem5.spectre.git \
  && git clone https://gem5.googlesource.com/public/gem5 \
  && cd /home/gem5user/gem5 \
  && scons build/X86/gem5.opt \
  && mkdir /home/gem5user/spectre \
  && cd /home/gem5user/spectre \
  && wget https://gist.githubusercontent.com/ErikAugust/724d4a969fb2c6ae1bbd7b2a9e3d4bb6/raw/41bf9bd0e7577fe3d7b822bbae1fec2e818dcdd6/spectre.c \
  && gcc spectre.c -o spectre -static
