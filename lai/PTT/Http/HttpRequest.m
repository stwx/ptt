//
//  HttpRequest.m
//  PTT
//
//  Created by xihan on 15/6/3.
//  Copyright (c) 2015年 stwx. All rights reserved.
//

#import "HttpRequest.h"
#import "HttpUrl.h"
#import "HttpInfo.h"
#import "NSString+Extension.h"

#define BOUNDARY @"----------cH2gL6ei4Ef1KM7cH2KM7ae0ei4gL6"

const NSTimeInterval requestTimeout = 10;

@interface HttpRequest()<NSURLSessionDataDelegate>

@property (nonatomic, strong)AckHandler ackHandler;
@property (nonatomic, strong)DicHandler dicHandler;

@end

@implementation HttpRequest


+ (void)postRequestWithHttpType:(HttpType)httpTpye
                         action:(int) action
                         params:(NSArray *)params
                        Handler:(AckHandler)handler{
    
    NSString *urlString = [HttpUrl httpUrlStringWithHttpType:httpTpye action:action params:params];
    NSString *encodedString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:encodedString];
    
    HttpRequest *httpRequest = [[HttpRequest alloc] init];
    httpRequest.ackHandler = handler;
    [httpRequest postRequestWithUrl:url];

}

- (void)postRequestWithUrl:(NSURL*)url
{
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:requestTimeout];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString *dataString;
        if (error == nil) {
            
            dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            
        }
        else{
            dataString = ACK_TIMEOUT;
            DLog(@"\n================\n%@\n=============\n",error);
        }
        if (self.ackHandler) {
            self.ackHandler(dataString);
        }
        [session finishTasksAndInvalidate];
    }];
    [dataTask resume];
}

#pragma mark ----upload-----
+ (void)uploadFileByFilePath:(NSString *)filePath
                     handler:(AckHandler)handler{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSData *data = [fileManager contentsAtPath:filePath];
    
    HttpRequest *httpRequest = [[HttpRequest alloc] init];
    httpRequest.ackHandler = handler;
    [httpRequest uploadFileByFileName:[filePath lastPathComponent] fileData:data];
    
}

- (void)uploadFileByFileName:(NSString *)fileName
                    fileData:(NSData *)fileData{
    NSString *urlStr = [NSString stringWithFormat:@"%@Upload",HTTP_HEAD];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSMutableURLRequest *request = [ [NSMutableURLRequest alloc] initWithURL: url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:requestTimeout];
    [request setHTTPMethod:@"POST"];
    [request setValue:[@"multipart/form-data; boundary=" stringByAppendingString:BOUNDARY] forHTTPHeaderField:@"Content-Type"];
    
    NSMutableData *body = [NSMutableData data];
    
    NSString *param1 = [NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-data; name=""file"";filename=""%@""\r\nContent-Type: application/octet-stream\r\n\r\n",BOUNDARY,fileName];
    
    [body appendData:[param1 dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:fileData];
    [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *endParam = [NSString stringWithFormat:@"--%@--",BOUNDARY];
    [body appendData:[endParam dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *param = [NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-data; name=""action""\r\n\r\nupload\r\n",BOUNDARY];
    [body appendData:[param dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:body];
    
    [self postWithRequest:request];
}

- (void)postWithRequest:(NSURLRequest *)request{
  
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSString *dataString;
        if (error == nil) {
            dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
           
        }
        else{
            dataString = ACK_TIMEOUT;
            DLog(@"\n================\n%@\n=============\n",error);
        }
        if (self.ackHandler) {
            self.ackHandler(dataString);
        }
        [session finishTasksAndInvalidate];
    }];
    [dataTask resume];
}

#pragma mark ----download-----
+ (void)downloadFileByFileName:(NSString *)fileName
                       handler:(DicHandler)handler{
    
    DLog(@"downloadFileByFileName!!!!");
    
    NSString *urlStr = [NSString stringWithFormat:@"%@Uploaded/%@",HTTP_HEAD,fileName];
    DLog(@"download url:%@",urlStr);
    NSURL *url = [NSURL URLWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:requestTimeout];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURLSessionDownloadTask *downLoad = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        NSDictionary *ackDic;
        DLog(@"download finish!!");
        HttpRequest *httpRequest = [[HttpRequest alloc] init];
        httpRequest.dicHandler = handler;
        if (error) {
            DLog(@"download error = %@",error.localizedDescription);
            ackDic = @{ ACK_RESULT:@0 };
        }
        else{
            
            // 如果要保存文件,需要将文件保存至沙盒
            // 生成沙盒的路径
            NSString *document = PATH_OF_DOCUMENT;
            NSString *folder = [document stringByAppendingPathComponent:@"Record"];
            NSString *path = [folder stringByAppendingPathComponent:fileName];
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            
            if (![fileManager fileExistsAtPath:folder]) {
                
                BOOL blCreateFolder= [fileManager createDirectoryAtPath:folder withIntermediateDirectories:NO attributes:nil error:NULL];
            
                if (!blCreateFolder) {
                    DLog(@" folder fial");
                    ackDic = @{ ACK_RESULT:@0 };
                    
                    if (httpRequest.dicHandler) {
                        httpRequest.dicHandler(ackDic);
                    }
                    [session finishTasksAndInvalidate];
                    return ;
                }
            }
            
            NSURL *toURL = [NSURL fileURLWithPath:path];
            // 将文件从临时文件夹复制到沙盒
            [fileManager copyItemAtURL:location toURL:toURL error:nil];
            DLog(@"download file success ");
            ackDic = @{ ACK_RESULT:@1, ACK_MSG:fileName };
        }
        
        if (httpRequest.dicHandler) {
            httpRequest.dicHandler(ackDic);
        }
        [session finishTasksAndInvalidate];
    }];
    [downLoad resume];

}



@end
