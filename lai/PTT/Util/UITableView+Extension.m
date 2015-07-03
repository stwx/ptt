//
//  UITableView_Extension.m
//  EZLearning
//
//  Created by xihan on 15/5/30.
//  Copyright (c) 2015年 STWX. All rights reserved.
//

#import "UITableView+Extension.h"

@implementation UITableView(Extension)

- (void)deselect{
    [self deselectRowAtIndexPath:[self indexPathForSelectedRow] animated:YES];
}

- (void)hideExtraSeparatorLine{
    UIView *view = [[UIView alloc] init];
    [view setBackgroundColor:[UIColor clearColor]];
    [self setTableFooterView:view];
}

@end
