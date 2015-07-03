//
//  EstimateUtil.h
//  PTT
//
//  Created by xihan on 15/6/19.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EstimateUtil : NSObject

+ (int)pwdErrorTypeWithPwd:(NSString *)pwd;
+ (BOOL)haveIllegalChar:(NSString *)str;
+ (BOOL)isGroupId:(NSString *)idStr;

@end
