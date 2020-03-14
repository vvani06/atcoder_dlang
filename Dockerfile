FROM dlanguage/dmd:2.070.1

RUN apt update -y && apt install git -y
RUN git config --global user.name "allegrogiken"
RUN git config --global user.email "vvani06+dev@gmail.com"

ENV PATH $PATH:/root/.code-d/bin
ENV PATH $PATH:/dlang/dub

WORKDIR /
ENTRYPOINT tail -f /dev/null
