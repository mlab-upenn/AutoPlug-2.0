#ifndef _TYPES_H
#define _TYPES_H

#define CAN_PARAM_MSG_ID (0x70) /* Car params from simulator */
#define CAN_INPUT_MSG_ID (0x60) /* Raw driver input */
#define CAN_BRAKE_MSG_ID (0x61) /* Computed brake output */
#define CAN_ACCEL_MSG_ID (0x62) /* Computed accel, gear and clutch values */
#define CAN_ACCEL_CORR_MSG_ID (0x80) /* Accelerator correction from EBCM to ECM for TC */
#define CAN_MIGRATE_MSG_ID (0x50) //Migrate task from A to B


#define STABILITY (0x08)
#define ABS       (0x04)
#define TRACTION  (0x02)
#define CRUISE    (0x01)

typedef struct _CarParams
{
    INT8 speed;
    UINT16 engineRPM;
    INT8 wheelSpeedFL;
    INT8 wheelSpeedFR;
    INT8 wheelSpeedRL;
    INT8 wheelSpeedRR;
    INT8 yawRate;
} CarParams;
#define SERIAL_CAR_PARAMS_PKT_LENGTH (2 + sizeof(CarParams) + 1)

typedef struct _CarInputs {
    UINT8 accel;
    UINT8 brake;
    INT8 steer;
    INT8 gear;
    UINT8 clutch;
    UINT8 controls; /* use it for ABS/TRAC/CRUISE  */
} CarInputs;
#define SERIAL_CAR_INPUTS_PKT_LENGTH (2 + sizeof(CarInputs) + 1)

typedef struct _AccelMsg
{
    UINT8 accel;
    INT8 gear;
    UINT8 clutch;
} AccelMsg;

typedef struct _BrakeMsg
{
    UINT8 brakeFL;
    UINT8 brakeFR;
    UINT8 brakeRL;
    UINT8 brakeRR;
} BrakeMsg;

typedef struct _TorcsInput
{
    UINT8 accel;
    UINT8 brakeFL;
    UINT8 brakeFR;
    UINT8 brakeRL;
    UINT8 brakeRR;
    INT8 steer;
    INT8 gear;
    UINT8 clutch;
} TorcsInput;

typedef struct _MigrateMsg 
{
    UINT8 flag;
} MigrateMsg;

#endif
