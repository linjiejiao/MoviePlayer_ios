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
#import "FilesListHeaderView.h"

#define MARGIN_HORIZON      15

@interface FileManageViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UINavigationItem *titleItem;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray<FileModel*> *fileList;
@property (copy, nonatomic) NSString *currentPath;
@property (strong, nonatomic) UILabel *currentPathLabel;
@property (weak, nonatomic) IBOutlet UIToolbar *bottomToolBar;
@property (strong, nonatomic) FilesListHeaderView *header;

@property (strong, nonatomic) NSMutableArray<FileModel *> *selectedFiles;

@end

@implementation FileManageViewController

- (IBAction)onEditClicked:(UIBarButtonItem *)sender {
    self.bottomToolBar.hidden = !self.bottomToolBar.hidden;
    if(self.bottomToolBar.hidden){
        self.tableView.editing = NO;
        [self.selectedFiles removeAllObjects];
    }else{
        self.tableView.editing = YES;
    }
    [self.tableView reloadData];
}

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

- (IBAction)onRenameClicked:(UIBarButtonItem *)sender {
}

- (IBAction)onDeleteClicked:(UIBarButtonItem *)sender {
    @synchronized (self.selectedFiles) {
        for(FileModel *model in self.selectedFiles){
            [self deleteFile:model];
        }
        [self.selectedFiles removeAllObjects];
        [self refreshList];
    }
}

- (IBAction)onMoreClicked:(UIBarButtonItem *)sender {
}

- (void)onBackFolder {
    self.currentPath = [self.currentPath stringByDeletingLastPathComponent];
}

#pragma  mark - override
- (instancetype)init {
    self = [super initWithNibName:@"FileManageViewController" bundle:nil];
    if(self){
        self.fileList = [NSMutableArray new];
        self.selectedFiles = [NSMutableArray new];
    }
    return self;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
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
    cell.selected = [self.selectedFiles containsObject:model];
    [cell setModel:model];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FileModel *model = [self.fileList objectAtIndex:indexPath.row];
    if(!tableView.editing){
        switch(model.type) {
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
    }else{
        @synchronized (self.selectedFiles) {
            [self.selectedFiles addObject:model];
        }
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    FileModel *model = [self.fileList objectAtIndex:indexPath.row];
    if(!tableView.editing){
    }else{
        @synchronized (self.selectedFiles) {
            [self.selectedFiles removeObject:model];
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if(!self.header){
        self.header = [FilesListHeaderView newView];
        self.currentPathLabel = self.header.pathLabel;
        self.currentPathLabel.text = [self getSimplifyPath:self.currentPath];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onBackFolder)];
        [self.header.backFolderView addGestureRecognizer:tap];
    }else{
        [self.header removeFromSuperview];
    }
    [self.header setBackFolderViewVisible:!([self isHomeRoot] || tableView.isEditing)];
    return self.header;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if([self isHomeRoot] || tableView.editing){
        return CURRENT_PATH_HEIGHT;
    }else{
        return CURRENT_PATH_HEIGHT + BACK_PATH_HEIGHT;
    }
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete | UITableViewCellEditingStyleInsert;
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
}

#pragma mark - other methods

- (void)setCurrentPath:(NSString *)currentPath {
    if(self.currentPathLabel) {
        self.currentPathLabel.text = [self getSimplifyPath:currentPath];
    }
    _currentPath = currentPath;
    [self refreshList];
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

- (NSString *)getSimplifyPath:(NSString *)fullPath {
    NSString *simplify = [fullPath stringByReplacingOccurrencesOfString:NSHomeDirectory() withString:@"HOME"];
    return simplify;
}

- (void)deleteFile:(FileModel *)file {
    NSError *error;
    [[NSFileManager defaultManager] removeItemAtPath:file.path error:&error];
    if(error) {
        NSLog(@"deleteFile:%@ got error:%@", file, error);
    }
}

- (void)refreshList {
    [self.fileList removeAllObjects];
    [self.fileList addObjectsFromArray:[self getData]];
    [self.tableView reloadData];
}

@end
