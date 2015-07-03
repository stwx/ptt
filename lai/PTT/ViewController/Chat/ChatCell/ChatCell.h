//
//  ChatCell.h
//  PTT
//
//  Created by xihan on 15/6/4.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ChatCell;

@protocol ChatCellDelegate <NSObject>
@optional
- (void)ChatCell_headImgDidClick:(NSInteger)index;
- (void)ChatCell_playRecordByIndex:(NSInteger)index
                              play:(BOOL)play;
@end

typedef void (^RecordContentBlock)(NSInteger index);

@class ChatCellFrameModel;
@interface ChatCell : UITableViewCell

+ (ChatCell *)dequeueReusableCellFromTableView:(UITableView *)tableView;
@property (nonatomic, strong)ChatCellFrameModel *cellFrame;
@property (nonatomic, assign)id<ChatCellDelegate>delegate;

- (void)stopPlayAnimating;

@end
