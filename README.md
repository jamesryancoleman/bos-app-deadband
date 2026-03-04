# Deadband

A heating control app that runs a deadband thermostat loop. It runs continuously until killed.

## Input Variables

### Required environment variables (BOS point addresses)

| Variable | Description |
|---|---|
| `ZONE_TEMP_PT` | BOS point address for the zone temperature sensor (read) |
| `SETPOINT_PT` | BOS point address for the temperature setpoint (read) |
| `HEATER_ON_PT` | BOS point address for the heater on/off command (write) |
| `FAN_SPD_CMD_PT` | BOS point address for the fan speed command (write) |

### Shared memory (BOS store, optional)

| Key | Default | Description |
|---|---|---|
| `global:upper_deadband` | `0.25` | Degrees above setpoint at which the heater turns off |
| `global:lower_deadband` | `0.25` | Degrees below setpoint at which the heater turns on |

## Control Logic

Every 10 seconds the app:

1. Reloads `upper_deadband` and `lower_deadband` from shared memory (falls back to last known values on failure).
2. Reads the current zone temperature and setpoint from BOS.
3. Applies hysteresis control:
   - **Turn heater ON** — if `zone_temp ≤ setpoint − lower_deadband` and the heater is currently off.
   - **Turn heater OFF** — if `zone_temp > setpoint + upper_deadband` and the heater is currently on.
4. No state change occurs when the temperature is within the deadband, preventing rapid cycling.

On startup the heater and fan are initialized to off/0 before the loop begins.

## Outputs

| Destination | Value | Condition |
|---|---|---|
| `HEATER_ON_PT` | `True` / `False` | Written on every state change |
| `FAN_SPD_CMD_PT` | `2.1` / `0` | Written on every state change (2.1 when heating, 0 when off) |
| `deadband_spread` (store) | `upper + lower` | Updated each loop iteration |
| `heater_cycles` (store) | integer count | Incremented each time the heater turns off |
