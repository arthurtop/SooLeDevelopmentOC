//
//  MenuItemCell.h
//  SooLeDevelopmentOC
//
//  Created by songlei on 2018/1/29.
//  Copyright © 2018年 songlei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuItem.h"
@class MenuItemCell;

@protocol MenuItemCellDetegate <NSObject>

- (void)cell:(MenuItemCell *)cell didSelectedBtn:(UIButton *)sender;

@end


@interface MenuItemCell : UITableViewCell

@property (nonatomic, strong) MenuItem *menuItem;

@property (nonatomic, weak) id<MenuItemCellDetegate> delegate;

@end
