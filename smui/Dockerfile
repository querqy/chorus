FROM querqy/smui:4.0.11

COPY --chown=smui:smui conf/* conf/

# This is a workaround for now.  Remove when SMUI 5.x is released.
COPY --chown=smui:smui 3.sql conf/evolutions/default/3.sql
COPY --chown=smui:smui 8.sql conf/evolutions/default/8.sql

USER root
RUN chmod +x conf/smui2*.sh
RUN apt-get update -y && apt-get install -y python3 python3-pip

USER smui
RUN python3 -m pip install requests
