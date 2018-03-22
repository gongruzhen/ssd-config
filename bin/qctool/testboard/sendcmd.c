#include <stdio.h>
#include <string.h>
#include <malloc.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <termios.h>
#include <getopt.h>

#define MAX_BUFFER_SIZE 512
#define CMD_LEN 5

int usage()
{
	printf("Usage: ./sendcmd [OPTION]* DEVICE CMD1 CMD2 CMD3\n"
	"\n"
	"\tCMD1(Action Type): 01(Slot), 02(FLT), 03(Acitve) \n"
	"\tCMD2(ON/OFF):00(On), FF(OFF)\n"
	"\tCMD3(IO select,bit effective):bit7: io7, bit6: io6 ... bit0: io0, 00 - noselect, FF - allselect\n"
	"\n"
	"\tExample:Slot0 Slot2 On\n"
	"\t./sendcmd /dev/ttyACM0 01 00 05 \n");

}
int open_serial(const char *device)
{
	int fd;
	struct termios opt;
	fd = open(device, O_RDWR | O_NOCTTY );
	if(fd == -1)
	{
	  perror("open serial port error!\n");
	  return -1;
	}

	tcgetattr(fd, &opt);
	cfmakeraw(&opt);
	cfsetispeed(&opt, B115200);
	cfsetospeed(&opt, B115200);
	opt.c_cflag |= (CLOCAL | CREAD);    //enable date receiver
	opt.c_cflag &= ~PARENB;      //没有校验
	opt.c_cflag &= ~CRTSCTS;     //没有数据流
	opt.c_cflag &= ~CSTOPB;   //关闭两位停止位，就是一位停止位
	opt.c_cflag &= ~CSIZE;	  //设置数据位宽时打开掩码
	opt.c_cflag |= CS8;	  //8位数据位
	opt.c_cc[VTIME]=10;	  // 1秒超时返回

	opt.c_cc[VMIN]=0;
	tcsetattr(fd, TCSANOW, &opt);

	return fd;
}

int cmd(int fd,char *data, int length,unsigned char *ack)
{
	int retv,i,count;
	char rbuf[MAX_BUFFER_SIZE];
	unsigned char success;

	// receive first to clear buffer
	//retv = read(fd, rbuf,MAX_BUFFER_SIZE);
	i = 0;
	do{
		retv = write(fd, data, length);
		if(retv == -1)
		{
			perror("Write data error!\n");
			return -1;
		}

		count = read(fd, rbuf,MAX_BUFFER_SIZE);
		if (count < 0)
		{
			perror("Read data error!\n");
			return -1;
		}
		else if(1 == count){
			*ack = *rbuf;
			break;
		}
		//printf( "%d", count);
		i++;
	} while(i < 3);
	if(3 == i)
	{
		printf("cmd Something error!\n");
		return -2;
	}
	return 0;

}

int main(int argc, char *argv[]){
	int fd,retv,opt,i;
	unsigned char ack;
	unsigned char sbuf[CMD_LEN];
	char devname[128];

	if (argc < 5)
	{
		usage();
		return -1;
	}
	sprintf(devname, "%s", argv[1]);
	//printf("%s\n",devname);

	fd = open_serial(devname);
	if (fd < 0)
		return -1;
	sbuf[0] = 0x5A;      //Header
	for(i = 0; i < CMD_LEN-2; i++)
	{
		sbuf[1 + i] = strtoul(argv[2 + i], NULL, 16);
	}
	sbuf[4] = sbuf[0]^sbuf[1]^sbuf[2]^sbuf[3];

	if (retv = cmd(fd, sbuf,CMD_LEN,&ack) < 0)
	{
		printf("cmd error\n");
	}

	if(close(fd) < 0)
	{
		perror("Close the device failure!\n");
		return -1;
	}
	if (retv)
		return retv;
	if(ack == 0xAA)
		printf("cmd success!\n");
	else
	{
		printf("fail! retv = %02x\n",ack);
		retv = 1;
	}
	return retv;

}
