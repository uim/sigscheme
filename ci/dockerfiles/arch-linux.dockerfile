FROM archlinux

RUN \
  pacman --sync --noconfirm --refresh --sysupgrade && \
  pacman --sync --noconfirm \
    asciidoc \
    bzip2 \
    gcc \
    make \
    perl \
    pkg-config \
    ruby \
    sudo \
    tzdata

RUN \
  useradd --user-group --create-home sigscheme

RUN \
  echo "sigscheme ALL=(ALL:ALL) NOPASSWD:ALL" | \
    EDITOR=tee visudo -f /etc/sudoers.d/sigscheme

USER sigscheme

RUN mkdir -p /home/sigscheme/build
WORKDIR /home/sigscheme/build

CMD /source/ci/distcheck.sh
