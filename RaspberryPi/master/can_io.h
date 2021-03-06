#ifndef __CAN_IO__H__
#define __CAN_IO__H__
// Header file for can_io.c
// implements a CAN bus interface built on SocketCAN.

#include <errno.h>          /* Error number definitions */
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>

#include <net/if.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/ioctl.h>

#include <pthread.h>

#include <linux/can.h>
#include <linux/can/raw.h>

#include "linux-can-utils/lib.h"
#include "per_threads.h"

#define MOTOR_1_EN 0b00000010
#define MOTOR_2_EN 0b00001000
#define MOTOR_3_EN 0b00100000

#define MODE_TRQ_CTRL 0
#define MODE_POS_CTRL 1

// CAN IDs:
// TODO: make sure ID makes sense with message frequency
#define MOTOR_CMD_ID 0x00000001 // TODO: finalize ID: 0
#define MOTOR_1_POS_CAN_ID 0x00002001 // TODO: finalize ID: 2
#define MOTOR_2_POS_CAN_ID 0x00003001 // TODO: finalize ID: 3
#define MOTOR_3_POS_CAN_ID 0x00004001 // TODO: finalize ID: 4
#define MOTOR_1_CUR_CAN_ID 5 // TODO: finalize ID: 5
#define MOTOR_2_CUR_CAN_ID 6 // TODO: finalize ID: 6
#define MOTOR_3_CUR_CAN_ID 7 // TODO: finalize ID: 7
#define IMU_FZ_CAN_ID 8 // TODO: finalize ID: 8
#define BOOM_ROLL_CAN_ID 9 // TODO: finalize ID: 9
#define BOOM_PITCH_CAN_ID 10 // TODO: finalize ID: 10
#define BOOM_YAW_CAN_ID 11 // TODO: finalize ID: 11

int s; // can raw socket
int nbytesR,nbytesW;
struct sockaddr_can addr;
struct can_frame writeFrame;
struct can_frame readFrame;
struct ifreq ifr;
struct timeval tv; // used for read timeout

typedef struct {
  int16_t qa_act[3];  // (actual) actuated joint angles
  int16_t ia[3];      // (actual) actuated joint currents
  int16_t boom[3];    // boom angles
  int16_t accel;      // acceleration from IMU
  int16_t fz;         // force from force sensor
} can_input_struct;

// set up CAN raw socket:
int initSocketCAN(void);

// get data from CAN, parse it, and put it into a struct of type can_input_struct:
int readCAN(can_input_struct *ptr);

int writePosToCAN(double *pos_deg_arr); // write 3 reference joint positions to CAN

int writeTrqToCAN(double *trq_Nm_arr); // write 3 reference joint torques to CAN

int killMotors(void);

#endif
