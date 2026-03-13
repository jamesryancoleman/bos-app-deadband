from zoneinfo import ZoneInfo
import datetime
import time
import sys
import os

import bospy as bos

_tz = ZoneInfo("America/New_York")

if __name__ == "__main__":
    required = {'ZONE_TEMP_PT', 'SETPOINT_PT', 'HEATER_ON_PT', 'FAN_SPD_CMD_PT'}
    missing = required - os.environ.keys()
    if missing:
        sys.exit(f"Missing required config keys: {missing}")

    # now these must all return a value
    zone_temp = os.environ.get('ZONE_TEMP_PT')
    setpoint = os.environ.get('SETPOINT_PT')
    heater_on = os.environ.get('HEATER_ON_PT')
    fan_spd_cmd = os.environ.get('FAN_SPD_CMD_PT')

    # debug
    print({k: os.environ.get(k) for k in required})

    # this collects values from BOS shared memory
    deadbands = bos.load(["global:upper_deadband", "global:lower_deadband"])
    upper_deadband = float(deadbands.get("global:upper_deadband") or 0.25)
    lower_deadband = float(deadbands.get("global:lower_deadband") or 0.25)
    
    # s boolean to track status and ensure the heater is not turned on/off repeatedly
    heater_cycles = 0
    heater_cycles_key = "heater_cycles"
    bos.store(heater_cycles_key, heater_cycles)
    
    heater_is_on = False 
    if heater_is_on:
        bos.set(heater_on, 1)
    else: 
        bos.set(heater_on, 0)
    bos.set(fan_spd_cmd, 0) 
    while True:
        # update deadbands independently — failure keeps last known values
        try:
            deadbands = bos.load(["global:upper_deadband", "global:lower_deadband"])
            upper_deadband = float(deadbands.get("global:upper_deadband") or upper_deadband)
            lower_deadband = float(deadbands.get("global:lower_deadband") or lower_deadband)
            bos.store("deadband_spread", (upper_deadband + lower_deadband))
        except Exception as e:
            print(f"warning: could not retrieve deadbands, using last known values ({upper_deadband}, {lower_deadband}): {e}")

        try:
            # get the current values
            results = bos.get([zone_temp, setpoint])
            current_temp = float(results[zone_temp])
            current_setpoint = float(results[setpoint])

            now = datetime.datetime.now(_tz)
            if (current_temp <= (current_setpoint - lower_deadband)) and not heater_is_on:
                heater_is_on = True
                if heater_is_on:
                    bos.set(heater_on, 1)
                else: 
                    bos.set(heater_on, 0)
                bos.set(fan_spd_cmd, 2.1)
                print(f"heater_is_on={heater_is_on} @ {now}")
            elif (current_temp > (current_setpoint + upper_deadband)) and heater_is_on:
                heater_is_on = False
                if heater_is_on:
                    bos.set(heater_on, 1)
                else: 
                    bos.set(heater_on, 0)
                bos.set(fan_spd_cmd, 0)
                print(f"heater_is_on={heater_is_on} @ {now}")

                heater_cycles += 1
                bos.store(heater_cycles_key, heater_cycles)
        except Exception as e:
            print(f"error in control loop at {datetime.datetime.now()}: {e}")

        time.sleep(10)


