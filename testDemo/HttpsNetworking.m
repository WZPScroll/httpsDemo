//
//  HttpsNetworking.m
//  测试方法
//
//  Created by WZP on 2016/12/2.
//  Copyright © 2016年 123. All rights reserved.
//

#import "HttpsNetworking.h"





@implementation HttpsNetworking


+ (HttpsNetworking *)getManager{
    //网络请求object，需要设置一些参数
    HttpsNetworking * manager=[HttpsNetworking manager];
    //
    manager.securityPolicy=[self policy];
    //如果是双向认证则重写NSURLSesson的代理方法(取消下面的注释就可以)
//    [self setSessionDidReceiveAuthenticationChallengeWithManager:manager];
    
    return manager;
}


+ (AFSecurityPolicy *)policy{
    //根证书路径
    NSString * path = [[NSBundle mainBundle] pathForResource:@"xiaoxun" ofType:@"cer"];
    //
    NSData * cerData = [NSData dataWithContentsOfFile:path];
    //
    NSSet * dataSet = [NSSet setWithObject:cerData];
    //AFNetworking验证证书的object
    AFSecurityPolicy * policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate withPinnedCertificates:dataSet];
    //是否可以使用自建证书（不花钱的）
    policy.allowInvalidCertificates=YES;
    //是否验证域名（一般不验证）
    policy.validatesDomainName=NO;
    
    return policy;

}

+ (void)setSessionDidReceiveAuthenticationChallengeWithManager:(AFHTTPSessionManager *)manager{
    
    __weak typeof(manager)weakManager = manager;
    __weak typeof(self)weakSelf = self;


    [manager setSessionDidReceiveAuthenticationChallengeBlock:^NSURLSessionAuthChallengeDisposition(NSURLSession*session, NSURLAuthenticationChallenge *challenge, NSURLCredential *__autoreleasing*_credential) {
        NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
        __autoreleasing NSURLCredential *credential =nil;
        
        
        if([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
            NSLog(@"验证服务器1");
            if([weakManager.securityPolicy evaluateServerTrust:challenge.protectionSpace.serverTrust forDomain:challenge.protectionSpace.host]) {
                NSLog(@"验证服务器2");
                
                credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
                if(credential) {
                    NSLog(@"验证服务器3");
                    disposition =NSURLSessionAuthChallengeUseCredential;
                } else {
                    NSLog(@"验证服务器4");
                    
                    disposition =NSURLSessionAuthChallengePerformDefaultHandling;
                }
            } else {
                NSLog(@"验证服务器5");
                
                disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
            }
        } else {
            NSLog(@"验证客户端1");
            
            // client authentication
            SecIdentityRef identity = NULL;
            SecTrustRef trust = NULL;
            NSString *p12 = [[NSBundle mainBundle] pathForResource:@"client"ofType:@"p12"];
            NSFileManager *fileManager =[NSFileManager defaultManager];
            
            if(![fileManager fileExistsAtPath:p12])
            {
                NSLog(@"client.p12:not exist");
            }
            else
            {
                NSLog(@"验证客户端2");
                
                NSData *PKCS12Data = [NSData dataWithContentsOfFile:p12];
                
                if ([[weakSelf class]extractIdentity:&identity andTrust:&trust fromPKCS12Data:PKCS12Data])
                {
                    NSLog(@"验证客户端3");
                    
                    SecCertificateRef certificate = NULL;
                    SecIdentityCopyCertificate(identity, &certificate);
                    const void*certs[] = {certificate};
                    CFArrayRef certArray =CFArrayCreate(kCFAllocatorDefault, certs,1,NULL);
                    credential =[NSURLCredential credentialWithIdentity:identity certificates:(__bridge  NSArray*)certArray persistence:NSURLCredentialPersistencePermanent];
                    disposition =NSURLSessionAuthChallengeUseCredential;
                }
                
            }
        }
        *_credential = credential;
        return disposition;
    }];
}

+ (BOOL)extractIdentity:(SecIdentityRef*)outIdentity andTrust:(SecTrustRef *)outTrust fromPKCS12Data:(NSData *)inPKCS12Data {
    OSStatus securityError = errSecSuccess;
    //客户端证书密码
    NSDictionary*optionsDictionary = [NSDictionary dictionaryWithObject:@"123456" forKey:(__bridge id)kSecImportExportPassphrase];
    
    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
    securityError = SecPKCS12Import((__bridge CFDataRef)inPKCS12Data,(__bridge CFDictionaryRef)optionsDictionary,&items);
    
    if(securityError == 0) {
        CFDictionaryRef myIdentityAndTrust =CFArrayGetValueAtIndex(items,0);
        const void*tempIdentity =NULL;
        tempIdentity= CFDictionaryGetValue (myIdentityAndTrust,kSecImportItemIdentity);
        *outIdentity = (SecIdentityRef)tempIdentity;
        const void*tempTrust =NULL;
        tempTrust = CFDictionaryGetValue(myIdentityAndTrust,kSecImportItemTrust);
        *outTrust = (SecTrustRef)tempTrust;
    } else {
        NSLog(@"Failedwith error code %d",(int)securityError);
        return NO;
    }
    return YES;
}

@end
