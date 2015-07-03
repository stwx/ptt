//
//  AudioManager.m
//  BlueTalk
//
//  Created by China on 13-2-2.
//


#import "AudioManager.h"
#include "PttS.h"
#import "PttService.h"
#import "UDManager.h"

RecorderStruct	  mAudioRecorder;
PlayerStruct      mAudioPlayer;
Byte              *noiseData;

int             position = 0;
int             currentPlayType;

BOOL            m_IsAudioStart = NO;
BOOL            m_IsAudioPaused = NO;
BOOL            m_IsSpeakerUsed = NO;


#pragma  mark  录音回调函数
static void Solgo_AudioManager_RecorderCallBack( void *inUserData,
                                                AudioQueueRef inAQ,
                                                AudioQueueBufferRef inBuffer,
                                                const AudioTimeStamp *inStartTime,
                                                UInt32 inNumPackets,
                                                const AudioStreamPacketDescription *inPacketDesc )
{
    uint8_t   tempRecordBuffer[MAX_TEMP_RECORD_BUFFER_SIZE]={};
    
    AudioQueueEnqueueBuffer( inAQ, inBuffer, 0, NULL );
    
    RecorderStruct 	*pAudioRecorder = (RecorderStruct*)inUserData;
    
    if( inAQ != pAudioRecorder->AudioRecorderQueue )
        
    {
        SOLGO_ASSERT;
        return;
    }
    
    if( NO == pAudioRecorder->IsRecording )
    {
        SOLGO_ASSERT;
        return;
    }

    memcpy(tempRecordBuffer, inBuffer->mAudioData, inBuffer->mAudioDataByteSize);
    
    int len = iOS_AudioProcess_PLIBmicAudioPush(tempRecordBuffer);
    if ( 0 > len )
    {
        SOLGO_ASSERT;
    }

    [ [ PttService sharedInstance ]  PttNativeRun ];

}

#pragma mark  播音回调函数
static void Solgo_AudioManager_PlayerCallBack( void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef outQB )
{
    uint8_t    	tempRecvBuffer[WAVE_PACKET_SIZE_IN_BYTES] = {};
    char        *Audiobuffer;
    
    PlayerStruct 	*pAudioPlayer = (PlayerStruct*) inUserData;
    
    if( inAQ != pAudioPlayer->AudioPlayerQueue )
    {
        SOLGO_ASSERT;
        return;
    }
    
    if( NO == pAudioPlayer->IsPlaying && NO == m_IsAudioPaused )
    {
        SOLGO_ASSERT;
        outQB->mAudioDataByteSize = WAVE_PACKET_SIZE_IN_BYTES;
        Audiobuffer = (char*) outQB->mAudioData;
        memcpy( (void*)Audiobuffer, (void*)tempRecvBuffer, WAVE_PACKET_SIZE_IN_BYTES );
        AudioQueueEnqueueBuffer( inAQ, outQB, 0, NULL );
        return;
    }
    
    outQB->mAudioDataByteSize = WAVE_PACKET_SIZE_IN_BYTES;
    Audiobuffer = (char*) outQB->mAudioData;
    
    if ( position != NOISE_DATA_SIZE  )
    {
        Solgo_AudioManager_GetNoiseData(tempRecvBuffer, position, WAVE_PACKET_SIZE_IN_BYTES);
        position += WAVE_PACKET_SIZE_IN_BYTES;
    }
    else
    {
       iOS_AudioProcess_PLIBspeakerAudioPop(tempRecvBuffer);
    }
   
    memcpy( (void*)Audiobuffer, (void*)tempRecvBuffer, WAVE_PACKET_SIZE_IN_BYTES );
    
    AudioQueueEnqueueBuffer( inAQ, outQB, 0, NULL );
}

