FROM jamescoleman/bospy

LABEL bos.type="application"
LABEL bos.name="deadband"
LABEL bos.author="James"
LABEL bos.description="drives a on-off heater within a deadband"
LABEL bos.usage="required parameters are the points: ZONE_TEMP_PT, SETPOINT_PT, HEATER_ON_PT, FAN_SPD_CMD_PT. Deadband is manipulated via the 'global:upper_deadband' and 'global:lower_deadband'."
LABEL bos.env.spec='[ { "label": "Zone Temperature Sensor", "key": "ZONE_TEMP_PT", "input_type": "control_point", "is_required": true, "usage": "the current temperature of the space", "placeholder": "bos://localhost/dev/1/pts/1", "preferred_class": "brick:Zone_Air_Temperature_Sensor", "accept_class": "brick:Air_Temperature_Sensor" }, { "label": "Heating Setpoint", "key": "SETPOINT_PT", "input_type": "control_point", "is_required": true, "usage": "the target temperature of the space", "placeholder": "bos://localhost/dev/1/pts/2", "preferred_class": "brick:Heating_Zone_Air_Temperature_Setpoint", "accept_class": "brick:Temperature_Setpoint" }, { "label": "Heater On Command", "key": "HEATER_ON_PT", "input_type": "control_point", "is_required": true, "usage": "the on/off heater to control", "placeholder": "bos://localhost/dev/1/pts/3", "preferred_class": "brick:On_Command", "accept_class": "brick:On_Off_Command" }, { "label": "Fan Speed Command", "key": "FAN_SPD_CMD_PT", "input_type": "control_point", "is_required": true, "usage": "A fan to turn on with the heating", "placeholder": "bos://localhost/dev/1/pts/4", "preferred_class": "brick:Fan_Speed_Command", "accept_class": "brick:Fan_Command" } ]'
# LABEL bos.env="ZONE_TEMP_PT,SETPOINT_PT,HEATER_ON_PT,FAN_SPD_CMD_PT"

# sample env vars
# FAN_SPD_CMD_PT=bos://localhost/dev/15/pts/4,HEATER_ON_PT=bos://localhost/dev/6/pts/2,SETPOINT_PT=bos://localhost/dev/15/pts/3,ZONE_TEMP_PT=bos://localhost/dev/15/pts/1

COPY src/ /opt/bos/app/deadband/src/
WORKDIR /opt/bos/app/deadband/src/

ENV TZ="America/New_York"

CMD ["python", "deadband.py"]

