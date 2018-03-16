//
//  Util.h
//  EmailSignature
//
//  Created by Alexei Gura on 12/6/17.
//  Copyright © 2017 Alexei Gura. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
@interface Util : NSObject

+(NSString*)getFileNameWithoutExtFromFullName:(NSString*)filename;
+(BOOL)isFirstRun;
+(void)setFirstRunComplete;
+(BOOL)makeDynaSignature:(NSString *)emailAccount;
+(NSMutableArray*)loadCurSignaturesFromMail;
+(BOOL)isRunningMailApp;
+(BOOL)killMailApplication;
+(BOOL)startMailApplication;
+(NSString*)getStringWithAppResourceFile:(NSString *)filePath;
+(NSString*)getStringWithFilePath:(NSString *)filePath;
+ (NSString *)uploadXmlFileForEWSAPIWithHtml:(NSString *)filePath;

+(BOOL)setSignatureOnOutlookWithHtmlFile:(NSString*) htmFilePath;
+(BOOL)setSignatureOnMailWithHtmlFile:(NSString*) htmFilePath signatureName:(NSString *)sinatureName;
+(void)openMailAppOnlyApp;
+(void)openMailApp;
+(void)openOutlookApp;

+(NSString*)getSignatureUniqueIdWithSignName:(NSString *)signName;
+(BOOL)setLockSignFile:(NSString *)uniqueId withLock:(BOOL)isLock;
@end
