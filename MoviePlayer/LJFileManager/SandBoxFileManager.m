//
//  SandBoxFileManager.m
//  MoviePlayer
//
//  Created by liangjiajian_mac on 16/7/30.
//  Copyright © 2016年 cn.ljj. All rights reserved.
//

#import "SandBoxFileManager.h"
#import "FileModel.h"

@implementation SandBoxFileManager
static SandBoxFileManager *_instance;

+ (SandBoxFileManager *)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[SandBoxFileManager alloc]init];
    });
    return _instance;
}

- (NSArray *)getFilesUnderPath:(NSString *)path {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *filesArray = [fm contentsOfDirectoryAtPath:path error:NULL];
    NSMutableArray *fileModels = [[NSMutableArray alloc]initWithCapacity:filesArray.count];
    for(NSString * fileName in filesArray){
        NSString *fullPath = [path stringByAppendingFormat:@"/%@", fileName];
        [fileModels addObject:[self createModelFromPath:fullPath]];
    }
    return fileModels;
}

- (FileModel *)createModelFromPath:(NSString *)path {
    FileModel *model = [FileModel new];
    model.name = [path lastPathComponent];
    model.path = path;
    NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
    [model fillWithDictionary:attrs];
    return model;
}
@end
