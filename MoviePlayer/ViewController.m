//
//  ViewController.m
//  MoviePlayer
//
//  Created by liangjiajian_mac on 16/7/27.
//  Copyright © 2016年 cn.ljj. All rights reserved.
//

#import "ViewController.h"
#import "LJAVPlayerViewController.h"
#import "FileManageViewController.h"

@interface ViewController () <FilesSelectDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation ViewController
- (IBAction)onClickLocalItem:(UIBarButtonItem *)sender {
    FileManageViewController *vc = [[FileManageViewController alloc]init];
    vc.delegate = self;
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}

- (void)didSelectFiles:(FileModel *)file{
    NSURL *url = [NSURL fileURLWithPath:file.path];
    LJAVPlayerViewController *vc = [[LJAVPlayerViewController alloc]initWithURL:url];
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}

- (void)cancelSelecte {
    NSLog(@"cancelSelecte");
}

- (BOOL)filterFiles:(FileModel *)model {
    if(model.type == TypeDirectory
       || [model.name hasSuffix:@".MOV"]
       || [model.name hasSuffix:@".mp4"]){
        return YES;
    }
    return NO;
}

- (IBAction)onClickServerItem:(UIBarButtonItem *)sender {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
