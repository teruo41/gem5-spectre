FROM amazonlinux:latest

RUN set -x \
  && echo "=== YUM UPDATE AND INSTALL PACKAGES ===" \
  && yum -y update \
  && amazon-linux-extras install -y epel \
  && yum search protoc \
  && yum -y install \
    compat-gcc-48 \
    compat-gcc-48-c++ \
    python-devel \
    zlib-devel \
    python-six \
    scons \
    git \
    m4 \
    wget \
  && ldconfig \
  && echo "=== ADD AN USER ===" \
  && useradd gem5user \
  && cp -r /etc/skel /home/gem5user \
  && chown -R gem5user:gem5user /home/gem5user

USER gem5user
RUN set -x \
  && cd /home/gem5user \
  && echo "=== GIT CLONE GEM5-SPECTRE PROJECT ===" \
  && git clone https://github.com/teruo41/gem5-spectre.git --depth 1 \
  && cd /home/gem5user/gem5-spectre \
  && git submodule update --init --recursive --depth 1 \
  && echo "=== BUILD GEM5 ===" \
  && cd /home/gem5user/gem5-spectre/gem5 \
  && CC=gcc48 CXX=g++48 scons --verbose build/X86/gem5.opt \
  && cd /home/gem5user/gem5-spectre/gem5/configs/learning_gem5/part1 \
  && echo "=== CREATE SIMPLE O3 CONFIGURATION ===" \
  && sed -e "s:TimingSimpleCPU():DerivO3CPU(branchPred=LTAGE()):" two_level.py > two_level_o3ltage.py \
  && echo "=== GEM5 RUN TEST ===" \
  && cd /home/gem5user/gem5-spectre \
  && mkdir gem5out \
  && gem5/build/X86/gem5.opt -d gem5out/runtest gem5/configs/learning_gem5/part1/two_level_o3ltage.py \
  && echo "=== BUILD SPECTRE ===" \
  && cd /home/gem5user/gem5-spectre/spectre \
  && gcc48 spectre.c -o spectre -static
