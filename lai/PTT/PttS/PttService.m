//
//  PttService.m
//  PTT-test
//
//  Created by solgo on 15/4/16.
//  Copyright (c) 2015年 solgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PttService.h"
#import "PttS.h"
#import "UdpPacket.h"
#import "SocketConnect.h"
#import "AudioManager.h"
#import "NSString+Extension.h"
#import "PttTimer.h"
#import "AppDelegate.h"
#import "PttSNotiHandler.h"
#import "UDManager.h"

#define   PTT_TIMER_DATA_LEN       100
#define   MAX_UDP_PACKET_LENGTH    1500
#define   TAG  "PttService"

static    PttService               *_sharedInstance;
static    long                     mSystemStartMss;

BOOL (^StrEqual)(NSString *str1, NSString *str2) = ^(NSString *str1, NSString *str2){
    return [str1 isEqualToString:str2];
};


@implementation PttService

+ (id) sharedInstance {
    @synchronized ([PttService class]) {
        if (_sharedInstance == nil) {
            _sharedInstance = [[PttService alloc] init];
        }
    }
    return _sharedInstance;
}


-(instancetype)init
{
    if ( self = [ super init ] )
    {
        _mPttTimerList = [ [ NSMutableArray alloc ] init ] ;
        
        iOS_PttService_PLIBsetSystemMss([self GetSystemMss]);
        
        iOS_PttService_PLIBinit();
        
        Solgo_AudioManager_Init();
        
        [ self PttNativeRun ];
    }
    
    return self;
}


-(void)PttRecvPacket:( UdpPacket* )packet
{
    iOS_PttService_PLIBrecvPkt
    (
        packet.srcIp,
        packet.destPort,
        packet.srcPort,
        packet.destPort,
        packet.packet,
        packet.lenght
    );
    @synchronized( self )
    {
        if( self != nil )
        {
            [ self PttNativeRun ];
        }
    }
}


-(void)PttTimerExpired:(Byte*)timerData
{
    iOS_PttService_PLIBtimeOut(timerData);
    @synchronized( self )
    {
        [ self PttNativeRun ];
    }
}


-(void) PttNativeRun
{
    MAIN(^{
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [ self PttNativeThreadRun ];
        });

    });
}

-(void) PttNativeThreadRun
{
    iOS_PttService_PLIBsetSystemMss( [self GetSystemMss]);
        
    iOS_PttService_PLIBloop();
       
    Byte timerData[PTT_TIMER_DATA_LEN];
        
    while( true )
    {
         if( 0 == iOS_PttService_PLIBgetTimer( timerData ) )
         {
             break;
         }
         else
         {
             int timerLength = iOS_PttService_PLIBgetTimerLength( timerData )/1000;
             int timerMode = iOS_PttService_PLIBgetTimerMode( timerData );
             int timerMid = iOS_PttService_PLIBgetTimerMid( timerData );
             int timerId = iOS_PttService_PLIBgetTimerID( timerData );
             if ( 0 == timerLength )
             {
                 [ self PttStopTimerWithMid:timerMid timerId:timerId ];
                 [ self PttRemoveNotRunningTimer ];
         
             }
             else
             {
                 [ self PttStartTimerWithData:timerData
                                  timerLenght:timerLength
                                    timerMode:timerMode
                                     timerMid:timerMid
                                      timerId:timerId ];
             }
         }
    }
    
    Byte packet[ MAX_UDP_PACKET_LENGTH ];
    Byte data[ MAX_UDP_PACKET_LENGTH ];
    int packetLength ,dataLength;
        
    while ( true )
    {
        packetLength = iOS_PttService_PLIBgetSendPkt( packet );
        if (  0 < packetLength )
        {
            unsigned int destIpAddress = iOS_PttService_PLIBgetSendPktDstIp( packet );
            int destPort = iOS_PttService_PLIBgetSendPktDstPort( packet );
            dataLength = iOS_PttService_PLIBgetSendPktData( packet , data);
                                  
            Byte sendData[dataLength];
            memcpy(sendData,data, dataLength);
            char *SercerIp_Chr = intToString(destIpAddress);
            Solgo_UDP_Send(sendData, SercerIp_Chr, destPort,dataLength);
        }
        else
        {
            break;
        }
    }
        
    Byte broadcastData[ 1024 ];
    int broadcastLength;
    while ( true )
    {
        broadcastLength = iOS_PttService_PLIBgetBroadcast( broadcastData );
        if ( 0 < broadcastLength )
        {
            broadcastData [ broadcastLength ] = 0;
            NSString *broadcast_Str = [ [ NSString alloc ]initWithBytes:broadcastData length:broadcastLength encoding:NSUTF8StringEncoding ];
            DLog(@" ---- BROADCAST ---- [ %@ ]",broadcast_Str);
            [self handlePttData:broadcast_Str];
        }
        else
        {
            break;
        }
    }
    
    Byte printData[1024];
    int printLength;
    while ( true )
    {
        printLength = iOS_PttService_PLIBgetPrint( printData );
        if( 0 < printLength )
        {
//            NSData *data = [[NSData alloc] initWithBytes:printData length:printLength];
//            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            //DLog(@"%@",str);
            printData[ printLength ] = 0;
        }
        else
        {
            break;
        }
    }
}

