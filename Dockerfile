FROM amazonlinux:latest

RUN set -x \
  && echo "=== SET ROOT PASSWORD ===" \
  && echo "root:admin" | chpasswd

RUN set -x \
  && echo "=== ADD AN USER ===" \
  && useradd gem5user \
  && echo "gem5user:gem5-spectre" | chpasswd \
  && cp -r /etc/skel /home/gem5user \
  && chown -R gem5user:gem5user /home/gem5user

RUN set -x \
  && echo "=== YUM UPDATE AND INSTALL PACKAGES ===" \
  && yum -y update \
  && amazon-linux-extras install -y epel \
  && yum -y install \
    compat-gcc-48 \
    compat-gcc-48-c++ \
    python-devel \
    python-six \
    zlib-devel \
    scons \
    git \
    m4 \
    protobuf-compiler \
    wget

USER gem5user

RUN set -x \
  && echo "=== GIT CLONE GEM5-SPECTRE PROJECT ===" \
  && cd /home/gem5user \
  && git clone https://github.com/teruo41/gem5-spectre.git --depth 1 \
  && cd gem5-spectre \
  && git submodule update --init --recursive --depth 1

RUN set -x \
  && echo "=== BUILD GEM5 ===" \
  && cd /home/gem5user/gem5-spectre/gem5 \
  && which gcc48 \
  && which g++48 \
  && CC=gcc48 CXX=g++48 scons --verbose build/X86/gem5.opt \
  && cd /home/gem5user/gem5-spectre/gem5/configs/learning_gem5/part1

RUN set -x \
  && echo "=== CREATE SIMPLE O3 CONFIGURATION ===" \
  && cd /home/gem5user/gem5-spectre/gem5 \
  && sed -e "s:TimingSimpleCPU():DerivO3CPU(branchPred=LTAGE()):" two_level.py > two_level_o3ltage.py

RUN set -x \
  && echo "=== GEM5 RUN TEST ===" \
  && cd /home/gem5user/gem5-spectre \
  && mkdir gem5out \
  && gem5/build/X86/gem5.opt -d gem5out/runtest gem5/configs/learning_gem5/part1/two_level_o3ltage.py

RUN set -x \
  && echo "=== BUILD SPECTRE ===" \
  && cd /home/gem5user/gem5-spectre/spectre \
  && gcc48 spectre.c -o spectre -static
