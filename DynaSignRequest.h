//
//  DynaSignRequest.h
//  EmailSignature
//
//  Created by Alexei Gura on 12/5/17.
//  Copyright © 2017 Alexei Gura. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Util.h"
@protocol DynaSignRequestDelegate
@optional
-(void)doneRequestAndExtract:(BOOL)result FilePath:(NSString *)filePath;
@end

@interface DynaSignRequest : NSObject<NSURLSessionDelegate>
{
    NSURLSessionConfiguration *defaultConfigObject;
    NSURLSession *defaultSession;
    NSURLSessionDataTask *dataTask;
    NSMutableData *downloadData;
    NSString *curSettedTempFilaName;
    BOOL    resultVal;
    long    mlTotalSize;
}

@property (strong) id<DynaSignRequestDelegate> delegate;

- (id) init;
- (void)requestForTemplate;
@end
