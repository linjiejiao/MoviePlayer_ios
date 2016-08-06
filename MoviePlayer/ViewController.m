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
#import <AssetsLibrary/AssetsLibrary.h>


@interface ViewController () <FilesSelectDelegate, UITableViewDelegate>
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
    if([file.name hasSuffix:@"mp4"]
       || [file.name hasSuffix:@"MOV"]
       || [file.name hasSuffix:@"mov"]){
        LJAVPlayerViewController *vc = [[LJAVPlayerViewController alloc]initWithURL:[NSURL fileURLWithPath:file.path]];
        [self presentViewController:vc animated:YES completion:^{
            
        }];
    }
}

- (void)cancelSelecte {
    NSLog(@"cancelSelecte");
}

- (BOOL)filterFiles:(FileModel *)model {
    return YES;
}

- (IBAction)onClickServerItem:(UIBarButtonItem *)sender {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
