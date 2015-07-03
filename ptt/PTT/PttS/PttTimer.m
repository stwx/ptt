//
//  PttTimer.m
//  PTT-test
//
//  Created by solgo on 15/4/20.
//  Copyright (c) 2015年 solgo. All rights reserved.
//

#import "PttTimer.h"

const int EN_RELATIVE_TIMER_LOOP = 2;
const int PTT_TIMER_DATA_LEN     = 100;

Byte           _tempData[100];
int            _timerMode;

@interface PttTimer()
{
    NSTimer *mTimer;
}
@end

@implementation PttTimer

-(instancetype)initWithTimerData:(Byte *)timerData
                          length:(int)length
                       timerMode:(int)timerMode
                        timerMid:(int)timerMid
                         timerId:(int)timerId
{
    if ( self = [ self init ] )
    {
        _isRunning = YES;
        _timerData = timerData;
        _length = length;
        _timerMode = timerMode;
        _timerMid = timerMid;
        _timerId = timerId;
        memcpy( _tempData, _timerData,  PTT_TIMER_DATA_LEN);
        if ( EN_RELATIVE_TIMER_LOOP == _timerMode )
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
                mTimer = [ NSTimer timerWithTimeInterval:_length
                                                  target:self
                                                selector:@selector(PttTimerTask)
                                                userInfo:nil
                                                 repeats:YES ];
                [runLoop addTimer:mTimer forMode:NSDefaultRunLoopMode];
                [runLoop run];
            });
        }
        else
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
                
                NSRunLoop* runLoop = [NSRunLoop currentRunLoop];
                mTimer = [ NSTimer timerWithTimeInterval:_length
                                                  target:self
                                                selector:@selector(PttTimerTask)
                                                userInfo:nil
                                                 repeats:NO ];
                [runLoop addTimer:mTimer forMode:NSDefaultRunLoopMode];
                               [ runLoop run ];
            });
        }
    }
    return self;
}


-(void) PttTimerTask
{
    if( _isRunning )
    {
        [ [ PttService sharedInstance ] PttTimerExpired:_tempData ];
        
        if ( EN_RELATIVE_TIMER_LOOP != _timerMode )
        {
            _isRunning = NO;
        }
    }
}

-(void) Stop
{
    if ( [ mTimer isValid ] && mTimer != nil )
    {
        [ mTimer setFireDate:[ NSDate distantFuture ] ];
    }
    
    [ mTimer invalidate ];
    mTimer = nil;
    _isRunning = NO;
}

@end
