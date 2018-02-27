//
//  XLZBuleToothManger.m
//  SooLeDevelopmentOC
//
//  Created by songlei on 2017/1/16.
//  Copyright © 2017年 songlei. All rights reserved.
//

#import "XLZBuleToothManger.h"


@interface XLZBuleToothManger()<CBCentralManagerDelegate, CBPeripheralDelegate>{
    BOOL isOpenBLE;   ///是否开启蓝牙
    int countDown;    ///倒计时
    
}

@property (nonatomic, strong) CBCentralManager *cbCentMananger;

@property (nonatomic, strong) NSString *identify;

@property (nonatomic, strong) NSTimer *timer;  ////连接超时



@end

@implementation XLZBuleToothManger

+ (XLZBuleToothManger *)sharedInstance{
    static XLZBuleToothManger *deviceManger;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
       
        deviceManger = [[XLZBuleToothManger alloc]init];
        
    });
    return deviceManger;
}


- (void)initDevice{
    countDown = 0;
    if (!_cbCentMananger) {
        _cbCentMananger = [[CBCentralManager alloc]initWithDelegate:self queue:nil options:nil];
    }
}

///扫描设备
- (void)scan{
    NSUserDefaults *userDeault = [NSUserDefaults standardUserDefaults];
    NSString *uuidString = [userDeault objectForKey:ST_SERVICE_UUID];
    NSArray *peripherals;
    if (uuidString) {
        //如果绑定过设备，就用绑定的标示uuid进行扫描
        NSUUID *uuid = [[NSUUID alloc]init];
        peripherals = [self.cbCentMananger retrievePeripheralsWithIdentifiers:@[uuid]];
    }else{
        //如果未绑定过设置，通过serviceUUID进行扫描
        peripherals = [self.cbCentMananger retrieveConnectedPeripheralsWithServices:@[[CBUUID UUIDWithString:ST_SERVICE_UUID]]];
    }
    
    if (peripherals > 0) {
        
        CBPeripheral *peripheral = [peripherals firstObject];
        peripheral.delegate = self;
        self.peripheral = peripheral;
        
        [self.cbCentMananger connectPeripheral:self.peripheral options:nil];
    }
    
    if (!self.timer) {
        countDown = 8;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(connectOverrun) userInfo:nil repeats:YES];
    }
    
    
    
}

///停止扫描
- (void)stopScan{
    [self.cbCentMananger stopScan];
    [self.timer invalidate];
    self.timer = nil;
    
}

///连接设备
- (void)connect:(NSString *)identify{
    if (isOpenBLE) {
        self.identify = identify;
        [self.cbCentMananger scanForPeripheralsWithServices:nil options:nil];
        if (!self.timer) {
            countDown = 8;
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(connectOverrun) userInfo:nil repeats:YES];
        }
    }
}

///断开连接
- (void)disconnect{
    if(self.cbCentMananger && self.peripheral) {
        [self.cbCentMananger cancelPeripheralConnection:self.peripheral];
        
        if ([self.delegate respondsToSelector:@selector(onConnectBreak)]) {
            [self.delegate onConnectBreak];
        }
    }
}


///超时连接
- (void)connectOverrun{
    countDown -= 1;
    if (countDown == 0) {
        [self.timer invalidate];
        self.timer = nil;
        [self.cbCentMananger stopScan];
        if ([self.delegate respondsToSelector:@selector(onScanNotFound)]) {
            [self.delegate onScanNotFound];
        }
    }
}


///更新蓝牙状态
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    if (central.state == CBCentralManagerStatePoweredOn) {
        isOpenBLE = YES;
    } else if (central.state == CBCentralManagerStatePoweredOff){
        
        [[NSNotificationCenter defaultCenter]postNotificationName:@"ConnectState" object:@"蓝牙关闭"];
    }else{
        NSLog(@"---蓝牙未打开!");
    }
}


///获取设备版本号
- (void)getVersion{
    NSData *data = [self hexToBytes:@"088573"];
    
    if (self.write) {
        [self.peripheral writeValue:data forCharacteristic:self.write type:CBCharacteristicWriteWithoutResponse];
    }
    
    
}

///获取电量
- (void)getBattery{
    NSData *data = [self hexToBytes:@"88096F"];
    if (self.write) {
        [self.peripheral writeValue:data forCharacteristic:self.write type:CBCharacteristicWriteWithoutResponse];
    }
    
}



