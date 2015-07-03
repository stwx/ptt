//
//  NSDate+Extension.h
//  PTT
//
//  Created by xihan on 15/6/22.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate(Extension)

+ (NSString *)dateString;
+ (NSDate *)dateFromString:(NSString *)dateString;

- (NSString *)string;
- (NSString *)msgDateString;
- (NSString *)conversationDataString;

- (NSInteger)minuteFromDate:(NSDate *)date;

- (BOOL)isThisYear;
- (BOOL)isThisMonth;
- (BOOL)isToday;
- (BOOL)isYesterday;


@end
