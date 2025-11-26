cmake_minimum_required(VERSION 3.22.1)

project(doom)

set(SOURCES
	src/main/linuxdoom-1.10/dart/dart_api_dl.c
	src/main/linuxdoom-1.10/dart_interface.c
    src/main/linuxdoom-1.10/doomdef.c
	src/main/linuxdoom-1.10/doomstat.c
	src/main/linuxdoom-1.10/dstrings.c
	src/main/linuxdoom-1.10/i_system.c
	src/main/linuxdoom-1.10/i_sound.c
	src/main/linuxdoom-1.10/i_video.c
	src/main/linuxdoom-1.10/i_net.c	
	src/main/linuxdoom-1.10/tables.c	
	src/main/linuxdoom-1.10/f_finale.c
	src/main/linuxdoom-1.10/f_wipe.c
	src/main/linuxdoom-1.10/d_main.c
	src/main/linuxdoom-1.10/d_net.c
	src/main/linuxdoom-1.10/d_items.c
	src/main/linuxdoom-1.10/g_game.c
	src/main/linuxdoom-1.10/m_menu.c
	src/main/linuxdoom-1.10/m_misc.c
	src/main/linuxdoom-1.10/m_argv.c
	src/main/linuxdoom-1.10/m_bbox.c
	src/main/linuxdoom-1.10/m_fixed.c
	src/main/linuxdoom-1.10/m_swap.c
	src/main/linuxdoom-1.10/m_cheat.c
	src/main/linuxdoom-1.10/m_random.c
	src/main/linuxdoom-1.10/am_map.c
	src/main/linuxdoom-1.10/p_ceilng.c
	src/main/linuxdoom-1.10/p_doors.c
	src/main/linuxdoom-1.10/p_enemy.c
	src/main/linuxdoom-1.10/p_floor.c
	src/main/linuxdoom-1.10/p_inter.c
	src/main/linuxdoom-1.10/p_lights.c
	src/main/linuxdoom-1.10/p_map.c
	src/main/linuxdoom-1.10/p_maputl.c
	src/main/linuxdoom-1.10/p_plats.c
	src/main/linuxdoom-1.10/p_pspr.c
	src/main/linuxdoom-1.10/p_setup.c
	src/main/linuxdoom-1.10/p_sight.c
	src/main/linuxdoom-1.10/p_spec.c
	src/main/linuxdoom-1.10/p_switch.c
	src/main/linuxdoom-1.10/p_mobj.c
	src/main/linuxdoom-1.10/p_telept.c
	src/main/linuxdoom-1.10/p_tick.c
	src/main/linuxdoom-1.10/p_saveg.c
	src/main/linuxdoom-1.10/p_user.c
	src/main/linuxdoom-1.10/r_bsp.c
	src/main/linuxdoom-1.10/r_data.c
	src/main/linuxdoom-1.10/r_draw.c
	src/main/linuxdoom-1.10/r_main.c
	src/main/linuxdoom-1.10/r_plane.c
	src/main/linuxdoom-1.10/r_segs.c
	src/main/linuxdoom-1.10/r_sky.c
	src/main/linuxdoom-1.10/r_things.c
	src/main/linuxdoom-1.10/w_wad.c
	src/main/linuxdoom-1.10/wi_stuff.c
	src/main/linuxdoom-1.10/v_video.c
	src/main/linuxdoom-1.10/st_lib.c
	src/main/linuxdoom-1.10/st_stuff.c
	src/main/linuxdoom-1.10/hu_stuff.c
	src/main/linuxdoom-1.10/hu_lib.c
	src/main/linuxdoom-1.10/s_sound.c
	src/main/linuxdoom-1.10/z_zone.c
	src/main/linuxdoom-1.10/info.c
	src/main/linuxdoom-1.10/sounds.c
)

add_library(doom SHARED ${SOURCES})

target_compile_options(doom PRIVATE
    -g -Wall -DNORMALUNIX -DLINUX

	-Wno-uninitialized
	-Wno-unsequenced
	-Wno-unused-result
	-Wno-pointer-to-int-cast
	-Wno-int-to-pointer-cast
	-Wno-unused-const-variable
	-Wno-unused-variable
	-Wno-unused-but-set-variable
	-Wno-macro-redefined
)

target_link_libraries(doom PRIVATE
	log
	m
)