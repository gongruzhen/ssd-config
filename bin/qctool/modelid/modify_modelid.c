#include <stdio.h>
#include <fcntl.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <getopt.h>

#include <sys/ioctl.h>
#include <sys/stat.h>
#include <linux/types.h>

#include "shannon_mbr.h"
#include "shannon_ioctl.h"

#define MAGIC_NUMBER	0X646972656374696F

#define NOR_BLOCKSIZE1	0x1000UL
#define NOR_BLOCKSIZE2	0x20000UL
#define MODELID_OFF	0x28UL
#define MODELID_LEN	32

//80bytes
struct norflash_info {
	__u64 magic_number;
	char service_tag[32];
	char model_id[40];
};

//#define DEBUG
#ifdef DEBUG
void dump(unsigned char *buf, int len)
{
	int i, j, n;
	int line = 16;
	char c;
  
	n = len / line;
	if (len % line)
		n++;
    
	for (i = 0; i < n; i++) {
		printf("0x%lx: ", (unsigned long)(buf + i * line));

		for (j = 0; j < line; j++) {
			if ((i * line + j) < len)
				printf("%02x ", buf[i * line + j]);
			else
				printf("   ");
		}

		printf("  ");
		for (j = 0; j < line && (i * line + j) < len; j++) {
			if ((i * line + j) < len) {
				c = buf[i * line + j];
				printf("%c", c > ' ' && c < '~' ? c : '.');
			} else
				printf("   ");
		}
      
		printf("\n");
	}
}
#endif

void usage(void)
{
	printf("Usage: ./modify_modelid [-d device] [-y]\n");
	printf("Option:\n"
	       "--device | -d\t device name (if not specified exclusive, default is /dev/scta)\n"
	       "--force  | -y\t force to modify mode id\n"
//	       "--typeb  | -b\t additional board type\n"
	       "--help   | -h\t help information\n");
}

