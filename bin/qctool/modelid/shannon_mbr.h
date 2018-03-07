/* Definitions for Shannon hardware/software interface.
 * Copyright (c) 2012, Shannon technology
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 */

#ifndef __SHANNON_MBR_H
#define __SHANNON_MBR_H

#include <linux/types.h>

#define MBR_EBLOCKS	4           /* reserved MBR erase blocks. */
#define MBR_WATERMARK	0xa5a5a5a5
#define MBR_LOGICB_SHIFT	9

#define SHANNON_MBR_SIZE       512

#define CURRENT_MBR_FORMAT_VERSION	0x5400
#define MBR_ID_SIZE		32
struct shannon_mbr {
	char id[MBR_ID_SIZE];
	__u64 mbr_format_version;
	__u64 hardware_version;
	__u64 software_version;
	__u64 nand_manufacture;
	__u64 nand_id;
	__u64 capacity;

	__u32 lun_amount;
	__u32 eblocks_in_lun;
	__u32 pages_in_eblock;
	__u32 nand_page_shift;
	__u32 oob_size;
	__u32 logicb_shift;
	__u32 plane_order;
	__u32 cfg_channels;
	__u32 cfg_lunset_in_channel;
	__u32 cfg_lun_in_lunset;

	__u32 init_hot_sblk;
	__u32 init_cold_sblk;

	__u16 interrupt_delay;   /* default to 1 */
	__u8 ecc_codewords_in_logicb;
	__u8 ecc_correction_power;
	__u32 history_erase_count;

	__u64 power_cycle_count;
	__u64 power_on_seconds;    /* updated in each reformat progress */
	__u64 host_write_sectors;
	__u64 total_write_sectors;
	__u64 host_read_sectors;

	__u32 flash_drvmode;  /* output_drive_strength + 1; so 0 is invalid. */
	__u8 luns_per_ce_mask;
	__u8 lun_map_mode;
	__u16 raid_stripes;

#define BAD_LUN_MAP_ARRAY_SIZE	8
	__u64 bad_phy_lun_map[BAD_LUN_MAP_ARRAY_SIZE];
	__u32 max_pages_in_eblock;
	__u32 user_logicb_shift;
#define PRIORITIZE_WRITE	0x0001
#define ATOMIC_WRITE		0x0002
	__u64 feature_flags;
	__u8 power_budget;
	/* 0 is reserved in mbr, so value stored here is the real value + 1 */
	__u8 dma_max_read_limit; /* real dma_max_read_limit + 1 */
	__u16 clk; /* real clk + 1 */
	__u32 max_outstanding_bios;
	/* increase mbr_update when update bad_phy_lun_map and refresh mbr */
	__u32 mbr_update;
	/* for aux1, aux2 and board */
	__u8 temp_threshold1;
	__u8 temp_critical_threshold1;
	/* for inner */
	__u8 temp_threshold2;
	__u8 temp_critical_threshold2;
	__u8 reserved[232];
};

#endif /* __SHANNON_MBR_H */
