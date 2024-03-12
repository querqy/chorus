FROM querqy/smui:4.0.11

COPY --chown=smui:smui conf/* conf/

USER root
RUN chmod +x conf/smui2*.sh
RUN apt-get update -y && apt-get install -y python3 python3-pip

USER smui
RUN python3 -m pip install requests
