//
//  WLHttpManager.h
//  WeiLv
//
//  Created by James on 16/5/12.
//  Copyright © 2016年 WeiLv Technology. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

typedef NS_ENUM(NSInteger,RequestType){
    
    RequestTypeGet,
    RequestTypePost
    
};

typedef void(^CallBack)(id responseObject);
typedef void(^RequestFailure)(NSError *error) ;


@interface JDHttpManager : NSObject

//单例类创建方法

+ (instancetype)shareManager;


/**
 *  第三方AFNetWorking请求接口
 *  @param URLString  请求的URL
 *  @param parameters      登录需要传的参数   字典形式，若为Get请求可传空
 *  @param type       请求方式
 *  @param success    成功回调,id对象 自行转换数组或字典
 *  @param failure    失败回调,返回NSError对象
 
 
 */
//GET POST请求接口
//用AFNetWorking第三方请求接口
- (void)requestWithURL:(NSString* )URLString
           RequestType:(RequestType)type
            Parameters:(NSDictionary*)parameters
               Success:(void(^)(id responseObject))success
               Failure:(void(^)(NSError *error))failure;


/**
 *  系统自带Get请求接口
 *  @param path  请求的URL
 *  @param params      登录需要传的参数   字典形式，若为Get请求可传空
 *  @param callback    成功回调,id对象 自行转换数组或字典
 *  @param failure     失败回调,返回NSError对象
 */

//用系统自带的NSURLSession请求 GET接口
-(void)getddByUrlPath:(NSString *)path
            andParams:(NSString *)params
             CallBack:(CallBack)callback
              Failure:(RequestFailure)failure;


/**
 *  系统自带POST请求接口
 *  @param path  请求的URL
 *  @param params      登录需要传的参数   字典形式，若为Get请求可传空
 *  @param callback    成功回调,id对象 自行转换数组或字典
 *  @param failure     失败回调,返回NSError对象
 */
//用系统自带的请求   POST请求
-(void)postddByByUrlPath:(NSString *)path
                  Params:(NSDictionary*)params
                CallBack:(CallBack)callback
                 Failure:(void(^)(NSError *error))failure;


/**
 *  第三方AFNetWorking图片上传接口
 *  @param URLString   请求的URL
 *  @param imageName   上传图片名
 *  @param params      登录需要传的参数   字典形式，若为Get请求可传空
 *  @param image       要上传的图片
 *  @param callback    成功回调,id对象 自行转换数组或字典
 *  @param failure     失败回调,返回NSError对象
 */


-(void)upLoadImageByUrl:(NSString *)URLString
              ImageName:(NSString*)imageName
                 Params:(NSDictionary *)params
                  Image:(UIImage*)image
               CallBack:(CallBack)callback
                Failure:(void(^)(NSError *error))failure;


//监测网络的可链接性
-(BOOL) netWorkReachabilityWithURLString:(NSString *) strUrl;

@end

