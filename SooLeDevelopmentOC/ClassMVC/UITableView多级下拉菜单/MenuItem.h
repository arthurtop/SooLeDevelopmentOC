//
//  MenuItem.h
//  SooLeDevelopmentOC
//
//  Created by songlei on 2018/1/29.
//  Copyright © 2018年 songlei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MenuItem : NSObject

/// ------- 名字
@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong) NSArray<MenuItem *> *subsArr;


@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) BOOL isUnfold;
@property (nonatomic, assign) BOOL isCanUnfold;
@property (nonatomic, assign) NSInteger index;

@end
