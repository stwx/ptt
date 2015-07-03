//
//  NSDate+Extension.m
//  PTT
//
//  Created by xihan on 15/6/22.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import "NSDate+Extension.h"

@implementation NSDate(Extension)

+ (NSString *)dateString{
    NSDate *date=[NSDate date];
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *locationString=[dateformatter stringFromDate:date];
    return locationString;
}

+ (NSDate *)dateFromString:(NSString *)dateString{
    NSDateFormatter *dateFomatter = [[NSDateFormatter alloc] init];
    [dateFomatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFomatter dateFromString:dateString];
    return date;
}

- (NSString *)string{
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *locationString=[dateformatter stringFromDate:self];
    return locationString;
}

- (NSString *)msgDateString{
    NSString *dateString;
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
    if ([self isToday]) {
        [dateformatter setDateFormat:@"HH:mm:ss"];
        NSString *locationString=[dateformatter stringFromDate:self];
        dateString = [NSString stringWithFormat:@"今天 %@", locationString];
    }
    else if( [self isYesterday] ){
        [dateformatter setDateFormat:@"HH:mm"];
        NSString *locationString=[dateformatter stringFromDate:self];
        dateString = [NSString stringWithFormat:@"昨天 %@", locationString];
    }
    else if( [self isThisYear] ){
        [dateformatter setDateFormat:@"MM-dd HH:mm"];
        dateString = [dateformatter stringFromDate:self];
    }
    return dateString;
}

- (NSString *)conversationDataString{
    NSString *dateString;
    NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
    if ([self isToday]) {
        [dateformatter setDateFormat:@"HH:mm"];
        dateString = [dateformatter stringFromDate:self];
    }
    else if( [self isYesterday] ){
        dateString = @"昨天";
    }
    else if( [self isThisYear] ){
        [dateformatter setDateFormat:@"MM-dd"];
        dateString = [dateformatter stringFromDate:self];
    }
    return dateString;
}

- (BOOL)isThisYear{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitYear;
    NSDateComponents *components = [calendar components:unit fromDate:self];
    NSDateComponents *nowComponents = [calendar components:unit fromDate:[NSDate date]];
    return nowComponents.year == components.year;
}

- (BOOL)isThisMonth{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitMonth | NSCalendarUnitYear;
    NSDateComponents *components = [calendar components:unit fromDate:self];
    NSDateComponents *nowComponents = [calendar components:unit fromDate:[NSDate date]];
    return nowComponents.month == components.month && components.month == nowComponents.month;
}

- (BOOL)isToday{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear;
    NSDateComponents *components = [calendar components:unit fromDate:self];
    NSDateComponents *nowComponents = [calendar components:unit fromDate:[NSDate date]];
    return nowComponents.month == components.month && components.month == nowComponents.month && components.day == nowComponents.day;
}

- (BOOL) isYesterday{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    int unit = NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear;
    NSDateComponents *components = [calendar components:unit fromDate:self];
    NSDateComponents *nowComponents = [calendar components:unit fromDate:[NSDate date]];
    NSInteger day = components.day - nowComponents.day ;
    return nowComponents.month == components.month && components.month == nowComponents.month && day == -1;
}

- (NSInteger)minuteFromDate:(NSDate *)date{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned int unit = NSCalendarUnitMinute;
    NSDateComponents *components1 = [calendar components:unit fromDate:self];
    NSDateComponents *components2 = [calendar components:unit fromDate:date];
    NSInteger min =  components1.minute - components2.minute ;
    return min;
}

@end
