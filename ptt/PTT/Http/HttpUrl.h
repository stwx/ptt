//
//  HttpUrlString.h
//  PTT
//
//  Created by xihan on 15/6/3.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "HttpInfo.h"

@interface HttpUrl : NSObject

+ (NSString *)httpUrlStringWithHttpType:(HttpType)httpTpye
                                 action:(int) action
                                 params:(NSArray *)params;

@end
