//
//  PttTimer.h
//  PTT-test
//
//  Created by solgo on 15/4/20.
//  Copyright (c) 2015年 solgo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PttService.h"


@interface PttTimer : NSObject


@property   (nonatomic)int            length;
@property   (nonatomic)int            timerMode;
@property   (nonatomic)BOOL           isRunning;
@property   (nonatomic)Byte           *timerData;
@property   (nonatomic)int            timerMid;
@property   (nonatomic)int            timerId;


-(instancetype)initWithTimerData:(Byte*)timerData length:(int)length timerMode:(int)timerMode timerMid:(int)timerMid timerId:(int)timerId;
-(void) Stop;

@end
