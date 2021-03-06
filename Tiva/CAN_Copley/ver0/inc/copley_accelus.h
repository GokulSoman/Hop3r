#ifndef __COPLEY_ACCELUS__H__
#define __COPLEY_ACCELUS__H__
// Header file for copley_accelus.c
// interfaces with Copley Accelus motor driver

// See CopleyNotes.txt (parent directory) for details

// Author: Dan Lynch
// Begun 4/12/18

uint8_t init_copley(void);

uint8_t set_copley_mode(uint8_t copley_mode);
uint8_t get_copley_mode(void);

uint8_t set_current_mA(int16_t cur_ref_mA);
uint16_t get_current_mA(void);

#endif
