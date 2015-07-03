//
//  EstimateUtil.m
//  PTT
//
//  Created by xihan on 15/6/19.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import "EstimateUtil.h"
#import "NSString+Extension.h"

@implementation EstimateUtil

//0：密码格式正确；1:密码长度不够；2:密码格式错误
+ (int)pwdErrorTypeWithPwd:(NSString *)pwd
{
    int len = (int) pwd.length;
    unichar c;
    for (int i = 0; i < len; i++)
    {
        c = [pwd characterAtIndex:i];
        if (!isalnum(c))
        {
            return  2;
        }
    }
    if (6 > len || 10 < len)
    {
        return 1;
    }
    return 0;
}

+ (BOOL)haveIllegalChar:(NSString *)str{
    NSArray *array = @[@"\"",@"'",@",",@"&",@"!"];
    __block BOOL result = NO;
    [array enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        if ([str haveString:obj]) {
            *stop = YES;
            result = YES;
        }
    }];
    return result;
}

+ (BOOL)isGroupId:(NSString *)idStr{
    if ([[idStr substringToIndex:1] isEqualToString:@"g"]) {
        return YES;
    }
    return NO;
}


@end