#pragma mark   播放提示音回调函数
static void Solgo_AudioManager_PlayNoiseCallBack( void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef outQB )
{
    uint8_t    	tempRecvBuffer[WAVE_PACKET_SIZE_IN_BYTES] = {};
    char        *Audiobuffer;
    
    PlayerStruct 	*pAudioPlayer = (PlayerStruct*) inUserData;
    
    if( inAQ != pAudioPlayer->AudioPlayerQueue )
    {
        SOLGO_ASSERT;
        return;
    }
    
    if( NO == pAudioPlayer->IsPlaying && NO == m_IsAudioPaused )
    {
        SOLGO_ASSERT;
        outQB->mAudioDataByteSize = WAVE_PACKET_SIZE_IN_BYTES;
        Audiobuffer = (char*) outQB->mAudioData;
        memcpy( (void*)Audiobuffer, (void*)tempRecvBuffer, WAVE_PACKET_SIZE_IN_BYTES );
        AudioQueueEnqueueBuffer( inAQ, outQB, 0, NULL );
        return;
    }
    
    outQB->mAudioDataByteSize = WAVE_PACKET_SIZE_IN_BYTES;
    Audiobuffer = (char*) outQB->mAudioData;
    
    if ( position != NOISE_DATA_SIZE  )
    {
        Solgo_AudioManager_GetNoiseData(tempRecvBuffer, position, WAVE_PACKET_SIZE_IN_BYTES);
        
        position += WAVE_PACKET_SIZE_IN_BYTES;
        
        memcpy( (void*)Audiobuffer, (void*)tempRecvBuffer, WAVE_PACKET_SIZE_IN_BYTES );
        
        AudioQueueEnqueueBuffer( inAQ, outQB, 0, NULL );
    }
}

#pragma mark   静音回调函数
static void Solgo_AudioManager_MuteCallBack( void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef outQB )
{
    uint8_t    	tempRecvBuffer[WAVE_PACKET_SIZE_IN_BYTES] = {};
    char        *Audiobuffer;
    
    PlayerStruct 	*pAudioPlayer = (PlayerStruct*) inUserData;
    
    if( inAQ != pAudioPlayer->AudioPlayerQueue )
    {
        SOLGO_ASSERT;
        return;
    }
    
    if( NO == pAudioPlayer->IsPlaying && NO == m_IsAudioPaused )
    {
        SOLGO_ASSERT;
        outQB->mAudioDataByteSize = WAVE_PACKET_SIZE_IN_BYTES;
        Audiobuffer = (char*) outQB->mAudioData;
        memcpy( (void*)Audiobuffer, (void*)tempRecvBuffer, WAVE_PACKET_SIZE_IN_BYTES );
        AudioQueueEnqueueBuffer( inAQ, outQB, 0, NULL );
        return;
    }
    
    outQB->mAudioDataByteSize = WAVE_PACKET_SIZE_IN_BYTES;
    Audiobuffer = (char*) outQB->mAudioData;
    
    memcpy( (void*)Audiobuffer, (void*)tempRecvBuffer, WAVE_PACKET_SIZE_IN_BYTES );
    
    AudioQueueEnqueueBuffer( inAQ, outQB, 0, NULL );
}


void Solgo_AudioManager_Init(void)
{
    int         iLoop;
    
    for( iLoop = 0; iLoop < RECORD_BUFFERS_NUM; iLoop++ )
    {
        mAudioRecorder.AudioRecorderBuffers[iLoop] = NULL;
    }
    mAudioRecorder.AudioRecorderQueue = NULL;
    mAudioRecorder.IsMute = NO;
    mAudioRecorder.IsRecording = NO;
    
    for( iLoop = 0; iLoop < PLAY_BUFFERS_NUM; iLoop++ )
    {
        mAudioPlayer.AudioPlayerBuffers[iLoop] = NULL;
    }
    mAudioPlayer.AudioPlayerQueue = NULL;
    mAudioPlayer.IsPlaying = NO;
    
    Solgo_AudioManager_GetNoise();
}

int Solgo_AudioManager_InitSession()
{
    AVAudioSession  *audioSession = [AVAudioSession sharedInstance];
    NSError         *error = nil;
    
    BOOL ret;
    
    ret = [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];

    if(!ret)
    {
        NSLog(@"%@",[error description]);
    }
    
    ret = [audioSession setActive:YES error:&error];
    
    if(!ret)
    {
        NSLog(@"%@",[error description]);
    }
    
    UInt32 route = kAudioSessionOverrideAudioRoute_Speaker;
    ret = [audioSession overrideOutputAudioPort:route error:&error];
    
    if (!ret)
    {
        NSLog(@"%@",[error description]);
    }
    
    return 1;
}

