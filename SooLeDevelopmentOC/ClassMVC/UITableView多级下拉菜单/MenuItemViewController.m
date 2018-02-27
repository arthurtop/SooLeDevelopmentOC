//
//  MenuItemViewController.m
//  SooLeDevelopmentOC
//
//  Created by songlei on 2018/1/29.
//  Copyright © 2018年 songlei. All rights reserved.
//

#import "MenuItemViewController.h"
#import "MenuItem.h"
#import "MenuItemCell.h"
#import "UIView+Extension.h"
#import <MJExtension.h>


@interface MenuItemViewController ()<MenuItemCellDetegate>

@property (nonatomic, strong) NSMutableArray<MenuItem *> *menuItems;

@property (nonatomic, strong) NSMutableArray<MenuItem *> *lastShowMenuItems;

@property (nonatomic, strong) NSMutableArray<MenuItem *> *oldShowMenuItems;

@property (nonatomic, strong) NSMutableArray<MenuItem *> *selectMenuItems;

@property (nonatomic, strong) UIButton *allBtn;


@end

@implementation MenuItemViewController

static NSString *menuItemId = @"MenuItemCell";


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
    
}

#pragma mark- xlz 设置
- (void)setup{
    self.title = @"多级菜单";
    
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"a" ofType:@"plist"];
    
    NSArray *date = [NSArray arrayWithContentsOfFile:filePath];
    
    self.menuItems = [MenuItem mj_objectArrayWithKeyValuesArray:date];
    
    UIButton *allBtn = [[UIButton alloc] init];
    [allBtn setTitle:@"全选" forState:(UIControlStateNormal)];
    [allBtn setTitle:@"反选" forState:(UIControlStateSelected)];
    [allBtn setTitleColor:[UIColor blueColor] forState:(UIControlStateNormal)];
    [allBtn sizeToFit];
    allBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [allBtn addTarget:self action:@selector(allBtnClick:) forControlEvents:(UIControlEventTouchUpInside)];
    self.allBtn = allBtn;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:allBtn];
    
    
    UIButton *btn = [[UIButton alloc] init];
    [btn setTitle:@"打印已选" forState:(UIControlStateNormal)];
    [btn setTitleColor:[UIColor blueColor] forState:(UIControlStateNormal)];
    [btn sizeToFit];
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    [btn addTarget:self action:@selector(printSelectedMenuItems:) forControlEvents:(UIControlEventTouchUpInside)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    [self setupRowCount];
    
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    self.tableView.rowHeight = 45;
    [self.tableView registerClass:[MenuItemCell class] forCellReuseIdentifier:menuItemId];
    
}


#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.lastShowMenuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MenuItemCell *cell = [tableView dequeueReusableCellWithIdentifier:menuItemId forIndexPath:indexPath];
    cell.menuItem = self.lastShowMenuItems[indexPath.row];
    cell.delegate = self;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MenuItem *menuItem = self.lastShowMenuItems[indexPath.row];
    if (!menuItem.isCanUnfold) return;
    
    self.oldShowMenuItems = [NSMutableArray arrayWithArray:self.lastShowMenuItems];
    
    // 设置展开闭合
    menuItem.isUnfold = !menuItem.isUnfold;
    // 更新被点击cell的箭头指向
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:(UITableViewRowAnimationAutomatic)];
    
    // 设置需要展开的新数据
    [self setupRowCount];
    
    // 判断老数据和新数据的数量, 来进行展开和闭合动画
    // 定义一个数组, 用于存放需要展开闭合的indexPath
    NSMutableArray<NSIndexPath *> *indexPaths = @[].mutableCopy;
    
    // 如果 老数据 比 新数据 多, 那么就需要进行闭合操作
    if (self.oldShowMenuItems.count > self.lastShowMenuItems.count) {
        // 遍历oldShowMenuItems, 找出多余的老数据对应的indexPath
        for (int i = 0; i < self.oldShowMenuItems.count; i++) {
            // 当新数据中 没有对应的item时
            if (![self.lastShowMenuItems containsObject:self.oldShowMenuItems[i]]) {
                NSIndexPath *subIndexPath = [NSIndexPath indexPathForRow:i inSection:indexPath.section];
                [indexPaths addObject:subIndexPath];
            }
        }
        // 移除找到的多余indexPath
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:(UITableViewRowAnimationTop)];
    }else {
        // 此时 新数据 比 老数据 多, 进行展开操作
        // 遍历 latestShowMenuItems, 找出 oldShowMenuItems 中没有的选项, 就是需要新增的indexPath
        for (int i = 0; i < self.lastShowMenuItems.count; i++) {
            if (![self.oldShowMenuItems containsObject:self.lastShowMenuItems[i]]) {
                NSIndexPath *subIndexPath = [NSIndexPath indexPathForRow:i inSection:indexPath.section];
                [indexPaths addObject:subIndexPath];
            }
        }
        // 插入找到新添加的indexPath
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:(UITableViewRowAnimationTop)];
    }
}


