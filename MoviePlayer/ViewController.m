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

@interface ViewController () <FilesSelectDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation ViewController {
    NSURL *url;
}
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

-(void)handleWrittenFile:(ALAsset*) videoAsset {
    NSDictionary *assetUrls = [videoAsset valueForProperty:ALAssetPropertyURLs];
    NSString *key =[[assetUrls allKeys] firstObject];
    NSString *urlStr = [[assetUrls objectForKey:key] description];
    NSDictionary *parms = [self parseUrl:urlStr];
    NSLog(@"parms=%@", parms);
    NSString *videoId = [parms objectForKey:@"id"];
    NSString *ext = [parms objectForKey:@"ext"];
    NSLog(@"videoId=%@, ext=%@", videoId, ext);
    NSString *DocRoot = [(NSArray*)NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
    NSString *tempFile = [NSString stringWithFormat:@"%@/%@.%@",DocRoot, videoId, ext];
    ALAssetRepresentation *rep = [videoAsset defaultRepresentation];
    NSUInteger size = [rep size];
    const int bufferSize = 65636;
    NSLog(@"written to : %@", tempFile);
    FILE *f = fopen([tempFile cStringUsingEncoding:1], "wb+");
    if (f==NULL) {
        return;
    }
    Byte *buffer =(Byte*)malloc(bufferSize);
    int read =0, offset = 0;
    NSError *error;
    if (size != 0) {
        do {
            read = [rep getBytes:buffer
                      fromOffset:offset
                          length:bufferSize
                           error:&error];
            fwrite(buffer, sizeof(char), read, f);
            offset += read;
//            NSLog(@"read : %d   total : %d",read, offset);
        } while (read != 0);
//        currentLength =0;
//        expectedLength = offset;
    }
    fclose(f);
}

- (NSDictionary *)parseUrl:(NSString*)url {
    NSMutableDictionary *dic = [NSMutableDictionary new];
    if([url containsString:@"?"]){
        url = [[url componentsSeparatedByString:@"?"] lastObject];
    }
    NSArray *components = [url componentsSeparatedByString:@"&"];
    for(NSString *component in components){
        NSArray *keyValue = [component componentsSeparatedByString:@"="];
        if(keyValue && keyValue.count == 2){
            [dic setObject:[keyValue lastObject] forKey:[keyValue firstObject]];
        }
    }
    return dic;
}

- (void)cancelSelecte {
    NSLog(@"cancelSelecte");
}

- (BOOL)filterFiles:(FileModel *)model {
    return YES;
}

- (IBAction)onClickServerItem:(UIBarButtonItem *)sender {
    ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc]init];//生成整个photolibrary句柄的实例
    NSMutableArray *mediaArray = [[NSMutableArray alloc]init];//存放media的数组
    [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {//获取所有group
        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {//从group里面
            NSString* assetType = [result valueForProperty:ALAssetPropertyType];
            if ([assetType isEqualToString:ALAssetTypePhoto]) {
//                NSLog(@"Photo");
            }else if([assetType isEqualToString:ALAssetTypeVideo]){
                NSLog(@"Video result=%@", result);
                [self handleWrittenFile:result];
            }else if([assetType isEqualToString:ALAssetTypeUnknown]){
                NSLog(@"Unknow AssetType");
            }
//            
//            NSLog(@"Representation Size = %lld",[[result defaultRepresentation]size]);
        }];
    } failureBlock:^(NSError *error) {
        NSLog(@"Enumerate the asset groups failed.");
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