#pragma mark  录音
void Solgo_AudioManager_StartRecord()
{
    Solgo_AudioManager_StartPlayProcess(NOISE);
    mAudioRecorder.IsRecording = YES;
}

int Solgo_AudioManager_StartRecordProcess( BOOL  IsMute)
{
    OSStatus 						result;
    AudioStreamBasicDescription		AudioStreamFormat;
    UInt32                      	bufferByteSize = WAVE_PACKET_SIZE_IN_BYTES;
    int								i;

    if ( 0 > iOS_AudioProcess_PLIBsetAudioSendChannelCodecInfo(6, 5) )
    {
        SOLGO_ASSERT;
        return 0;
    }
    
    if( 1 !=  Solgo_AudioManager_InitSession() )
    {
        SOLGO_ASSERT;
        return 0;
    }
    
#pragma mark 初始化语音格式
    AudioStreamFormat.mSampleRate = SAMPLES_PER_SECOND;
    AudioStreamFormat.mFormatID = kAudioFormatLinearPCM;
    AudioStreamFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    AudioStreamFormat.mChannelsPerFrame = 1;
    AudioStreamFormat.mBitsPerChannel = 16;
    AudioStreamFormat.mBytesPerPacket = 2;
    AudioStreamFormat.mBytesPerFrame = 2;
    AudioStreamFormat.mFramesPerPacket = 1;
    AudioStreamFormat.mReserved = 0;

    if( NULL != mAudioRecorder.AudioRecorderQueue )
    {
        result = AudioQueueDispose( mAudioRecorder.AudioRecorderQueue, true );
        if( result )
        {
            SOLGO_ASSERT;
            return 0;
        }
        mAudioRecorder.AudioRecorderQueue = NULL;
    }

#pragma mark 申请录音队列
    result = AudioQueueNewInput( &AudioStreamFormat, Solgo_AudioManager_RecorderCallBack, &mAudioRecorder, CFRunLoopGetMain(), kCFRunLoopCommonModes, 0, &mAudioRecorder.AudioRecorderQueue );

    if( result )
    {
        SOLGO_ASSERT;
        return 0;
    }

#pragma mark 申请录音缓冲区
    for( i = 0; i < RECORD_BUFFERS_NUM; i++ )
    {
        result = AudioQueueAllocateBuffer( mAudioRecorder.AudioRecorderQueue, bufferByteSize, &mAudioRecorder.AudioRecorderBuffers[i] );
        if( result )
        {
            SOLGO_ASSERT;
            return 0;
        }
        
        result = AudioQueueEnqueueBuffer( mAudioRecorder.AudioRecorderQueue, mAudioRecorder.AudioRecorderBuffers[i], 0, NULL );
        if( result )
        {
            SOLGO_ASSERT;
            return 0;
        }
    }
    
    if ( 1 != iOS_AudioProcess_PLIBnewAudioSendChannel() )
    {
        SOLGO_ASSERT;
        return 0;
    }
    
    AudioQueueStart(mAudioRecorder.AudioRecorderQueue, NULL);
    
    mAudioRecorder.IsMute = IsMute;
    mAudioRecorder.IsRecording = YES;
    
    return 1;
}

