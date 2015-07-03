//
//  UdpPacket.h
//  PTT-test
//
//  Created by solgo on 15/4/20.
//  Copyright (c) 2015年 solgo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UdpPacket : NSObject

@property(assign,nonatomic) int srcIp;
@property(assign,nonatomic) int srcPort;
@property(assign,nonatomic) int destIp;
@property(assign,nonatomic) int destPort;
@property(assign,nonatomic) int lenght;
@property(assign,nonatomic) Byte *packet;

-(id)initWithSrcIp:(char *)srcIp
           srcPort:(int)   srcPort
            destIp:(char *)destIp
          destPort:(int)   destPort
            lenght:(int)   length
            packet:(Byte *)packet;

char* intToString( unsigned int ipInt );
int   stringToInt(char* ip_Str);




@end
