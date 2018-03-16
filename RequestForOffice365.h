//
//  RequestForOffice365.h
//  EmailSignature
//
//  Created by CARDAPP on 3/1/14.
//  Copyright © 2014 Alexei Gura. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppConfig.h"

@protocol RequestForOffice365Delegate <NSObject>

- (void)resultRequestForOffice365:(BOOL)isSuccess;

@end

@interface RequestForOffice365 : NSObject<NSURLSessionDelegate, NSURLSessionDataDelegate, NSURLSessionTaskDelegate, NSURLDownloadDelegate, NSXMLParserDelegate>
{
    NSMutableData *webData;
    long mlTotalSize;
    NSMutableArray *xmlArray;
}
@property (nonatomic, retain) id<RequestForOffice365Delegate> delegate;

- (void)callWebServiceWithHtmlPath:(NSString *)strPath password:(NSString *)password emailAddress:(NSString *)emailAddress;
@end