#pragma mark 播音
int Solgo_AudioManager_StartPlayProcess( int type )
{
    OSStatus 						result = 0;
    AudioStreamBasicDescription		AudioStreamFormat;
    UInt32                      	bufferByteSize = WAVE_PACKET_SIZE_IN_BYTES;
    int								i;
    
    if( 1 !=  Solgo_AudioManager_InitSession() )
    {
        SOLGO_ASSERT;
        return 0;
    }
    
    if ( 1 != iOS_AudioProcess_PLIBnewAudioRecvChannel() )
    {
        SOLGO_ASSERT;
    }
    
#pragma mark 初始化放音格式
    AudioStreamFormat.mReserved = 0;
    AudioStreamFormat.mSampleRate = SAMPLES_PER_SECOND;
    AudioStreamFormat.mFormatID = kAudioFormatLinearPCM;
    AudioStreamFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
    AudioStreamFormat.mChannelsPerFrame = 1;
    AudioStreamFormat.mBitsPerChannel = 16;
    AudioStreamFormat.mBytesPerPacket = 2;
    AudioStreamFormat.mBytesPerFrame = 2;
    AudioStreamFormat.mFramesPerPacket = 1;
    
    if( NULL != mAudioPlayer.AudioPlayerQueue )
    {
        result = AudioQueueDispose( mAudioPlayer.AudioPlayerQueue, true );
        if( result )
        {
            SOLGO_ASSERT;
            return 0;
        }
        mAudioPlayer.AudioPlayerQueue = NULL;
    }
    
    if ( type == VOICE )
    {
        NSLog(@" -->> [ type == VOICE ]");
        mAudioPlayer.IsPlaying = YES;
        
        result = AudioQueueNewOutput( &AudioStreamFormat, Solgo_AudioManager_PlayerCallBack, &mAudioPlayer, CFRunLoopGetMain(), kCFRunLoopCommonModes, 0, &mAudioPlayer.AudioPlayerQueue );
    }
    
    else if ( type == NOISE )
    {
        NSLog(@" -->> [ type == NOISE ]");
        mAudioPlayer.IsNoisePlaying = YES;
        mAudioPlayer.IsPlaying = YES;
        
        result = AudioQueueNewOutput( &AudioStreamFormat, Solgo_AudioManager_PlayNoiseCallBack, &mAudioPlayer, CFRunLoopGetMain(), kCFRunLoopCommonModes, 0, &mAudioPlayer.AudioPlayerQueue );
        
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            Solgo_AudioManager_StopNoiseProcess();
        });
    }
    else if ( type == BGM )
    {
        //非对讲状态不播放后台静音进程
        if (![UDManager isTalking])
        {
            return 0;
        }
        //听讲状态不播放后台静音进程
        if ( [[ PttService sharedInstance ] PTT_GetUserTalkState ] == USER_TALK_STATE_RECEIVER )
        {
            return 0;
        }
         NSLog(@" -->> [ type == BGM ] ");
        result = AudioQueueNewOutput( &AudioStreamFormat, Solgo_AudioManager_MuteCallBack, &mAudioPlayer, CFRunLoopGetMain(), kCFRunLoopCommonModes, 0, &mAudioPlayer.AudioPlayerQueue );
    }
    
    if( result )
    {
        SOLGO_ASSERT;
        return 0;
    }
    
    currentPlayType = type;
    mAudioPlayer.IsPlaying = YES;
    
    //申请放音缓冲区
    for( i = 0; i < PLAY_BUFFERS_NUM; i++ )
    {
        result = AudioQueueAllocateBuffer( mAudioPlayer.AudioPlayerQueue, bufferByteSize, &mAudioPlayer.AudioPlayerBuffers[i] );
        
    }
    if( result )
    {
        SOLGO_ASSERT;
        return 0;
    }
    
    AudioQueueReset(mAudioPlayer.AudioPlayerQueue);
    
    //收齐一定数量的包后，开始放音
    if( type == VOICE )
    {
        NSLog(@"Start play voice\n");
        for( int loop = 0; loop < PLAY_BUFFERS_NUM; loop++)
        {
            Solgo_AudioManager_PlayerCallBack( &mAudioPlayer, mAudioPlayer.AudioPlayerQueue, mAudioPlayer.AudioPlayerBuffers[loop] );
        }
    }
    else if ( type == NOISE )
    {
        NSLog(@"Start play noise\n");
        for( int loop = 0; loop < PLAY_BUFFERS_NUM; loop++)
        {
            Solgo_AudioManager_PlayNoiseCallBack( &mAudioPlayer, mAudioPlayer.AudioPlayerQueue, mAudioPlayer.AudioPlayerBuffers[loop] );
        }
    }
    else if ( type == BGM )
    {
        NSLog(@"Start play BGM\n");
        for( int loop = 0; loop < PLAY_BUFFERS_NUM; loop++)
        {
            Solgo_AudioManager_MuteCallBack( &mAudioPlayer, mAudioPlayer.AudioPlayerQueue, mAudioPlayer.AudioPlayerBuffers[loop] );
        }
    }
    
