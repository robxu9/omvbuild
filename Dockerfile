FROM robxu9/openmandriva:2014.0

RUN urpmi --auto --auto-update
RUN urpmi --auto git

ADD scripts /scripts

RUN /scripts/make-directories
RUN /scripts/install-linux-user-chroot

ENV TINI_VERSION v0.6.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static /tini
RUN chmod +x /tini

ADD omvbuild /omvbuild
ADD packages.list /packages.list

RUN mkdir /build

VOLUME ["/workspace"]
ENTRYPOINT ["/tini", "--", "/omvbuild"]