#pragma mark- xlz CBcentralMangerDelegate
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI{
    
    NSLog(@"%@", [peripheral.identifier UUIDString]);
    //筛选设备名，换成自己的设备名称
    if([peripheral.name rangeOfString:@"MI"].location != NSNotFound){
        NSLog(@"didDiscoverPeripheral");
        
        if (self.identify) {
            if ([[peripheral.identifier UUIDString] isEqualToString:self.identify]) {
                [self.cbCentMananger connectPeripheral:peripheral options:nil];
                NSLog(@"成功连接设备");
                
                self.peripheral = peripheral;
                [self.timer invalidate];
                self.timer = nil;
            }
        } else {
            NSUUID *uuid = peripheral.identifier;
            NSLog(@"%@",peripheral.name);
            if ([self.delegate respondsToSelector:@selector(deviceIdentifier:)]) {
                [self.delegate deviceIdentifier:[uuid UUIDString]];
            }
            
            [self.cbCentMananger stopScan];
            if ([self.delegate respondsToSelector:@selector(onScanStop)]) {
                [self.delegate onScanStop];
            }
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"Failed to connnet peripheral %@ (%@)", peripheral, error);
    if ([self.delegate respondsToSelector:@selector(onConnectFailed)]) {
        [self.delegate onConnectFailed];
    }
    
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    
    if ([self.delegate respondsToSelector:@selector(onConnectBreak)]) {
        [self.delegate onConnectBreak];
    }
}

////链接成功
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    NSLog(@"didConnectPeripheral");
    if ([self.delegate respondsToSelector:@selector(onConnected)]) {
        [self.delegate onConnected];
    }
    [self.cbCentMananger stopScan];
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
    NSString *uuid =[peripheral.identifier UUIDString];
    //存储字段
    [[NSUserDefaults standardUserDefaults] setObject:uuid forKey:ST_DEVICEIDENTIFI_ID];
    
}


#pragma mark- xlz peripheral delegate
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    if (!error) {
        for (CBService *service in peripheral.services) {
            
            if ([service.UUID.UUIDString isEqualToString:ST_SERVICE_UUID]) {
                [self.peripheral discoverCharacteristics:@[service.characteristics] forService:service];
                
                
            }
        }
    }
    
}

//发现characteristics，由发现服务调用（上一步），获取读和写的characteristics
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    
    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([characteristic.UUID.UUIDString isEqualToString:ST_CHARACTERISTIC_UUID_READ]) {
            self.read = characteristic;
            [self.peripheral setNotifyValue:YES forCharacteristic:self.read];
        }else{
            self.write = characteristic;
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error{
    if (error) {
        [self.cbCentMananger cancelPeripheralConnection:peripheral];
        return;
    }
}

///是否写入成功代理
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    
    if (error) {
        NSLog(@"%@", error);
    }
}

//数据接收
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if ([characteristic.UUID.UUIDString isEqualToString:ST_CHARACTERISTIC_UUID_READ]) {
        NSData *data = characteristic.value;
        NSLog(@"设备返回码：%@",data);
        
        //根据硬件协议进行解析
        
        NSData *cmdData = [data subdataWithRange:NSMakeRange(0, 2)];
        if ([cmdData isEqualToData:[self hexToBytes:CMD_SEND_BATTERYLEVEL_REMIND]]) {
            //设备电量
            unsigned char *bs = (unsigned char *)[[data subdataWithRange:NSMakeRange(2, 1)] bytes];
            unsigned int w1 = *bs;
            if ([self.delegate respondsToSelector:@selector(onGetBattery:)]) {
                [self.delegate onGetBattery:w1*20];
            }
            
            
        }else if ([cmdData isEqualToData:[self hexToBytes:CMD_SW_REV_INFO]]){
            //设备版本
            unsigned char *bs = (unsigned char *)[[data subdataWithRange:NSMakeRange(2, 1)] bytes];
            unsigned int w1 = *bs;
            int version = [[self toHex:w1] intValue];
            if ([self.delegate respondsToSelector:@selector(onGetVersion:)]) {
                [self.delegate onGetVersion:[NSString stringWithFormat:@"v%d.%d",version/10,version%10]];
            }
            
        }
        
    }
    
    
}



#pragma mark- xlz 其他配置
////字符串转data
- (NSData *)hexToBytes:(NSString *)str{
    NSMutableData *data = [NSMutableData data];
    int idx;
    for (idx = 0; idx + 2 <= str.length; idx+=2) {
        NSRange range = NSMakeRange(idx, 0);
        NSString *hexStr = [str substringWithRange:range];
        NSScanner *scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}

//将十进制转化为十六进制
- (NSString *)toHex:(int)tmpid{
    NSString *nLetterValue;
    NSString *str = @"";
    int ttmpig;
    for (int i = 0; i<9; i++) {
        ttmpig = tmpid % 16;
        ttmpig = tmpid / 16;
        switch (ttmpig) {
            case 10:
                nLetterValue = @"A";
                break;
            case 11:
                nLetterValue = @"B";
                break;
            case 12:
                nLetterValue = @"C";
                break;
            case 13:
                nLetterValue = @"D";
                break;
            case 14:
                nLetterValue = @"E";
                break;
            case 15:
                nLetterValue = @"F";
                break;
            default:
                nLetterValue = [NSString stringWithFormat:@"%lu",ttmpig];
                break;
        }
        str = [nLetterValue stringByAppendingString:str];
        if (tmpid == 0) {
            break;
        }
    }
    if (str.length == 1) {
        return [NSString stringWithFormat:@"0%@",str];
    }else{
        return str;
    }
    
}








@end