//    Float32 gain = 1.0;
//    //设置音量
//    AudioQueueSetParameter (
//                            mAudioPlayer.AudioPlayerQueue,
//                            kAudioQueueParam_Volume,
//                            gain
//                            );
    result = AudioQueueStart( mAudioPlayer.AudioPlayerQueue, NULL );
    if( result )
    {
        SOLGO_ASSERT;
        return 0;
    }
    
    m_IsAudioStart = YES;
    
    return 1;
}

#pragma mark 结束语音进程
int Solgo_AudioManager_StopProcess()
{
    OSStatus 						result;
    if ( YES ==  mAudioPlayer.IsPlaying )
    {
        result = AudioQueueDispose( mAudioPlayer.AudioPlayerQueue, true );
        if( result )
        {
            SOLGO_ASSERT;
            return 0;
        }
        position = 0;
        mAudioPlayer.AudioPlayerQueue = NULL;
        mAudioPlayer.IsPlaying = NO;
    }
    
    if(  YES ==  mAudioRecorder.IsRecording  )
    {
        result = AudioQueueDispose( mAudioRecorder.AudioRecorderQueue, true );
     
        if( result )
        {
            SOLGO_ASSERT;
            return 0;
        }
        
        mAudioRecorder.AudioRecorderQueue = NULL;
        mAudioRecorder.IsRecording = NO;
    }
    
    mAudioRecorder.IsMute = YES;
    m_IsAudioStart = NO;
    
    NSLog(@"Stop play voice");
    
    return 1;
}

#pragma mark 结束提示音
int Solgo_AudioManager_StopNoiseProcess()
{
    OSStatus 						result; 
    if ( YES == mAudioPlayer.IsNoisePlaying )
    {
        result = AudioQueueDispose( mAudioPlayer.AudioPlayerQueue, true );
        if( result )
        {
            SOLGO_ASSERT;
            return 0;
        }
        mAudioPlayer.AudioPlayerQueue = NULL;
        mAudioPlayer.IsNoisePlaying = NO;
        mAudioPlayer.IsPlaying = NO;
        position = 0;
        
        if ( NO == mAudioRecorder.IsRecording )
        {
            if ( [[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground)
            {
                Solgo_AudioManager_StartPlayProcess(BGM);
            }
        }
    }
    if ( YES == mAudioRecorder.IsRecording )
    {
        Solgo_AudioManager_StartRecordProcess(NO);
    }
    
    NSLog(@"Stop play noise");
    return 1;
}

#pragma mark 结束后台
void Solgo_AudioManager_StopBGM()
{
    OSStatus 						result;
    //听讲状态不结束
    if ( [[ PttService sharedInstance ] PTT_GetUserTalkState ] == USER_TALK_STATE_RECEIVER )
    {
        return ;
    }
    
    if ( YES ==  mAudioPlayer.IsPlaying )
    {
        result = AudioQueueDispose( mAudioPlayer.AudioPlayerQueue, true );
        if( result )
        {
            SOLGO_ASSERT;
            return;
        }
        
        mAudioPlayer.AudioPlayerQueue = NULL;
    }

    mAudioPlayer.IsPlaying = NO;

    m_IsAudioStart = NO;
    
    NSLog(@"Stop play BGM");
}

#pragma mark 获取提示音数据
void Solgo_AudioManager_GetNoise()
{
    noiseData = (Byte*)malloc(NOISE_DATA_SIZE);
    iOS_AudioProcess_PLIBgetNoise(noiseData, NOISE_DATA_SIZE);
}

void Solgo_AudioManager_GetNoiseData(Byte *data,int start,int len)
{
    memcpy(data, noiseData+start, len);
}
