
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioQueue.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

#define RECORD_BUFFERS_NUM				3				//录音Buffer数量
#define PLAY_BUFFERS_NUM				10				//放音Buffer数量
#define START_POP_NUM                   16              //

#define SAMPLES_PER_SECOND		8000.0f			//语音采样速度

#define	MAX_TEMP_RECORD_BUFFER_SIZE		320

#define	WAVE_PACKET_SIZE_IN_BYTES		320

#define MS_SAMPLES_SIZE_IN_BYTES  WAVE_PACKET_SIZE_IN_BYTES/20

#define MS_HINT_VOICE_PLAY 600

#define NOISE_DATA_SIZE  MS_HINT_VOICE_PLAY * MS_SAMPLES_SIZE_IN_BYTES
//录音结构
typedef struct
{
	AudioQueueRef               AudioRecorderQueue;						        //录音队列
	AudioQueueBufferRef         AudioRecorderBuffers[RECORD_BUFFERS_NUM];		//录音缓冲区
	BOOL                        IsMute;									        //静音状态
	BOOL						IsRecording;							        //正在录音
} RecorderStruct;

//放音结构
typedef struct
{
    AudioQueueRef 				AudioPlayerQueue;						        //放音队列
    AudioQueueBufferRef 		AudioPlayerBuffers[PLAY_BUFFERS_NUM];	        //放音缓冲区
	BOOL						IsPlaying;								        //正在放音
    BOOL                        IsNoisePlaying;                                 //正在播放提示音
} PlayerStruct;

typedef enum {
    VOICE,
    NOISE,
    BGM,
} palyType;

void Solgo_AudioManager_Init(void);
void Solgo_AudioManager_StartRecord();
int  Solgo_AudioManager_StartRecordProcess( BOOL  IsMute);
int  Solgo_AudioManager_StartPlayProcess( int type );
int  Solgo_AudioManager_StopProcess();
int  Solgo_AudioManager_StopNoiseProcess();
void Solgo_AudioManager_StopBGM();
void Solgo_AudioManager_GetNoise();
void Solgo_AudioManager_GetNoiseData(Byte *data,int start,int len);


