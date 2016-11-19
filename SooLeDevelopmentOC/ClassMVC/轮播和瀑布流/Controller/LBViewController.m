//
//  LBViewController.m
//  SooLeDevelopmentOC
//
//  Created by songlei on 2016/10/29.
//  Copyright © 2016年 songlei. All rights reserved.
//

#import "LBViewController.h"


#define tableViewCell @"tableViewCell"


@interface LBViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSArray *titleArr;
}
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation LBViewController

- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:tableViewCell];
        
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    titleArr = @[@"无线轮播",@"瀑布流"];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:_tableView];
    
    
    
    
}


#pragma mark- datasource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifiCell =  tableViewCell;
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifiCell forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifiCell];
    }
    cell.textLabel.text = titleArr[indexPath.item];
    
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return titleArr.count;
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





@end
