//
//  ViewController.m
//  testDemo
//
//  Created by WZP on 2016/12/7.
//  Copyright © 2016年 123. All rights reserved.
//

#import "ViewController.h"
#import "HttpsNetworking.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self request];
    
}


- (void)request{

    NSLog(@"就这么用,其他的没什么变化,post请求也一样");
    
    HttpsNetworking * manager = [HttpsNetworking getManager];
    
    [manager GET:@"https://你的地址" parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSLog(@"%@",responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        NSLog(@"%@",error);
        
    }];
    
    
    


}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
