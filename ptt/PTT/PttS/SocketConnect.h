//
//  SocketConnect.h
//  QQQQ
//
//  Created by RenHongwei on 15/1/27.
//  Copyright (c) 2015年 RenHongwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UdpPacket.h"

@interface SocketConnect : NSObject
extern void Solgo_UDP_Send ( Byte *msg ,char *REMOTE_INET_ADDRESS,int REMOTE_UDP_PORT, int len );
extern UdpPacket* Solgo_UDP_Recv ();
extern BOOL Solgo_UDP_Init ();
extern BOOL Solgo_UDP_Close();
@end