- (void)cell:(MenuItemCell *)cell didSelectedBtn:(UIButton *)sender{
    cell.menuItem.isSelected = !cell.menuItem.isSelected;
    // 修改按钮状态
    self.allBtn.selected = NO;
    [self.tableView reloadData];
}

#pragma mark- xlz 点击事件
- (void)allBtnClick:(UIButton *)btn{
    btn.selected = !btn.selected;
    
    [self selected:btn.selected menuItems:self.menuItems];
    
}
/**
 取消或选择, 某一数值中所有的选项, 包括子层级
 @param selected 是否选中
*/
- (void)selected:(BOOL)selected menuItems:(NSArray<MenuItem *> *)menuitems{
    for (int i = 0; i < menuitems.count; i++) {
        MenuItem *menuItem = menuitems[i];
        menuItem.isSelected = selected;
        if (menuItem.isCanUnfold) {
            [self selected:selected menuItems:menuItem.subsArr];
        }
    }
    [self.tableView reloadData];
}

- (void)printSelectedMenuItems:(UIButton *)btn{
    [self.selectMenuItems removeAllObjects];
    [self departmentsWithMenuItems:self.menuItems];
    
}

/**
 获取选中数据
 */
- (void)departmentsWithMenuItems:(NSArray<MenuItem *> *)menuItems
{
    for (int i = 0; i < menuItems.count; i++) {
        MenuItem *menuItem = menuItems[i];
        if (menuItem.isSelected) {
            [self.selectMenuItems addObject:menuItem];
        }
        if (menuItem.subsArr.count) {
            [self departmentsWithMenuItems:menuItem.subsArr];
        }
    }
}

#pragma mark - < 添加可以展示的选项 >

- (void)setupRowCount
{
    // 清空当前所有展示项
    [self.lastShowMenuItems removeAllObjects];
    
    // 重新添加需要展示项, 并设置层级, 初始化0
    [self setupRouCountWithMenuItems:self.menuItems index:0];
}

/**
 将需要展示的选项添加到latestShowMenuItems中, 此方法使用递归添加所有需要展示的层级到latestShowMenuItems中
 @param menuItems 需要添加到latestShowMenuItems中的数据
 @param index 层级, 即当前添加的数据属于第几层
 */
- (void)setupRouCountWithMenuItems:(NSArray<MenuItem *> *)menuItems index:(NSInteger)index
{
    for (int i = 0; i < menuItems.count; i++) {
        MenuItem *item = menuItems[i];
        // 设置层级
        item.index = index;
        // 将选项添加到数组中
        [self.lastShowMenuItems addObject:item];
        // 判断该选项的是否能展开, 并且已经需要展开
        if (item.isCanUnfold && item.isUnfold) {
            // 当需要展开子集的时候, 添加子集到数组, 并设置子集层级
            [self setupRouCountWithMenuItems:item.subsArr index:index + 1];
        }
    }
}


#pragma mark- xlz 懒加载
- (NSMutableArray<MenuItem *> *)menuItems{
    if (!_menuItems) {
        self.menuItems = [[NSMutableArray  alloc]init];
    }
    return _menuItems;
}


- (NSMutableArray<MenuItem *> *)lastShowMenuItems{
    if (!_lastShowMenuItems) {
        self.lastShowMenuItems = [[NSMutableArray alloc]init];
    }
    return _lastShowMenuItems;
}

- (NSMutableArray<MenuItem *> *)oldShowMenuItems{
    if (!_oldShowMenuItems) {
        self.oldShowMenuItems = [[NSMutableArray alloc]init];
    }
    return _oldShowMenuItems;
}

- (NSMutableArray<MenuItem *> *)selectMenuItems{
    if (!_selectMenuItems) {
        self.selectMenuItems = [[NSMutableArray  alloc]init];
    }
    return _selectMenuItems;
}



@end
