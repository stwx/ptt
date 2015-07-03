//
//  UdpPacket.m
//  PTT-test
//
//  Created by solgo on 15/4/20.
//  Copyright (c) 2015年 solgo. All rights reserved.
//

#import "UdpPacket.h"
#define LEN 16

@implementation UdpPacket


-(id)initWithSrcIp:(char *)srcIp
           srcPort:(int)   srcPort
            destIp:(char *)destIp
          destPort:(int)   destPort
            lenght:(int)   length
            packet:(Byte *)packet
{
    if ( self = [ super init ] )
    {
        self.srcIp = stringToInt( srcIp );
        self.srcPort = srcPort;
        self.destIp = stringToInt(srcIp);
        self.destPort = destPort;
        self.lenght = length;
        self.packet = packet;
    }
    return self;
}

int stringToInt(char* ip_Str)
{
    if ( ip_Str == nil )  return 0;
    
    char *token;
    uint i = 3, total = 0, cur;
    
    token = strtok( ip_Str, "." );
    
    while (token != NULL) {
        cur = atoi(token);
        if ( cur <= 255 )
        {
            total += cur * pow(256, i);
        }
        i --;
        token = strtok(NULL, ".");
    }
    
    return total;
    
}

char* intToString( unsigned int ipInt )
{
    char *new = (char *)malloc(LEN);
    memset(new, '\0', LEN);
    new[0] = '.';
    char token[4];
    int bt, ed, len, cur;
    
    while (ipInt) {
        cur = ipInt % 256;
        sprintf(token, "%d", cur);
        strcat(new, token);
        ipInt /= 256;
        if (ipInt)  strcat(new, ".");
    }
    
    len = (int) strlen(new);
    swapStr(new, 0, len - 1);
    
    for (bt = ed = 0; ed < len;) {
        while (ed < len && new[ed] != '.') {
            ed ++;
        }
        swapStr(new, bt, ed - 1);
        ed += 1;
        bt = ed;
    }
    
    new[len - 1] = '\0';
    
    return new;
}

void swapStr(char *str, int begin, int end)
{
    int i, j;
    
    for (i = begin, j = end; i <= j; i ++, j --) {
        if (str[i] != str[j]) {
            str[i] = str[i] ^ str[j];
            str[j] = str[i] ^ str[j];
            str[i] = str[i] ^ str[j];
        }
    }
}

@end
