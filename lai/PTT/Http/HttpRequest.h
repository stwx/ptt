//
//  HttpRequest.h
//  PTT
//
//  Created by xihan on 15/6/3.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HttpInfo.h"

@interface HttpRequest : NSObject

+ (void)postRequestWithHttpType:(HttpType)httpTpye
                         action:(int) action
                         params:(NSArray *)params
                        Handler:(AckHandler)handler;

+ (void)uploadFileByFilePath:(NSString *)filePath
                     handler:(AckHandler)handler;

+ (void)downloadFileByFileName:(NSString *)fileName
                       handler:(DicHandler)handler;

@end
