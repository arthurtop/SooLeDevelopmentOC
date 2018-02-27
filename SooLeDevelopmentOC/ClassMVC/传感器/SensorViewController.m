//
//  SensorViewController.m
//  SooLeDevelopmentOC
//
//  Created by songlei on 2018/1/9.
//  Copyright © 2018年 songlei. All rights reserved.
//

#import "SensorViewController.h"
#import <CoreMotion/CoreMotion.h>


@interface SensorViewController ()

@property (nonatomic, strong) CMMotionManager *manager;
@property (nonatomic, strong) UIImageView *imgView;

@end

@implementation SensorViewController

#pragma mark- xlz 懒加载
- (CMMotionManager *)manager{
    if (!_manager) {
        _manager = [[CMMotionManager alloc]init];
    }
    return _manager;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.imgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"IMG_1041.JPG"]];
    self.imgView.frame = CGRectMake(60, 100, 200, 200);
    [self.view addSubview:self.imgView];
    
//    self.imgView add
    
    [self keepBalance];
    
    
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self useAccelerometerPull];
    if (self.manager.accelerometerActive) {
        [self.manager stopAccelerometerUpdates];
        
    }
    
    
}

#pragma mark- xlz 让图片保持水平
- (void)keepBalance{
    if (self.manager.accelerometerAvailable) {
        
        self.manager.accelerometerUpdateInterval = 0.01f;
        [self.manager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
            
            double rotation = atan2(accelerometerData.acceleration.x, accelerometerData.acceleration.y) - M_PI;
            
            self.imgView.transform = CGAffineTransformMakeRotation(rotation);
        }];
        
    }
}


#pragma mark- xlz 加速器的两种获取方法 PUSH & PULL
- (void)useAccelerometerPull{
    
    if (self.manager.accelerometerAvailable) {
        
        self.manager.accelerometerUpdateInterval = 0.1;
        [self.manager startAccelerometerUpdates];
        
    }
    
    //获取并处理加速度计数据。这里我们就只是简单的做了打印。
    NSLog(@"X = %f,Y = %f,Z = %f",self.manager.accelerometerData.acceleration.x,self.manager.accelerometerData.acceleration.y,self.manager.accelerometerData.acceleration.z);
}

- (void)useAccelerometerPush{
    if (self.manager.accelerometerAvailable) {
        self.manager.accelerometerUpdateInterval = 0.1;
        
        [self.manager startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData * _Nullable accelerometerData, NSError * _Nullable error) {
            NSLog(@"X = %f,Y = %f,Z = %f",self.manager.accelerometerData.acceleration.x,self.manager.accelerometerData.acceleration.y,self.manager.accelerometerData.acceleration.z);
        }];
    }else{
        
        NSLog(@"不可用...");
    }
    
}





@end
