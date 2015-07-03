//
//  SocketConnect.m
//  QQQQ
//
//  Created by RenHongwei on 15/1/27.
//  Copyright (c) 2015年 RenHongwei. All rights reserved.
//


#import "SocketConnect.h"
#import "UdpPacket.h"
#include "PttS.h"
#import <stdio.h>
#import <stdlib.h>
#import <string.h>
#import <netinet/in.h>
#import <netdb.h>
#import <sys/ioctl.h>
#import <net/if.h>
#import <errno.h>
#import <arpa/inet.h>
#import <sys/types.h>
#import <sys/socket.h>
#import <sys/signal.h>


#define LOCAL_UDP_PORT          40000
#define UDP_RECV_MAX_LEN        1536
#ifdef _FOR_DEBUG_
#endif

int sockfd;
int mLOCAL_UDP_PORT = LOCAL_UDP_PORT;
struct sockaddr_in local_address, remote_address;

@implementation SocketConnect

void Solgo_UDP_Send ( Byte *msg ,char *REMOTE_INET_ADDRESS,int REMOTE_UDP_PORT, int len )
{
   // DLog(@"\n==============\n    ip:%s\n    port:%d\n==============\n",REMOTE_INET_ADDRESS, REMOTE_UDP_PORT);
    bzero(&remote_address, sizeof(remote_address));
    remote_address.sin_family = AF_INET;
    remote_address.sin_addr.s_addr = inet_addr(REMOTE_INET_ADDRESS);
    remote_address.sin_port = htons(REMOTE_UDP_PORT);
    
    if (sendto(sockfd, msg, len, 0,(struct sockaddr *)&remote_address, sizeof(remote_address)) == -1)
    {
        SOLGO_ASSERT;
        printf("发送失败\n");
    }
}

UdpPacket* Solgo_UDP_Recv ( void )
{
    Byte msg[UDP_RECV_MAX_LEN];
    int len;
    unsigned int addr_len = sizeof(struct sockaddr_in);
    len = (int) recvfrom(sockfd,msg, sizeof(msg), 0, (struct sockaddr *)&local_address, &addr_len);
    
    if ( len <= 0 )
    {
        return nil;
    }
    
    int ServerPort;
    char ServerIP[128];
    strcpy(ServerIP, inet_ntoa(local_address.sin_addr));
     ServerPort=htons(local_address.sin_port);
    char *localIp = (char *)[ @"127.0.0.1" UTF8String ];
    
    UdpPacket *packet = [[UdpPacket alloc]initWithSrcIp:ServerIP srcPort:ServerPort destIp:localIp destPort:mLOCAL_UDP_PORT lenght:len packet:msg];
    return packet;
}

BOOL Solgo_UDP_Init ( )
{
    sockfd = socket(AF_INET, SOCK_DGRAM, 0);
    if (-1 == sockfd)
    {
        SOLGO_ASSERT;
        return NO;
    }
    
    struct timeval timeout = {0.2,0};
    if ( 0 != setsockopt(sockfd, SOL_SOCKET, SO_SNDTIMEO, &timeout, sizeof(timeout)) )
    {
        SOLGO_ASSERT;
        return NO;
    }

    bzero(&local_address, sizeof(local_address));
    local_address.sin_family = AF_INET;
    local_address.sin_addr.s_addr = htonl(INADDR_ANY);
    local_address.sin_port = htons(mLOCAL_UDP_PORT);
    
    if (-1 == bind(sockfd, (struct sockaddr *)&local_address, sizeof(local_address)))
    {
        SOLGO_ASSERT;
        printf("socket绑定失败\n");
        return NO;
    }
    return YES;
}

BOOL Solgo_UDP_Close()
{
    if (close(sockfd) != 0)
    {
        SOLGO_ASSERT;
        printf("socket关闭失败\n");
        return NO;
    }
    return YES;
}

@end
