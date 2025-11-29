// Emacs style mode select   -*- C++ -*- 
//-----------------------------------------------------------------------------
//
// $Id:$
//
// Copyright (C) 1993-1996 by id Software, Inc.
//
// This source is available for distribution and/or modification
// only under the terms of the DOOM Source Code License as
// published by id Software. All rights reserved.
//
// The source is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// FITNESS FOR A PARTICULAR PURPOSE. See the DOOM Source Code License
// for more details.
//
// $Log:$
//
// DESCRIPTION:
//	DOOM graphics stuff for X11, UNIX.
//
//-----------------------------------------------------------------------------

static const char
rcsid[] = "$Id: i_x.c,v 1.6 1997/02/03 22:45:10 b1 Exp $";

#include <unistd.h>
#include <sys/ipc.h>
#include <sys/shm.h>


#include <stdarg.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/socket.h>

#include <netinet/in.h>

#include "doomstat.h"
#include "i_system.h"
#include "v_video.h"

#include "doomdef.h"
#include <stdint.h>
#include "dart_interface.h"

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
    static int	lasttic;
    int		tics;
    int		i;
    // UNUSED static unsigned char *bigscreen=0;

    // draws little dots on the bottom of the screen
    if (devparm)
    {

	i = I_GetTime();
	tics = i - lasttic;
	lasttic = i;
	if (tics > 20) tics = 20;

	for (i=0 ; i<tics*2 ; i+=2)
	    screens[0][ (SCREENHEIGHT-1)*SCREENWIDTH + i] = 0xff;
	for ( ; i<20*2 ; i+=2)
	    screens[0][ (SCREENHEIGHT-1)*SCREENWIDTH + i] = 0x0;
    
    }

    notifyDartFrameReady();
}

void I_ReadScreen (byte* scr)
{
    memcpy (scr, screens[0], SCREENWIDTH*SCREENHEIGHT);
}