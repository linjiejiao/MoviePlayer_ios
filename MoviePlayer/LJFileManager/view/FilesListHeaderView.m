//
//  FilesListHeaderView.m
//  MoviePlayer
//
//  Created by liangjiajian_mac on 16/8/2.
//  Copyright © 2016年 cn.ljj. All rights reserved.
//

#import "FilesListHeaderView.h"

@implementation FilesListHeaderView

+ (UIView *)newView {
    NSArray *views = [[NSBundle mainBundle] loadNibNamed:@"FilesListHeaderView" owner:nil options:nil];
    FilesListHeaderView *header = views.firstObject;
    header.backFolderView = views.lastObject;
    CGRect frame = header.backFolderView.frame;
    frame.origin.y = CGRectGetMaxY(header.pathLabel.frame);
    header.backFolderView.frame = frame;
    return header;
}

- (void)setBackFolderViewVisible:(BOOL)visible {
    if(visible){
        if(!self.backFolderView.superview){
            [self addSubview:self.backFolderView];
        }
    }else{
        if(self.backFolderView.superview){
            [self.backFolderView removeFromSuperview];
        }
    }
}
@end