int main(int argc, char **argv)
{
	int fd;
	int ret, nlength;
	int force = 0;
	char *fbuffer;
	char modelid[MODELID_LEN + 1], origid[MODELID_LEN + 1];
	char opt, prompt;
	unsigned int user_capacity;
	struct stat stat_buf;
	char device[128];
	char type = 0;
	struct shannon_norflash_ops nor_ops;
	struct shannon_smart smart;
	struct norflash_info *nf_info;
	struct shannon_reg reg;
	__u32 NOR_INFOFFSET, reg_data;

	struct option longopts[] = {
		{"force", no_argument, NULL, 'y'},
		{"device", required_argument, NULL, 'd'},
		{"help", no_argument, NULL, 'h'},
		{"modelid", required_argument, NULL, 'm'},
		{"typeb", no_argument, NULL, 'b'},
		{NULL, no_argument, NULL, 0},
	};

	memset(device, 0, sizeof(device));
	memset(modelid, 0, sizeof(modelid));

	while ((opt = getopt_long(argc, argv, "bhyd:m:", longopts, NULL)) != EOF) {
		switch(opt) {
		case 'y':
			force = 1;
			break;
		case 'd':
			strncpy(device, optarg, 128);
			break;
		case 'm':
			if (strlen(optarg) > MODELID_LEN) {
				printf("BAD ModelID! The specifed modelid length is exceeding %d. Exit\n", MODELID_LEN);
				return -1;
			}

			memcpy(modelid, optarg, strlen(optarg));
			break;
		case 'b':
			type = 'b';
			break;
		case 'h':
			usage();
			return 0;
		default:
			usage();
			return -1;
		}
	};

	if (strlen(device) == 0)
		sprintf(device, "%s", "/dev/scta");

	if (lstat(device, &stat_buf) < 0) {
		perror("lstat");
		printf("device node %s dose not exist\n", device);
		return -1;
	}

	if (!S_ISCHR(stat_buf.st_mode)) {
		printf("%s is not a character device file\n", device);
		return -1;
	}

	fd = open(device, O_RDWR);
	if (fd < 0) {
		perror("Failed to open");
		return -1;
	}

	ret = ioctl(fd, SHANNON_IOCRSMART, &smart);
	if (ret < 0) {
		perror("read mbr");
		close(fd);
		return -1;
	}

	user_capacity = smart.capacity * 512 / (1000 * 1000 * 1000);
/*
	if (user_capacity < 800) {
		user_capacity = 800;
		printf("WARNING: user capacity less than 800G, still mark as 800G\n");
	} else if (user_capacity < 1600) {
		user_capacity = 800;
	} else if (user_capacity < 3200) {
		user_capacity = 1600;
	} else if (user_capacity < 6400) {
		user_capacity = 3200;
	} else {
		user_capacity = 6400;
	}
*/
	/* G4/G5 compatible */
	reg.reg = 0;
	reg.buf = &reg_data;
	reg.len = 1;
	ret = ioctl(fd, SHANNON_IOCRDREG, &reg);
	if (ret < 0) {
		perror("Failed to ioctl regread 0x00");
		return -1;
	}
	if ((reg_data & 0xFF) < 0x10) {
		NOR_INFOFFSET = 0x1FFF000;	// G4
	} else {
		reg.reg = 0x21;
		ret = ioctl(fd, SHANNON_IOCRDREG, &reg);
		if (ret < 0) {
			perror("Failed to ioctl regread 0x21");
			return -1;
		}
		if (reg_data)
			NOR_INFOFFSET = 0x1FFF000;
		else
			NOR_INFOFFSET = 0xFF000;
	}

	nlength = sizeof(struct norflash_info);
	fbuffer = malloc(nlength);
	if (!fbuffer) {
		perror("Failed to malloc");
		close(fd);
		return -1;
	}

	memset(fbuffer, 0, nlength);
	nor_ops.data = fbuffer;
	nor_ops.offset = NOR_INFOFFSET;
	nor_ops.length = nlength;
	nor_ops.cmd = SHN_NORFLASH_CMD_READ;

	ret = ioctl(fd, SHANNON_IOCRNORREAD, &nor_ops);
	if (ret < 0) {
		perror("Failed to ioctl norread");
		free(fbuffer); close(fd);
		return -1;
	}
#ifdef DEBUG
	printf("Dump nor flash data starting from %x size %d:\n",
		NOR_INFOFFSET, nlength);
	dump(fbuffer, nlength);
#endif

	nf_info = (struct norflash_info *)fbuffer;
	if (nf_info->magic_number != MAGIC_NUMBER) {
		printf("Read norflash ERROR, magic number does not match\n");
		free(fbuffer); close(fd);
		return -1;
	}

	memset(origid, 0, sizeof(origid));
	memcpy(origid, fbuffer + MODELID_OFF, MODELID_LEN);
	if (strlen(origid) > MODELID_LEN) {
		printf("Error happend, force quit\n");
		free(fbuffer); close(fd);
		return -1;
	}

	printf("%s original modelid is: %s.\n", device, origid);

	if (modelid[0] == '\0') {
		if (type == 'b')
			sprintf(modelid, "%s %dG", "Direct-IO G3i-B-Ali", user_capacity);
		else
			sprintf(modelid, "%s %dG", "Direct-IO G3i-Ali", user_capacity);
	}

	if (strncmp(origid, modelid, MODELID_LEN) == 0) {
		printf("%s original modelid is already right. Exit\n", device);
		free(fbuffer); close(fd);
		return 0;
	}

	printf("%s new modelid will be: %s.\n", device, modelid);
	if (!force) {
		printf("You're about to change %s modelid. Confirm to change: Y|y: ", device);
		prompt = getchar();
		if (prompt != 'Y' && prompt != 'y') {
			printf("\nCanceled.\n");
			free(fbuffer); close(fd);
			return -1;
		}
	}

	nor_ops.data = NULL;
	nor_ops.cmd = SHN_NORFLASH_CMD_ERASE;
//	nor_ops.offset = NOR_INFOFFSET & ~(NOR_BLOCKSIZE1 - 1);
	nor_ops.offset = NOR_INFOFFSET;
	nor_ops.length = nlength; //same affect == NOR_BLOCKSIZE1

//	printf("offset = %08x\n", nor_ops.offset);

	ret = ioctl(fd, SHANNON_IOCWNORERASE, &nor_ops);
	if (ret < 0) {
		printf("Failed to ioctl SHANNON_IOCWNORERASE\n");
		free(fbuffer); close(fd);
		return -1;
	}

	memcpy(fbuffer + MODELID_OFF, modelid, MODELID_LEN);
	nor_ops.data = fbuffer;
	nor_ops.cmd = SHN_NORFLASH_CMD_WRITE;
	nor_ops.offset = NOR_INFOFFSET;
	nor_ops.length = nlength;

#ifdef DEBUG
	printf("About to write flash data starting from %x size %d:\n",
		NOR_INFOFFSET, nlength);
	dump(fbuffer, nlength);
#endif

	ret = ioctl(fd, SHANNON_IOCWNORWRITE, &nor_ops);
	if (ret < 0) {
		perror("Failed to ioctl norwrite");
		free(fbuffer); close(fd);
		return -1;
	}

	/* This ioctl command is added since 2.8.8.
	 */
	ret = ioctl(fd, SHANNON_IOCNORINFO);
	if (ret < 0) {
		perror("Failed to ioctl norflash info");
	}

#ifdef DEBUG
	printf("Try to readback to confirm\n");
	memset(fbuffer, 0, nlength);
	nor_ops.data = fbuffer;
	nor_ops.offset = NOR_INFOFFSET;
	nor_ops.length = nlength;
	nor_ops.cmd = SHN_NORFLASH_CMD_READ;

	ret = ioctl(fd, SHANNON_IOCRNORREAD, &nor_ops);
	if (ret < 0) {
		perror("Failed to ioctl norread");
		free(fbuffer); close(fd);
		return -1;
	}
	printf("Dump nor flash starting from %x size %d:\n",
		NOR_INFOFFSET, nlength);
	dump(fbuffer, nlength);
#endif
	printf("Done\n");

	free(fbuffer); close(fd);
	return 0;
}

