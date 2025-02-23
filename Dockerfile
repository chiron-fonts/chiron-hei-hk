FROM ubuntu:latest

ENV TZ="Asia/Hong_Kong"

RUN apt-get update && apt-get install -y python3 python3-pip

COPY ./scripts/requirements.txt /tmp/requirements.txt
RUN pip install --break-system-packages -r /tmp/requirements.txt
WORKDIR /source

ENTRYPOINT [ "/source/bin/build.sh" ]
