//
//  HttpsNetworking.h
//  测试方法
//
//  Created by WZP on 2016/12/2.
//  Copyright © 2016年 123. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>


@interface HttpsNetworking : AFHTTPSessionManager


/**
 获得一个网络请求对象

 @return 网络请求对象
 */
+ (HttpsNetworking *)getManager;

@end


//此类是对AFN的简单封装，为了做https请求，需要导入第三方AFNetworking3.0以上版本
/*使用方法：

    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

 替换为下面的方法，（其他的不变）

    HttpsNetworking *manager = [HttpsNetworking getManager];


*/







