//
//  TouchIDHelper.h
//  SooLeDevelopmentOC
//
//  Created by jecansoft on 16/10/21.
//  Copyright © 2016年 songlei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TouchIDHelper : NSObject<NSCopying, NSMutableCopying>

@property (nonatomic, assign) BOOL isAppCurrentLoginState;


+ (instancetype)shareHelper;



@end
