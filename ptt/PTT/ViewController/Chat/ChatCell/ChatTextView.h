//
//  ChatTextView.h
//  PTT
//
//  Created by xihan on 15/6/10.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatCellFrameModel.h"

@interface ChatTextView : UIButton

//text
@property (nonatomic, copy) NSString * text;

//audio
@property (nonatomic, strong) UIImageView * voice;
@property (nonatomic, strong) UILabel * durLabel;
@property (nonatomic, assign) float dur;
@property (nonatomic, assign) BOOL fromSelf;

- (void)stopPlayAnimating;
- (void)startPlayAnimating;


@end
