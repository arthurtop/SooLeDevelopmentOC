//
//  LoveViewController.m
//  SooLeDevelopmentOC
//
//  Created by songlei on 2018/2/8.
//  Copyright © 2018年 songlei. All rights reserved.
//

#import "LoveViewController.h"
#import "StarsView.h"


@interface LoveViewController ()

@property (nonatomic, assign) CGFloat number;
@property (nonatomic, strong) UIView *bgView;


@end

@implementation LoveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage *maskImage = [UIImage imageNamed:@"btn_link_fill"];
    UIImage *lineImage = [UIImage imageNamed:@"btn_link_line"];
    
    StarsView *starView = [[StarsView alloc] init];
    starView.frame = CGRectMake(100, 100, maskImage.size.width, maskImage.size.height);
    starView.maskImage = maskImage;
    starView.borderIamge = lineImage;
    starView.fillColor = [UIColor colorWithRed:0.94 green:0.27 blue:0.32 alpha:1];
    [self.view addSubview:starView];
    
    
    
    
    
}







@end



