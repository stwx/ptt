//
//  RecordManager.h
//  PTT
//
//  Created by xihan on 15/6/22.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^RecordBlock)(BOOL flag, NSString *fileName, NSString *filePath, NSTimeInterval recordDur);
typedef void (^PlayBlock)();

@interface RecordManager : NSObject

@property (nonatomic, strong)RecordBlock recordBlock;
@property (nonatomic, strong)PlayBlock playBlock;

+ (RecordManager *)shareRecordManager;

+ (void)playWithFileName:(NSString *)fileName
                complete:(PlayBlock)block;

+ (void)startRecord;


+ (void)stopRecord:(RecordBlock)block;


@end
