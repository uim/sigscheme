FROM debian:13

RUN \
  echo "debconf debconf/frontend select Noninteractive" | \
    debconf-set-selections

RUN \
  echo 'APT::Install-Recommends "false";' > \
    /etc/apt/apt.conf.d/disable-install-recommends

RUN \
  apt update -qq && \
  apt install -y \
    asciidoc \
    autoconf \
    autoconf-archive \
    automake \
    bzip2 \
    gcc \
    libc6-dev \
    libtool \
    make \
    pkg-config \
    ruby \
    sudo \
    tzdata && \
  apt clean && \
  rm -rf /var/lib/apt/lists/*

RUN \
  useradd --user-group --create-home sigscheme

RUN \
  echo "sigscheme ALL=(ALL:ALL) NOPASSWD:ALL" | \
    EDITOR=tee visudo -f /etc/sudoers.d/sigscheme

USER sigscheme

RUN mkdir -p /home/sigscheme/build
WORKDIR /home/sigscheme/build

CMD /source/ci/release.sh
