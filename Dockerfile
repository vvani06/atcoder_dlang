FROM alpine:latest

RUN apk update && \
    apk add alpine-sdk cmake clang llvm ldc vim git bash fish

RUN git config --global user.name "allegrogiken"
RUN git config --global user.email "vvani06+dev@gmail.com"

RUN git clone https://github.com/dlang/dub.git /tmp/dub && \
    cd /tmp/dub && \
    ldmd2 build.d && \
    ./build && \
    cp bin/dub /usr/bin

COPY home/tools /tmp/tools
RUN cd /tmp/tools/auto_builder && \
    dub build && \
    cp auto_builder /usr/bin/build_auto

ENV PATH $PATH:/root/.code-d/bin

WORKDIR /root/
CMD fish
