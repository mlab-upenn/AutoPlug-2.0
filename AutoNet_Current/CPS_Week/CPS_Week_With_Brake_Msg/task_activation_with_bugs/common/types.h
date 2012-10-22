#ifndef _TYPES_H
#define _TYPES_H

#define CAN_PARAM_MSG_ID (0x70) /* Car params from simulator */
#define CAN_INPUT_MSG_ID (0x60) /* Raw driver input */
#define CAN_BRAKE_MSG_ID (0x61) /* Computed brake output */
#define CAN_ACCEL_MSG_ID (0x62) /* Computed accel, gear and clutch values */
#define CAN_ACCEL_CORR_MSG_ID (0x80) /* Accelerator correction from EBCM to ECM for TC */
#define CAN_VERIFY_MSG_ID (0x81) /* Verify Informatiion */
#define CAN_TASK_FEEDBACK_ID (0x82) /* confirmation information of task activation */
#define CAN_CRUISE_SPEED_ID (0x83) /* Desired speed from cruise module */
#define AUTOLINK_MSG_ID (0x11) /*Autolink Message CAN ID*/

#define TASK_MANIP      (0x01) /*Type of action- Task Manipulation*/
#define TASK_ACTIVATE   (0x01) /*Activate Task*/
#define TASK_SUSPEND    (0x02) /*Suspend Task*/
#define TASK_TERMINATE  (0x03) /*Terminate Task*/
#define TASK_REACTIVE   (0x05) /*Active Suspended Task*/
#define TASK_BUGS       (0x02) /*Introduce control bugs*/

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
    //INT8 lateralspeed;
    //INT8 lateralacc; 
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

typedef struct _ECU_packet
    {
        UINT8 ecu_id;
        UINT8 tasks;
        UINT8 action[4];
    } ECU_packet;
    
typedef struct _AutoLinkCANMsg
    {
        UINT8 action_type;
        ECU_packet ecu_packet;
     } AutoLinkCANMsg;

typedef struct _VerifyMsg
{
    INT8 exceed;
    INT8 delay;    //nothing is assigned
} VerifyMsg;

typedef struct _Task_feedback 
{
    UINT8 tasknum;
    UINT8 action;
} Task_feedback;
  
/*
typedef struct _Cruise_speed 
{
    INT8 current;
    INT8 desired;
} Cruise_speed;

typedef struct _Matlab_GUI 
{
    
    Task_feedback task_feedback;
    VerifyMsg verify_message;
} Matlab_GUI;
*/  
  

#endif
