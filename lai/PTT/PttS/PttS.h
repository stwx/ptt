//
//  PttS.h
//  PttS
//
//  Created by xihan on 15/5/29.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

extern int iOS_PttService_PLIBinit( );
extern int iOS_PttService_PLIBsetSystemMss( long sys_mss );
extern int iOS_PttService_PLIBloop( );
extern int iOS_PttService_PLIBexit( );
extern int iOS_PttService_PLIBrecvPkt( int srcIp, int dstIp, short srcPort, short dstPort,unsigned char * data, int length );
extern int iOS_PttService_PLIBtimeOut( unsigned char * data );
extern int iOS_PttService_PLIBnetworkChange(  );
extern int iOS_PttService_PLIBgetTimer( unsigned char * data );
extern int iOS_PttService_PLIBgetTimerLength( unsigned char * data );
extern int iOS_PttService_PLIBgetTimerMode( unsigned char * data );
extern int iOS_PttService_PLIBgetTimerMid( unsigned char * data );
extern int iOS_PttService_PLIBgetTimerID( unsigned char * data );
extern int iOS_PttService_PLIBgetSendPkt( unsigned char * data );
extern unsigned int iOS_PttService_PLIBgetSendPktSrcIp( unsigned char * data );
extern int iOS_PttService_PLIBgetSendPktSrcPort( unsigned char * data );
extern unsigned int iOS_PttService_PLIBgetSendPktDstIp( unsigned char * data );
extern int iOS_PttService_PLIBgetSendPktDstPort( unsigned char * data );
extern int iOS_PttService_PLIBgetSendPktData(  unsigned char * data, unsigned char * core );
extern int iOS_PttService_PLIBgetBroadcast( unsigned char * data );
extern int iOS_PttService_PLIBlogin( char * userId, char * password,
                                    char * phoneMode, char * phoneSystemVersion, char * phoneIMEI,
                                    char * phoneNumber, char * phoneNumberAttribution );
extern int iOS_PttService_PLIBlogout(  );
extern int iOS_PttService_PLIBgetGroups(  );
extern int iOS_PttService_PLIBgetGroupMembers( char * groupId );
extern int iOS_PttService_PLIBcreateTempGroup( char * groupId, char * groupName, char * userIdList );
extern int iOS_PttService_PLIBstartTalk(  );
extern int iOS_PttService_PLIBstopTalk(  );
extern int iOS_PttService_PLIBenableGroupTalk( char * groupId );
extern int iOS_PttService_PLIBjoinTalk( char * groupId );
extern int iOS_PttService_PLIBquitTalk(  );
extern int iOS_PttService_PLIBstartListenConfirm(  );
extern int iOS_PttService_PLIBstopListenConfirm(  );
extern int iOS_PttService_PLIBgetUserState(  );
extern int iOS_PttService_PLIBgetUserTalkGroupId( unsigned char * groupId );
extern int iOS_PttService_PLIBgetUserTalkState(  );
extern int iOS_PttService_PLIBgetUserTalkSeconds(  );
extern int iOS_PttService_PLIBgetTalkUserId( unsigned char * userId );
extern int iOS_AudioProcess_PLIBgetNoise( unsigned char * data, int noiseSize );
extern int iOS_AudioProcess_PLIBsetAudioSendChannelCodecInfo( int codec, int packetNum );
extern int iOS_AudioProcess_PLIBnewAudioSendChannel(  );
extern int iOS_AudioProcess_PLIBdeleteAudioSendChannel(  );
extern int iOS_AudioProcess_PLIBnewAudioRecvChannel(  );
extern int iOS_AudioProcess_PLIBdeleteAudioRecvChannel(  );
extern int iOS_AudioProcess_PLIBmicAudioPush( unsigned char * data );
extern int iOS_AudioProcess_PLIBspeakerAudioPop( unsigned char * data );
extern int iOS_AudioProcess_PLIBstopAudioRecv(  );
extern int iOS_PttService_PLIBgetPrint( unsigned char * data );



