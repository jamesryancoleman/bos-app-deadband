FROM jamescoleman/bospy

LABEL bos.type="application"
LABEL bos.name="deadband"
LABEL bos.author="James"
LABEL bos.description="drives a on-off heater within a deadband"
LABEL bos.usage="required parameters are the points: ZONE_TEMP_PT, SETPOINT_PT, HEATER_ON_PT, FAN_SPD_CMD_PT. Deadband is manipulated via the 'global:upper_deadband' and 'global:lower_deadband'."
LABEL bos.env="ZONE_TEMP_PT,SETPOINT_PT,HEATER_ON_PT,FAN_SPD_CMD_PT"

# sample env vars
# FAN_SPD_CMD_PT=bos://localhost/dev/15/pts/4,HEATER_ON_PT=bos://localhost/dev/6/pts/2,SETPOINT_PT=bos://localhost/dev/15/pts/3,ZONE_TEMP_PT=bos://localhost/dev/15/pts/1

COPY src/ /opt/bos/app/deadband/src/
WORKDIR /opt/bos/app/deadband/

ENV TZ="America/New_York"

CMD ["python", "deadband.py"]

