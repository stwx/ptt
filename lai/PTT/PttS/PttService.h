//
//  PttService.h
//  PTT-test
//
//  Created by solgo on 15/4/16.
//  Copyright (c) 2015年 solgo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UdpPacket.h"

@protocol PttServiceDelegate <NSObject>
@optional
- (void)PttS_recvLoginResult:(NSDictionary *)dic;
- (void)PttS_recvStartTalkAckResult:(BOOL)result;
- (void)PttS_recvStartListernNoti:(NSString *)talkerName;
- (void)PttS_recvStopListernNoti;
@end

typedef enum
{
    USER_TALK_STATE_IDLE        =   0,
    USER_TALK_STATE_SENDER      =   1,
    USER_TALK_STATE_RECEIVER    =   2
}USER_TALK_STATE;

@interface PttService : NSObject


@property(strong ,nonatomic)   NSMutableArray *mPttTimerList;
@property(strong, nonatomic)   NSThread *mPttNativeThread;
@property (assign, nonatomic) id<PttServiceDelegate>delegate;

+ (id) sharedInstance; 
-(void)PttRecvPacket:( UdpPacket* )packet;

-(void)PttStartTimerWithData:(Byte*)timerData
                 timerLenght:( int )timerLenght
                   timerMode:( int )timerMode
                    timerMid:( int )timerMid
                     timerId:( int )timerId;

-(void)PttStopTimerWithMid:(int)timerMid timerId:(int)timerId;

-(void)PttTimerExpired:(Byte*)timerData;
-(void) PttNativeRun;

-(int)PTT_Login:(char*)userId password:(char*)password;
-(int)PTT_Logout;
-(int)PTT_StartTalk;
-(int)PTT_OpenMic;
-(int)PTT_StopTalk;
-(int)PTT_OpenSpeak;
-(int)PTT_CloseSpeak;
-(int)PTT_GetUserState;
-(int)PTT_GetUserTalkState;
-(int)PTT_GetUserTalkSecond;
-(long)GetSystemMss;

@end

