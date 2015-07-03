//
//  NSString+Extension.h
//  PTT
//
//  Created by xihan on 15/5/26.
//  Copyright (c) 2015年 STWX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (Extension)

- (CGSize)sizeWithFont:(UIFont *)font andWidth:(float)width;
- (CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize;
- (NSDictionary *)jsonToDictionary;
- (BOOL)isNull;
- (char *)stringToChar;
- (BOOL)isMobileNumber;
- (BOOL)haveString:(NSString *)str;
- (NSString *)firstLetter;
- (NSString *)firstLetters;

@end