-(int)PTT_Login:(char*)userId password:(char*)password
{
    int ret;
    
    char *phoneMode =[ self Str2Char:([[UIDevice currentDevice]model]) ];
    char *phoneSystemVersion = [ self Str2Char:([[UIDevice currentDevice]systemVersion]) ];
    char *phoneIMEI = [ self Str2Char:@"88888888" ];
    char *phoneNumber = [ self Str2Char:@"12345678" ];
    char  *phoneNunberAttribution = [ self Str2Char:@"ABCD" ];
    
    ret = iOS_PttService_PLIBlogin( userId, password, phoneMode, phoneSystemVersion, phoneIMEI, phoneNumber, phoneNunberAttribution );
    @synchronized( self )
    {
        [ self PttNativeRun ];
    }
    return ret;
    
}

-(int)PTT_Logout
{
    int ret;
    ret = iOS_PttService_PLIBlogout();
    @synchronized( self )
    {
        [ self PttNativeRun ];
    }
    return ret;
}


-(int)PTT_StartTalk
{
    int ret;
    [ self StopAudioProcess ];
    ret = iOS_PttService_PLIBstartTalk();
    @synchronized( self )
    {
        [ self PttNativeRun ];
    }
    return ret;
}

-(int)PTT_OpenMic
{
    [ self StopAudioProcess ];
    Solgo_AudioManager_StartRecord();
    @synchronized( self )
    {
        [ self PttNativeRun ];
    }
    return 1;
}

-(int)PTT_StopTalk
{
    int ret;
    [ self StopAudioProcess ];
    ret = iOS_PttService_PLIBstopTalk();

    @synchronized( self )
    {
        [ self PttNativeRun ];
    }
    return ret;
}

-(int)PTT_OpenSpeak
{
    NSLog(@"PTT_OpenSpeak-----");
    int ret;
    [ self StopAudioProcess ];
    Solgo_AudioManager_StartPlayProcess( VOICE );
    ret = iOS_PttService_PLIBstartListenConfirm();
    @synchronized( self )
    {
        [ self PttNativeRun ];
    }
    return ret;
}

-(int)PTT_CloseSpeak
{
    int ret;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8f * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [ self StopAudioProcess ];
        iOS_PttService_PLIBstopListenConfirm();
        @synchronized( self )
        {
            [ self PttNativeRun ];
        }
        
        Solgo_AudioManager_StartPlayProcess(NOISE);
    });
    
    return ret;
}

-(int)PTT_GetUserState
{
    return iOS_PttService_PLIBgetUserState();
}

-(int)PTT_GetUserTalkState
{
    return iOS_PttService_PLIBgetUserTalkState();
}

-(int)PTT_GetUserTalkSecond
{
    iOS_PttService_PLIBsetSystemMss( [ self GetSystemMss ] );
    return iOS_PttService_PLIBgetUserTalkSeconds();
}

-(long) GetSystemMss
{
    long  currentSystemMss;
    currentSystemMss = [[NSDate date] timeIntervalSince1970] * 1000;
    return currentSystemMss - mSystemStartMss;
}

-(char*)Str2Char:(NSString*)str
{
    const char *chr = [ str UTF8String ];
    return (char*)chr;
}


-(void)StopAudioProcess
{
    Solgo_AudioManager_StopBGM();
    iOS_AudioProcess_PLIBstopAudioRecv();
    Solgo_AudioManager_StopProcess();
    iOS_AudioProcess_PLIBdeleteAudioSendChannel();
    iOS_AudioProcess_PLIBdeleteAudioRecvChannel();
}

