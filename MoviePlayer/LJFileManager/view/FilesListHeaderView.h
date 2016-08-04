//
//  FilesListHeaderView.h
//  MoviePlayer
//
//  Created by liangjiajian_mac on 16/8/2.
//  Copyright © 2016年 cn.ljj. All rights reserved.
//

#import <UIKit/UIKit.h>
#define CURRENT_PATH_HEIGHT 40
#define BACK_PATH_HEIGHT    70

@interface FilesListHeaderView : UIView
@property (weak, nonatomic) IBOutlet UILabel *pathLabel;
@property (strong, nonatomic) UIView *backFolderView;

+ (UIView *)newView;
- (void)setBackFolderViewVisible:(BOOL)visible;

@end
