//
//  DynaSignRequest.m
//  EmailSignature
//
//  Created by Alexei Gura on 12/5/17.
//  Copyright © 2017 Alexei Gura. All rights reserved.
//

#import "DynaSignRequest.h"
#import "AppDelegate.h"

@implementation DynaSignRequest
{
    AppDelegate *appDelegate;
}
- (id) init {
    appDelegate = (AppDelegate *)[NSApp delegate];
    return [super init];
}

- (void)requestForTemplate {
    NSString *requestURL;
    
    requestURL = [NSString stringWithFormat:@"%@%@", SERVER_ADDR, appDelegate.mStrEmailAddr];
    
    defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    [defaultConfigObject setTimeoutIntervalForRequest:5.0];
    defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate:self delegateQueue: [NSOperationQueue mainQueue]];
    dataTask = [defaultSession dataTaskWithURL: [NSURL URLWithString:requestURL]];
    [dataTask resume];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    completionHandler(NSURLSessionResponseAllow);
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if ([httpResponse statusCode] == 200) {
        mlTotalSize = (long)[httpResponse expectedContentLength];
        downloadData = [[NSMutableData alloc] init];
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [downloadData appendData:data];
    if ((long)[downloadData length] >= mlTotalSize)
        [self saveData];
}

-(void)URLSession:(NSURLSession *)session task:(nonnull NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error {
    NSLog(@"request failed :%@", error);
    if (error != nil)
        [self.delegate doneRequestAndExtract:NO FilePath:@""];
    
}

- (void)saveData {
    NSDate *curDate = [NSDate date];
    curSettedTempFilaName = [NSString stringWithFormat:@"%ld.html", (long)[curDate timeIntervalSince1970]];
    NSString *downloadFullPath = [NSString stringWithFormat:@"%@/%@", appDelegate.g_pathOfData, curSettedTempFilaName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager createFileAtPath:downloadFullPath contents:downloadData attributes:nil]) {
        [self unzipData];
    } else {
        NSLog(@"Save zip file failed!");
    }
}

- (void)unzipData{
//    NSString *name = (NSString *)[Util getFileNameWithoutExtFromFullName:curSettedTempFilaName];
    // Need to use the full path to everything
    // In this example, I am using my Downloads directory
    NSString *downloadFullPath = [NSString stringWithFormat:@"%@/%@", appDelegate.g_pathOfData, curSettedTempFilaName];
    [self.delegate doneRequestAndExtract:YES FilePath:downloadFullPath];
    
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    
//    NSString *destDir =[NSString stringWithFormat:@"%@/%@/", appDelegate.g_pathOfData, name];
//    [fileManager createDirectoryAtPath:destDir  withIntermediateDirectories:YES attributes:nil error:nil];
//    
//    NSString *destination = destDir;
//    NSString *zipFile = [downloadFullPath stringByExpandingTildeInPath];
//    
//    
//    NSTask *unzip = [[NSTask alloc] init];
//    
//    [unzip setLaunchPath:@"/usr/bin/unzip"];
//    [unzip setArguments:[NSArray arrayWithObjects:@"-u", @"-d",
//                         destination, zipFile, nil]];
//    
//    NSPipe *aPipe = [[NSPipe alloc] init];
//    [unzip setStandardOutput:aPipe];
//    
//    [unzip launch];
//    [unzip waitUntilExit];
//    
//    
//    // You can get rid of all the NSLog once you have finish testing
//    NSData *outputData = [[aPipe fileHandleForReading] readDataToEndOfFile];
//    NSString *outputString = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
//    
//    NSLog(@"Zip File: %@", zipFile);
//    NSLog(@"Destination: %@", destination);
//    NSLog(@"Pipe: %@", outputString);
//    NSLog(@"------------- Finish -----------");
//    [self.delegate doneRequestAndExtract:YES FilePath:destination];
}

@end
