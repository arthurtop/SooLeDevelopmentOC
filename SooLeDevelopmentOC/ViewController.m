//
//  ViewController.m
//  SooLeDevelopmentOC
//
//  Created by jecansoft on 16/10/12.
//  Copyright © 2016年 songlei. All rights reserved.
//

#import "ViewController.h"
#import "PYSearch.h"
#import "LBViewController.h"
#import "WordChangeSpeech.h"



#define TableViewCellID @"TableViewCellID"



@interface ViewController ()<UITableViewDelegate,UITableViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate,PYSearchViewControllerDelegate>


@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *titleArr;
@property (nonatomic, strong) NSArray *ctlNameArr;


@end

@implementation ViewController

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:TableViewCellID];
    }
    return _tableView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleArr = @[@"搜索功能",@"无线轮播和瀑布流",@"文字报语音"];
    
    
    
    
    
    [self.view addSubview:self.tableView];
    
   
    
    
}




#pragma mark- datasoure
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _titleArr.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = TableViewCellID;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    cell.textLabel.text = _titleArr[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger index = indexPath.item;
    switch (index) {
        case 0:
            [self didSeclectedPYSearch];
            break;
        case 1:
            [self limitCollectionView];
            break;
            
        case 2:
            [self AVVoide];
            break;
            
        case 3:
            
            break;
            
            
        default:
            break;
    }
    
}


#pragma mark- PY 搜索栏  和代理
- (void)didSeclectedPYSearch{
    
    NSArray *hotSearch = @[@"Java",@"objective-c",@"swift",@"c"];
    
    PYSearchViewController *searchCtl = [PYSearchViewController searchViewControllerWithHotSearches:hotSearch searchBarPlaceholder:@"搜索编辑语言" didSearchBlock:^(PYSearchViewController *searchViewController, UISearchBar *searchBar, NSString *searchText) {
        
        searchCtl.searchResultController.title = @"PYsearchResult";
        
    }];
    
    searchCtl.delegate = self;
    searchCtl.searchHistoryStyle = PYSearchHistoryStyleDefault;
    searchCtl.hotSearchStyle = PYHotSearchStyleDefault;
    
    UINavigationController *navCtl = [[UINavigationController alloc]initWithRootViewController:searchCtl];
    navCtl.navigationBar.barTintColor = [UIColor redColor];
    
    [self presentViewController:navCtl animated:YES completion:nil];
    
}

/** 搜索框文本变化时，显示的搜索建议通过searchViewController的searchSuggestions赋值即可 */
- (void)searchViewController:(PYSearchViewController *)searchViewController searchTextDidChange:(UISearchBar *)seachBar searchText:(NSString *)searchText{
    
    
}


#pragma mark- 无线轮播  瀑布流
- (void)limitCollectionView{
    
    LBViewController *lbCtl = [[LBViewController alloc]init];
    
    [self.navigationController pushViewController:lbCtl animated:YES];
    
}

#pragma mark- 语音播报
- (void)AVVoide{
    
    WordChangeSpeech *speech = [[WordChangeSpeech alloc]init];
    
    [speech read:@"大兄弟你好啊哈哈哈"];
    
}





#pragma mark- imagePickerController
- (void)test:(UIButton *)btn{
    
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.delegate = self;
    //picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.allowsEditing = YES;
    
    [self presentViewController:picker animated:YES completion:nil];
    
}

// 改变图像的尺寸，方便上传服务器
- (UIImage *) scaleFromImage: (UIImage *) image toSize: (CGSize) size
{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    
    //定义一个newPhoto，用来存放我们选择的图片。
    UIImage *newPhoto = [info objectForKey:@"UIImagePickerControllerEditedImage"];
    
    //    NSLog(@"保存头像！");
    //    [userPhotoButton setImage:image forState:UIControlStateNormal];
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imageFilePath = [documentsDirectory stringByAppendingPathComponent:@"logo1.png"];
    NSLog(@"imageFile->>%@",imageFilePath);
    success = [fileManager fileExistsAtPath:imageFilePath];
    if(success) {
        success = [fileManager removeItemAtPath:imageFilePath error:&error];
    }
    
    UIImage *smallImage=[self scaleFromImage:newPhoto toSize:CGSizeMake(80.0f, 80.0f)];//将图片尺寸改为80*80
    BOOL isWrite = [UIImageJPEGRepresentation(smallImage, 1.0f) writeToFile:imageFilePath atomically:YES];//写入文件
    if (isWrite) {
        NSLog(@"写入成功");
    }else{
        NSLog(@"写入失败");
    }
    
    UIImage *selfPhoto = [UIImage imageWithContentsOfFile:imageFilePath];//读取图片文件
    
    //_imageeVIew.image = selfPhoto;
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