-(void)PttStartTimerWithData:(Byte*)timerData
                 timerLenght:( int )timerLenght
                   timerMode:( int )timerMode
                    timerMid:( int )timerMid
                     timerId:( int )timerId
{
    PttTimer *mPttTimer = [ PttTimer alloc ];
    mPttTimer = [ mPttTimer initWithTimerData:timerData
                                       length:timerLenght
                                    timerMode:timerMode
                                     timerMid:timerMid
                                      timerId:timerId ];
    @synchronized(_mPttTimerList)
    {
        [ _mPttTimerList addObject:mPttTimer ];
    }
}

-(void)PttStopTimerWithMid:(int)timerMid timerId:(int)timerId
{

    PttTimer *mPttTimer;
    for ( int i = 0;i < _mPttTimerList.count;i++ )
    {
        mPttTimer = [ _mPttTimerList objectAtIndex:i ];
        if ( YES != mPttTimer.isRunning)
        {
            continue;
        }
        if ( timerMid == mPttTimer.timerMid
            && timerId == mPttTimer.timerId)
        {
            [mPttTimer Stop];
            break;
        }
    }
}

-(void)PttRemoveNotRunningTimer
{
    PttTimer  *pttTimer;
    BOOL      isBreak;
    while ( true )
    {
        isBreak = NO;
        for ( int i = 0; i<_mPttTimerList.count; i++ )
        {
            pttTimer = [_mPttTimerList objectAtIndex:i];
            
            if ( YES != pttTimer.isRunning )
            {
                @synchronized( _mPttTimerList )
                {
                    [_mPttTimerList removeObjectAtIndex:i];
                }
                
                isBreak = YES;
                break;
            }
        }
        
        if( YES != isBreak )
        {
            break;
        }
    }
}

- (void)handlePttData:(NSString *)dataString{
    NSArray *params = [dataString componentsSeparatedByString:@"`"];
   
    if ([params[0] isEqualToString:@"ACK"]) {
        [self handlePttAck:params];
    }
    else if ([params[0] isEqualToString:@"NOTIFY"]){
        [self handlePttNotify:params];
    }
   }

- (void)handlePttAck:(NSArray *)params{
    if ([params[1] isEqualToString:@"Login"]) {
        NSDictionary *notiDic;
        if ([params[2] isEqualToString:@"Ok"]) {
            notiDic = @{ @"result":@1, @"message":@"登录成功" };
        }
        else if ( [params[2] isEqualToString:@"Fail"] ){
            notiDic = @{ @"result":@0, @"message":[NSString stringWithFormat:@"错误代码:%@",params[3]] };
        }
        else if ( [params[2] isEqualToString:@"Timeout"] ){
            notiDic = @{ @"result":@0, @"message":@"连接ptts服务器超时" };
        }
        if ([_delegate respondsToSelector:@selector(PttS_recvLoginResult:)]) {
            [_delegate PttS_recvLoginResult:notiDic];
        }
    }
    if ([params[1] isEqualToString:@"StartTalk"]) {
        BOOL result = NO;
        if ([params[2] isEqualToString:@"Ok"]) {
            [ self PTT_OpenMic ];
            result = YES;
        }
        if ([_delegate respondsToSelector:@selector(PttS_recvStartTalkAckResult:)]) {
            [_delegate PttS_recvStartTalkAckResult:result];
        }
    }

}

- (void)handlePttNotify:(NSArray *)params{
    NSString *noti = params[1];
    if ([noti isEqualToString: @"StartListen"]){
        [UDManager saveListenState:YES];
        [self PTT_OpenSpeak];
        if ([_delegate respondsToSelector:@selector(PttS_recvStartListernNoti:)]) {
            [_delegate PttS_recvStartListernNoti:params[2]];
        }
    }
    else if ([noti isEqualToString:@"StopListen"]){
        [self PTT_CloseSpeak];
        [UDManager saveListenState:NO];
        if ([_delegate respondsToSelector:@selector(PttS_recvStopListernNoti)]) {
            [_delegate PttS_recvStopListernNoti];
        }
    }
    else if ([noti isEqualToString:@"RecvAppMessage"]){
        NSDictionary *dic = [params[2] jsonToDictionary];
        if (dic == nil) {
            ASSERT;
            return;
        }
        [PttSNotiHandler handleNotiWithDic:dic];
    }
}

@end

