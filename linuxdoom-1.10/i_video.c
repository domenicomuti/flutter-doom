#include "i_system.h"
#include "v_video.h"
#include <stdint.h>

extern uint32_t* external_palette;

void I_InitGraphics (void)
{    
}


void I_ShutdownGraphics(void)
{
}

void I_StartFrame (void)
{
}

void I_StartTic (void)
{
}

void I_SetPalette (byte* palette)
{
    for (int i=0 ; i<255 ; i++) {
        external_palette[i] = 0xFF000000;
		external_palette[i] |= (gammatable[usegamma][*palette++] & ~3);
		external_palette[i] |= (gammatable[usegamma][*palette++] & ~3) << 8;
		external_palette[i] |= (gammatable[usegamma][*palette++] & ~3) << 16;
    }
}

void I_UpdateNoBlit (void)
{
}

void I_FinishUpdate (void)
{
}

void I_ReadScreen (byte* scr)
{
}