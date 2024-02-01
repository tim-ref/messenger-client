FROM bats/bats

RUN \
  apk \
  --no-cache \
  --update \
  add \
  curl jq git

RUN git clone https://github.com/bats-core/bats-support.git /bats/test_helper/bats-support
RUN git clone https://github.com/bats-core/bats-assert.git /bats/test_helper/bats-assert
RUN git clone https://github.com/bats-core/bats-file.git /bats/test_helper/bats-file

COPY common-setup.bash /bats/test_helper