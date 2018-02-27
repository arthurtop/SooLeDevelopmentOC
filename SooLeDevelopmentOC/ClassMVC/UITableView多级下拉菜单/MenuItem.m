//
//  MenuItem.m
//  SooLeDevelopmentOC
//
//  Created by songlei on 2018/1/29.
//  Copyright © 2018年 songlei. All rights reserved.
//

#import "MenuItem.h"
#import <MJExtension.h>

@implementation MenuItem

+ (NSDictionary *)mj_objectClassInArray{
    return @{@"subsArr":[MenuItem class]};
}

- (BOOL)isCanUnfold{
    return self.subsArr.count > 0;
}


@end
