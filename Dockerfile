FROM rust:slim

RUN apt update && apt install -y --no-install-recommends curl build-essential ca-certificates libxml2 git fish unzip wget

RUN git config --global user.name "allegrogiken"
RUN git config --global user.email "vvani06+dev@gmail.com"

ENV D_COMPLILER="ldc-1.32.2"

RUN curl https://dlang.org/install.sh > /tmp/install.sh
RUN chmod +x /tmp/install.sh
RUN /tmp/install.sh install ${D_COMPLILER} 

RUN ln -s $(/tmp/install.sh get-path ${D_COMPLILER}) /usr/local/bin/ldc2
RUN ln -s $(/tmp/install.sh get-path --dmd ${D_COMPLILER}) /usr/local/bin/ldmd2
RUN ln -s $(/tmp/install.sh get-path --dub ${D_COMPLILER}) /usr/local/bin/dub

COPY home/tools /tmp/tools
RUN cd /tmp/tools/auto_builder && \
    dub build && \
    cp auto_builder /usr/bin/build_auto

ENV PATH $PATH:/workspace/.code-d/bin

WORKDIR /workspace/
CMD fish
