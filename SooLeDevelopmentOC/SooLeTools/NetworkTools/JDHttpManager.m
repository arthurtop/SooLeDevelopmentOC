//
//  WLHttpManager.m
//  WeiLv
//
//  Created by James on 16/5/12.
//  Copyright © 2016年 WeiLv Technology. All rights reserved.
//

#import "JDHttpManager.h"
@implementation JDHttpManager

#pragma mark - 创建单例方法
+ (instancetype)shareManager
{
    static JDHttpManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[JDHttpManager alloc]init];
    });
    return manager;
}

#pragma mark - 第三方AFNetWorking请求接口
/**
 *  第三方AFNetWorking请求接口
 *  @param URLString  请求的URL
 *  @param parameters      登录需要传的参数   字典形式，若为Get请求可传空
 *  @param type       请求方式(GET,POST)
 *  @param success    成功回调,id对象 自行转换数组或字典
 *  @param failure    失败回调,返回NSError对象
 */
- (void)requestWithURL:(NSString*)URLString RequestType:(RequestType )type Parameters:(NSDictionary*)parameters Success:(void(^)(id responseObject))success Failure:(void(^)(NSError *error))failure{
    
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer.acceptableContentTypes  =  [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/plain",@"application/xml", nil];
    
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
  
    if (type == RequestTypeGet)
    {
        [manager GET:URLString parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
        {
            if (success)
            {
                success(responseObject);
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
        {
            //失败error也通过block传出
            if (failure)
            {
                failure(error);
            }
        }];
    }
    else
    {
        [manager POST:URLString parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData)
        {
            
        } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
        {
            if (success)
            {
                
                success(responseObject);
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
        {
            if (failure)
            {
                failure(error);
            }
        }];
    }
}

#pragma mark - 系统自带Get请求接口
/**
 *  系统自带Get请求接口
 *  @param path  请求的URL
 *  @param params      登录需要传的参数   字典形式，若为Get请求可传空
 *  @param callback    成功回调,id对象 自行转换数组或字典
 *  @param failure     失败回调,返回NSError对象
 */
-(void)getddByUrlPath:(NSString *)path andParams:(NSString *)params CallBack:(CallBack)callback Failure:(RequestFailure)failure{
    
    if (params)
    {
        [path stringByAppendingString:[NSString stringWithFormat:@"?%@",params]];
    }
    
    NSString*  pathStr = [path  stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:pathStr];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
                                  {
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          
                                          
                                          id jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:Nil];
                                          
                                          if (callback)
                                          {
                                              callback(jsonData);
                                          }
                                          
                                          if (error)
                                          {
                                              
                                              if (failure)
                                              {
                                                  failure(error);
                                              }
                                          }
                                      });
                                  }];
    [task resume];
}

#pragma mark - 系统自带POST请求接口
/**
 *  系统自带POST请求接口
 *  @param path  请求的URL
 *  @param params      登录需要传的参数   字典形式，若为Get请求可传空
 *  @param callback    成功回调,id对象 自行转换数组或字典
 *  @param failure     失败回调,返回NSError对象
 */
-(void)postddByByUrlPath:(NSString *)path Params:(NSDictionary*)params CallBack:(CallBack)callback Failure:(void(^)(NSError *error))failure{
    
    NSURL *url = [NSURL URLWithString:path];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    
    if ([NSJSONSerialization isValidJSONObject:params])
    {
        NSData *jsonData = [self getDataFromDic:params];
        [request  setHTTPBody:jsonData];
        
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                id  jsonData = [NSJSONSerialization JSONObjectWithData:data options:0 error:Nil];
                
                if (callback)
                {
                    callback(jsonData);
                }
                
                if (error)
                {
                    if (failure)
                    {
                        failure(error);
                    }
                }
            });
        }];
        //开始请求
        [task resume];
    }
}

#pragma mark - 数据字典转换二进制流
- (NSData*)getDataFromDic:(NSDictionary *)dic
{
    NSString *string = nil;
    NSArray *array = [dic allKeys];
    for (int i = 0; i<array.count; i++)
    {
        NSString *key = [array objectAtIndex:i];
        NSString *value = [dic valueForKey:key];
        if (i == 0)
        {
            string = [NSString stringWithFormat:@"%@=%@",key,value];
        }
        else
        {
            string = [NSString stringWithFormat:@"%@&%@=%@",string,key,value];
        }
    }
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark - 第三方AFNetWorking图片上传接口
/**
 *  第三方AFNetWorking图片上传接口
 *  @param URLString   请求的URL
 *  @param imageName   上传图片名
 *  @param params      登录需要传的参数   字典形式，若为Get请求可传空
 *  @param image       要上传的图片
 *  @param callback    成功回调,id对象 自行转换数组或字典
 *  @param failure     失败回调,返回NSError对象
 */
-(void)upLoadImageByUrl:(NSString *)URLString ImageName:(NSString*)imageName Params:(NSDictionary *)params Image:(UIImage*)image CallBack:(CallBack)callback Failure:(void(^)(NSError *error))failure{
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json",nil];
    
    [manager POST:URLString parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData)
    {
        NSData*  imageData = UIImageJPEGRepresentation(image, 0.8);
        [formData appendPartWithFileData:imageData name:imageName fileName:[NSString stringWithFormat:@"image.jpg"] mimeType:@"image/jpeg"];
        
    }
    progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject)
    {
        if (callback)
        {
            callback(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error)
    {
        if (failure)
        {
            failure(error);
        }
    }];
}


#pragma 监测网络的可链接性
-(BOOL) netWorkReachabilityWithURLString:(NSString *) strUrl
{
    __block BOOL netState = NO;
    
    // 如果要检测网络状态的变化,必须用检测管理器的单例的startMonitoring
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    // 检测网络连接的单例,网络变化时的回调方法
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWWAN:
            case AFNetworkReachabilityStatusReachableViaWiFi:
                netState = YES;
                break;
            case AFNetworkReachabilityStatusNotReachable:
                netState = NO;
            default:
                break;
        }
        
    }];
    
    return netState;
}

@end
