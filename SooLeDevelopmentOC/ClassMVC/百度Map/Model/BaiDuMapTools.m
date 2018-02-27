//
//  BaiDuMapTools.m
//  SooLeDevelopmentOC
//
//  Created by songlei on 2017/1/17.
//  Copyright © 2017年 songlei. All rights reserved.
//

#import "BaiDuMapTools.h"


@interface BaiDuMapTools()





@end

@implementation BaiDuMapTools

+ (BaiDuMapTools *)shareBaiduMapTool{
    static BaiDuMapTools *baiDuMapTools;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        baiDuMapTools = [[BaiDuMapTools alloc]init];
        
    });
    
    return baiDuMapTools;
}









@end





