FROM querqy/smui:3.14.0

COPY --chown=1024:1024 conf/* conf/

USER root
RUN chmod +x conf/smui2*.sh
RUN apt-get update -y && apt-get install -y python3 python3-pip

USER smui
RUN python3 -m pip install requests
