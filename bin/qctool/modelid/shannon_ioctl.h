/* Definitions for Shannon hardware/software interface.
 * Copyright (c) 2012, Shannon technology
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 */

#ifndef __SHANNON_IOCTL_H
#define __SHANNON_IOCTL_H

#include "shannon_mbr.h"

#define ECC_CORRECTION_BITS_IN_SECTOR	    58

struct shannon_ecc_stat {
	__u64 ecc_statistics[ECC_CORRECTION_BITS_IN_SECTOR + 1];
};

struct shannon_disk_status {
	__u32 state;
	__u32 access_mode;
	__u64 readonly_reason;
	__u64 reduced_write_reason;
};

struct shannon_version_info {
	__u32 firmware_version;
	__u32 driver_version;
	__u64 serial_number;
	__u32 driver_fix_version;
	__u32 firmware_tag;
};

/* Since we wont expose ioctl interface to end user, get all smart attributes all together. */

/* We chose this size for historic reasons. */
#define SHANNON_SMART_SIZE		    528

struct shannon_smart {
	__u64 power_on_seconds;
	__u64 power_cycle_count;
	__u64 capacity;
	__u64 physical_capacity;

	__u32 overprovision;
	__u32 free_blkcnt;

	__u32 max_erase_count;
	__u32 min_erase_count;

	__u32 average_erase_count;
	__u32 total_erase_count;

	__u32 variance_of_erase_count;
	__u32 estimated_life_left;

	__u32 static_bad_blkcnt;
	__u32 dynamic_bad_blkcnt;

	__u64 host_write_sectors;
	__u64 host_write_ios;		    /* retired */
	__u64 host_write_msecs;		    /* retired */
	__u64 total_write_sectors;
	__u64 host_read_sectors;
	__u64 host_read_ios;		    /* retired */
	__u64 host_read_msecs;		    /* retired */

	__u32 ecc_failure_times;
	__u32 temperature_int;

	__u32 temperature_flash;
	__u32 temperature_board;

	__u32 voltage_int;
	__u32 voltage_int_max;

	__u32 voltage_aux;
	__u32 voltage_aux_max;

	__u64 sequence_number;

	__u32 temperature_int_max;    /* Place these variables here for compatibility, since sequence_number is utilized previously. */
	__u32 temperature_flash_max;

	__u32 temperature_board_max;
	__u32 seu_crc_error;

	__u32 seu_crc_error_history;
	__u32 seu_ecc_error;

	__u32 seu_ecc_error_history;
	__u32 ecc_correction_limit;

	__u32 ecc_codeword_size;
	__u32 pad1;

	__u64 buffer_write_counter;
	__u64 direct_write_counter;

	__u32 has_service_tag;		/* abandoned */
	__u8 service_tag[32];
	__u8 model_id[40];
	__u16 lnksta;
	__u16 pad2;

	__u32 lnkcap;
	__u32 pad3;

	__u64 flashid;

	__u16 hal_version;
	__u8 udid[36];
	__u8 pad4[2];

	__u32 hw_cfg_channels;
	__u32 hw_cfg_lunset_in_channel;

	__u32 hw_cfg_lun_in_lunset;
	__u16 device_id;
	__u16 subsystem_device_id;

	__u16 subsystem_vendor_id;
	__u8 pci_bus_number;
	__u8 pci_slot_number;
	__u8 pci_func_number;
	__u8 pad5[3];

	__u32 host_write_bandwidth;	/* KB/s */
	__u32 host_write_iops;

	__u32 host_write_latency;	/* us */
	__u32 total_write_bandwidth;	/* KB/s */

	__u32 host_read_bandwidth;	/* KB/s */
	__u32 host_read_iops;

	__u32 host_read_latency;	/* us */
	__u32 buffer_write_percent;

	__u32 write_amplifier;
	__u32 write_amplifier_lifetime;

	__u32 fpga_reconfig_sup;
	__u32 fpga_reconfig_times;

	__u16 scsi_mode;
	__u16 scsi_host_no;

	__u8 force_rw;
	__u8 reserved[89];
};

struct shannon_progress_bar {
	__u32 valid;
	__u32 percent;
};

#define SHN_PROGRESS_INVALID	0
#define SHN_PROGRESS_VALID	1
#define SHN_PROGRESS_DONE	2
#define SHN_PROGRESS_NORFLASH_ERASE		    3
#define SHN_PROGRESS_NORFLASH_WRITE		    4
#define SHN_PROGRESS_NORFLASH_READ		    5
#define SHN_PROGRESS_REFRESH_MBR		    6

struct shannon_norflash_ops {
	void *data;
	__u32 offset;
	__u32 length;
	__u32 cmd;
};

#define SHN_NORFLASH_CMD_ERASE	1
#define SHN_NORFLASH_CMD_WRITE	2
#define SHN_NORFLASH_CMD_READ	3


#define SHN_SET_FEATURE         1
#define SHN_UNSET_FEATURE       2

struct shannon_format_arg {
	__u64 capacity;
	__u32 user_logicb_shift;
	__u32 clear_history;
	__u32 force_format;
	__u32 atomic_write;
	__u32 prioritize_write;
};

struct shannon_reg {
	__u32 reg;
	__u32 *buf;
	__u32 len;
};

