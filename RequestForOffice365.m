//
//  RequestForOffice365.m
//  EmailSignature
//
//  Created by CARDAPP on 3/1/14.
//  Copyright © 2014 Alexei Gura. All rights reserved.
//

#import "RequestForOffice365.h"
#import "Util.h"

@implementation RequestForOffice365

- (void)callWebServiceWithHtmlPath:(NSString *)strPath password:(NSString *)password emailAddress:(NSString *)emailAddress {
    
    NSString *htmlString = [Util getStringWithFilePath:strPath];
    
    
    NSString *soapMessage = [NSString
                             stringWithFormat:@"<s:Envelope xmlns:s=\"http://schemas.xmlsoap.org/soap/envelope/\"><s:Body><SetSignature xmlns=\"http://tempuri.org/\"><emailAdress>%@</emailAdress><password>%@</password><htmlData>%@</htmlData></SetSignature></s:Body></s:Envelope>"
                             , emailAddress, password, htmlString];

    NSURL *url = [NSURL URLWithString:IIS_SERVER];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    NSString *msgLength = [NSString stringWithFormat:@"%lu", (unsigned long)[soapMessage length]];
    
    [theRequest addValue: @"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [theRequest addValue: SERVER_SOAP_ACTION forHTTPHeaderField:@"SOAPAction"];
    [theRequest addValue:@"100-continue" forHTTPHeaderField:@"Expect"];
    
    [theRequest addValue: msgLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody: [soapMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    [defaultConfigObject setTimeoutIntervalForRequest:3];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate:self delegateQueue: [NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithRequest:theRequest];
    [dataTask resume];
    xmlArray = [[NSMutableArray alloc] init];
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    completionHandler(NSURLSessionResponseAllow);
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    if ([httpResponse statusCode] == 200) {
        mlTotalSize = (long)[httpResponse expectedContentLength];
        webData = [[NSMutableData alloc] init];
    } else {
        [self.delegate resultRequestForOffice365:NO];
    }
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [webData appendData:data];
    if (webData == nil)
        return;
    if ((long)[webData length] >= mlTotalSize)
    {
        NSXMLParser *parser = [[NSXMLParser alloc] initWithData:webData];
        parser.delegate = self;
        BOOL parseResult = [parser parse];
        if (!parseResult) {
            [self.delegate resultRequestForOffice365:NO];
        }
        if ([xmlArray count] == 0)
            [self.delegate resultRequestForOffice365:YES];
        else
            [self.delegate resultRequestForOffice365:NO];
    }
}

-(void)URLSession:(NSURLSession *)session task:(nonnull NSURLSessionTask *)task didCompleteWithError:(nullable NSError *)error{
    NSLog(@"request failed :%@", error);
    if (error != nil)
        [self.delegate resultRequestForOffice365:NO];
}

#pragma mark - NSXMLParser Delegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict {
    
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    [xmlArray addObject:string];
}

@end
