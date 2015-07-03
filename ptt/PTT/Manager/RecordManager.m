//
//  RecordManager.m
//  PTT
//
//  Created by xihan on 15/6/22.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import "RecordManager.h"
#import <AVFoundation/AVFoundation.h>

@interface RecordManager()<AVAudioPlayerDelegate,AVAudioRecorderDelegate>
{
    AVAudioRecorder *_recorder;
    NSString *_fileName, *_folder, *_filePath;
    BOOL _recording, _playing;
    AVAudioPlayer *_player;
}
@end

@implementation RecordManager

+ (RecordManager *)shareRecordManager{
    static RecordManager *recordManager = nil;
    static dispatch_once_t predocate;
    dispatch_once(&predocate, ^{
        recordManager  = [[RecordManager alloc] init];
    });
    return recordManager;
}

+ (void)startRecord{
    RecordManager *manager = [RecordManager shareRecordManager];
    [manager startRecord];
}

+ (void)stopRecord:(RecordBlock)block{
    RecordManager *manager = [RecordManager shareRecordManager];
    [manager stopRecord:block];
}

+ (void)playWithFileName:(NSString *)fileName
                complete:(PlayBlock)block{
    RecordManager *manager = [RecordManager shareRecordManager];
    manager.playBlock = block;
    [manager playWithFileName:fileName];
}



- (instancetype)init{
    self = [super init];
    if (self) {
        NSString *document = PATH_OF_DOCUMENT;
        _folder = [document stringByAppendingPathComponent:@"Record"];
    }
    return self;
}

- (void)startRecord{
    
    if (_recording) {
        return;
    }
    
    if ( 1 != [ self initAudioSession ] ){
        return;
    }
    DLog(@"RecordManager strartRecord");
    _recording = YES;
    
    NSDictionary *recordSetting =
    @{
      AVSampleRateKey : [NSNumber numberWithFloat:8000.0],
      AVFormatIDKey : [NSNumber numberWithInt: kAudioFormatLinearPCM],
      AVLinearPCMBitDepthKey : [NSNumber numberWithInt:16],
      AVNumberOfChannelsKey : [NSNumber numberWithInt: 2],
      AVLinearPCMIsBigEndianKey : [NSNumber numberWithBool:NO],
      AVLinearPCMIsFloatKey : [NSNumber numberWithBool:NO]
      };
    
    _fileName = [self getSystemTime];
  
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:_folder]) {
        
        BOOL blCreateFolder= [fileManager createDirectoryAtPath:_folder withIntermediateDirectories:NO attributes:nil error:NULL];
        
        if (!blCreateFolder) {
            DLog(@" create folder fail ");
            return ;
        }
    }

    _filePath = [[[_folder stringByAppendingPathComponent:_fileName]
                  stringByAppendingPathExtension:@"wav"]
                 stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *fileUrl = [NSURL fileURLWithPath:_filePath];
    
    NSError *error;
    _recorder = [[AVAudioRecorder alloc] initWithURL:fileUrl settings:recordSetting error:&error];
    if (error != nil) {
        DLog(@"start record fail : %@",error);
        return;
    }
    _recorder.delegate = self;
    [_recorder prepareToRecord];
    [_recorder record];

}

- (void)stopRecord:(RecordBlock)block{

    if (_recording == YES) {
        [ _recorder stop ];
         _recording = NO;
        
        _player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:_filePath] error:nil];
        
        self.recordBlock = block;
    }
}

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    _recording = NO;
    if (!flag) {
         DLog(@" Record failed!!!");
    }

    if (self.recordBlock) {
        self.recordBlock(flag,[NSString stringWithFormat:@"%@.wav",_fileName],_filePath, _player.duration);
        _player = nil;
    }
}

- (void)playWithFileName:(NSString *)fileName{
    if (_playing || _recording) {
        [_player stop];
        _playing = NO;
        return;
    }
    if ( 1 != [ self initAudioSession ] ){
        return;
    }
    _playing = YES;
    NSError *error;
    
    NSString *path = [[_folder stringByAppendingPathComponent:fileName] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    NSArray *files = [fileManager subpathsAtPath:_folder];
//    DLog(@"\n=======\n%@\n=======\n",files);
    
    _player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&error];
    
    if (error) {
        DLog(@"%@",error);
        return;
    }
    _player.volume =1;
    _player.numberOfLoops =0;
    _player.delegate = self;
    [_player prepareToPlay];
    [_player play];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    _playing = NO;
    if (self.playBlock) {
        self.playBlock();
    }
}

-(NSString *)getSystemTime{
    NSDateFormatter *formatter =[[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    NSString *currentTime = [formatter stringFromDate:[NSDate date]];
    return currentTime;
}

-(int)initAudioSession{
    
    AVAudioSession  *audioSession = [AVAudioSession sharedInstance];
    NSError         *error = nil;
    
    BOOL ret;
    
    ret = [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    
    if(!ret){
        DLog(@"%@",[error description]);
    }
    
    ret = [audioSession setActive:YES error:&error];
    if(!ret){
        DLog(@"%@",[error description]);
    }
    
    UInt32 route = kAudioSessionOverrideAudioRoute_Speaker;
    ret = [audioSession overrideOutputAudioPort:route error:&error];
    
    if (!ret){
        DLog(@"%@",[error description]);
    }
    
    return 1;
}

@end