/*
 * Magic numbers about disk state and access mode
 * We place them here because userspace tools also need them
 */
#define SHN_STATE_ATTACHED          0
#define SHN_STATE_DETACHED          1
#define SHN_STATE_RECONFIG          8
#define SHN_STATE_RESET             16
#define SHN_STATE_ERROR_BIT         0x8000
#define SHN_STATE_MASK              0x7FFF

#define SHN_MODE_READWRITE	    0
#define SHN_MODE_REDUCED_WRITE	    1
#define SHN_MODE_READONLY	    2

#define SHN_REASON_USER_REQUESTED	0
#define SHN_REASON_LOW_OVERPROVISION	1
#define SHN_REASON_HIGH_TEMPERATURE     2
#define SHN_REASON_EPILOG_FAILURE       3
#define SHN_REASON_MANY_BAD_BLOCKS	4
#define SHN_REASON_SEU_ERROR		5
#define SHN_REASON_SENTINEL		6


#define SHANNON_IOCMAGIC	'x'

#define	SHANNON_IOCRMBR		_IOR(SHANNON_IOCMAGIC,	1,  struct shannon_mbr)

/* Attach disk and set access mode, return effective access mode after this command is executed. */
#define SHANNON_IOCSATTACH	_IOW(SHANNON_IOCMAGIC,	4,  int)

/*
 * Try to detach disk from system, return values:
 * 0	success, destroy gendisk and set disk state to detached
 * >0	failure, set disk state to detaching, return current user count
 */
#define SHANNON_IOCCDETACH	_IO(SHANNON_IOCMAGIC,	5)

/* Get current disk status, including disk state, access mode and reasons */
#define SHANNON_IOCRSTATUS	_IOR(SHANNON_IOCMAGIC,	6,  struct shannon_disk_status)

#define SHANNON_IOCCEJECT	_IO(SHANNON_IOCMAGIC,	8)

/* Reformat Shannon Drive(i.e. erase all super blocks ,write mbr & bbt back and apply new setting)
 * params: shannon_format_arg
 * capacity:
 *	    demanded capacity, zero means keep current capacity
 * user_logicb_shift:
 *	    demanded logical sector size
 * clear_history:
 *	    clear historic maximum temperature and voltage numbers, if not zero.
 * force_format:
 * 0	    normal reformat, must detach before this command, if not ,return -EBUSY.
 * 1	    force reformat, reformat even device is in use, this will cause great instablity to system.
 *	    CAUTION: not recommended!!!!!! must understand what you are doing.
 *
 * return values:
 * 0	    success
 * -EBUSY   device in use
 */
#define SHANNON_IOCSFORMAT	_IOW(SHANNON_IOCMAGIC,	8,  struct shannon_format_arg)

/* Read s.m.a.r.t attributes and other informations */
#define	SHANNON_IOCRSMART	_IOWR(SHANNON_IOCMAGIC,	9,  struct shannon_smart)

/*
 * Switch on/off LED to identify the disk itself, param:
 * 0	    turn off
 * 1	    turn on
 */
#define SHANNON_IOCWLED		_IOW(SHANNON_IOCMAGIC,	10, int)

/* Read ecc correction statistics, which can reflect nand flash health. */
#define SHANNON_IOCRECC		_IOR(SHANNON_IOCMAGIC,	11, struct shannon_ecc_stat)

/* Read version information, including fpga version, driver version and serial number. */
#define SHANNON_IOCRVERINFO	_IOR(SHANNON_IOCMAGIC,	12, struct shannon_version_info)

/* Read reformat progress information */
#define SHANNON_IOCRPROGRESS	_IOR(SHANNON_IOCMAGIC,	13, struct shannon_progress_bar)

/*
 * Manipualte NOR flash:
 * split into 3 independent ioctls to avoid mishandling, cmd field is for double check.
 */
#define SHANNON_IOCWNORERASE	_IOW(SHANNON_IOCMAGIC,	14, struct shannon_norflash_ops)
#define SHANNON_IOCWNORWRITE	_IOW(SHANNON_IOCMAGIC,	15, struct shannon_norflash_ops)
#define SHANNON_IOCRNORREAD	_IOWR(SHANNON_IOCMAGIC,	16, struct shannon_norflash_ops)

/*
 * Reload firmware from NOR flash when reboot.
 */
#define SHANNON_IOCCRELOAD	_IO(SHANNON_IOCMAGIC,	18)

/*
 * Read BAR registers
 */
#define SHANNON_IOCRDREG	_IOR(SHANNON_IOCMAGIC,	19, struct shannon_reg)
#define SHANNON_IOCWRREG	_IOR(SHANNON_IOCMAGIC,	20, struct shannon_reg)

#define SHANNON_IOCQATOMIC_SIZE _IO(SHANNON_IOCMAGIC,	22)

#define SHANNON_IOCCRECONFIG	_IO(SHANNON_IOCMAGIC,	23)
#define SHANNON_IOCCRESET	_IO(SHANNON_IOCMAGIC,	24)

#define SHANNON_IOCNORINFO	_IO(SHANNON_IOCMAGIC,	25)

#define SHANNON_IOCMAXNR				26


#endif /* __SHANNON_IOCTL_H */
