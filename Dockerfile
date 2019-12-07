FROM dlanguage/dmd:2.070.1

RUN apt update -y && apt install git -y

WORKDIR /
ENTRYPOINT tail -f /dev/null
