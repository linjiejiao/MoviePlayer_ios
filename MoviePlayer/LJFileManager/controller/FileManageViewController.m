//
//  FileSelectViewController.m
//  MoviePlayer
//
//  Created by liangjiajian_mac on 16/7/29.
//  Copyright © 2016年 cn.ljj. All rights reserved.
//

#import "FileManageViewController.h"
#import "FileTableViewCell.h"
#import "FileModel.h"
#import "SandBoxFileManager.h"

#define MARGIN_HORIZON  15
#define HEADER_HEIGHT   40

@interface FileManageViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UINavigationItem *titleItem;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray<FileModel*> *fileList;
@property (copy, nonatomic) NSString *currentPath;
@property (strong, nonatomic) UILabel *currentPathLabel;

@end

@implementation FileManageViewController

- (IBAction)onBackClicked:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        if(self.delegate) {
            [self.delegate cancelSelecte];
        }
    }];
}

- (void)dissmissWithSelectedFile:(FileModel *)file {
    [self dismissViewControllerAnimated:YES completion:^{
        if(self.delegate) {
            [self.delegate didSelectFiles:file];
        }
    }];
}

#pragma  mark - override
- (instancetype)init {
    self = [super initWithNibName:@"FileManageViewController" bundle:nil];
    if(self){
        self.fileList = [NSMutableArray new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[FileTableViewCell cellNib] forCellReuseIdentifier:[FileTableViewCell cellId]];
    self.tableView.rowHeight = [FileTableViewCell cellHeight];
    if(self.topTitle){
        self.titleItem.title = self.topTitle;
    }
    self.currentPath = NSHomeDirectory();
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setTopTitle:(NSString *)title {
    _topTitle = title;
    if(self.titleItem) {
        self.titleItem.title = title;
    }
}

#pragma mark - UITableViewDelegate & UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.fileList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[FileTableViewCell cellId]];
    FileModel *model = [self.fileList objectAtIndex:indexPath.row];
    cell.selectMode = tableView.editing;
    [cell setModel:model];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    FileModel *model = [self.fileList objectAtIndex:indexPath.row];
    switch(model.type) {
        case TypeSuperDirectory:
        case TypeDirectory: {
            self.currentPath = model.path;
        }break;
        case TypeFile: {
            [self dissmissWithSelectedFile:model];
        }break;
        default:
            NSLog(@"unknown model:%@", model);
            break;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header = [[UIView alloc]init];
    CGFloat screenWidth = [[UIScreen mainScreen]bounds].size.width;
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(MARGIN_HORIZON, 5, screenWidth - 2*MARGIN_HORIZON, HEADER_HEIGHT - 10)];
    label.numberOfLines = 2;
    label.font = [UIFont systemFontOfSize:12];
    label.lineBreakMode = NSLineBreakByTruncatingHead;
    label.text = self.currentPath;
    self.currentPathLabel = label;
    [header addSubview:label];
    return header;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return HEADER_HEIGHT;
}

#pragma mark - other methods

- (void)setCurrentPath:(NSString *)currentPath {
    if(self.currentPathLabel) {
        self.currentPathLabel.text = currentPath;
    }
    _currentPath = currentPath;
    [self.fileList removeAllObjects];
    if(![self isHomeRoot]){
        FileModel *model = [FileModel new];
        model.type = TypeSuperDirectory;
        model.path = [self.currentPath stringByDeletingLastPathComponent];
        [self.fileList addObject:model];
    }
    [self.fileList addObjectsFromArray:[self getData]];
    [self.tableView reloadData];
}

- (NSArray *)getData {
    NSMutableArray *array = [NSMutableArray new];
    NSArray *original = [[SandBoxFileManager sharedInstance] getFilesUnderPath:self.currentPath];
    id<FilesSelectDelegate> delegate = self.delegate;
    if(delegate && [delegate respondsToSelector:@selector(filterFiles:)]){
        for (FileModel *model in original){
            if(![delegate filterFiles:model]){
                continue;
            }
            [array addObject:model];
        }
    }else{
        return original;
    }
    return array;
}

- (BOOL)isHomeRoot {
    return [NSHomeDirectory() isEqualToString:self.currentPath];
}

@end
