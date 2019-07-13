FROM amazonlinux:latest

RUN set -x \
  && echo "=== YUM UPDATE AND INSTALL PACKAGES ===" \
  && yum -y update \
  && amazon-linux-extras install -y epel \
  && yum -y install gcc48 \
    gcc48-c++ \
    scons \
    git \
    zlib-devel \
    m4 \
    wget \
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
  && scons -j`grep processor /proc/cpuinfo | wc -l` build/X86/gem5.opt \
  && cd /home/gem5user/gem5-spectre/gem5/configs/learning_gem5/part1
  && sed -e "s:TimingSimpleCPU():DerivO3CPU(branchPred=LTAGE()):" two_level.py > two_level_o3ltage.py \
  && echo "=== GEM5 RUN TEST ===" \
  && cd /home/gem5user/gem5-spectre \
  && mkdir gem5out
  && gem5/build/X86/gem5.opt \
    -d gem5out/runtest gem5/configs/learning_gem5/part1/two_level_o3ltage.py \
    -c gem5/tests/test-progs/hello/bin/x86/linux/hello \
  && echo "=== BUILD SPECTRE ===" \
  && cd /home/gem5user/gem5-spectre/spectre \
  && gcc spectre.c -o spectre -static
