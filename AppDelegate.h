//
//  AppDelegate.h
//  EmailSignature
//
//  Created by Alexei Gura on 12/4/17.
//  Copyright © 2017 Alexei Gura. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppConfig.h"
#import "DynaSignRequest.h"
#import "RequestForOffice365.h"

@interface AppDelegate : NSObject <NSApplicationDelegate, DynaSignRequestDelegate, NSUserNotificationCenterDelegate, RequestForOffice365Delegate>
{
    NSUserDefaults *mUserDefaults;
    NSTimeInterval mLastRequestTime;
    NSTimer *mTimer;
    NSString *mHtmlFilePath;
    dispatch_queue_t queue_request_forOffice365;
}
@property (nonatomic, strong) NSStatusItem *statusItem;
@property (nonatomic, strong) DynaSignRequest *g_requestEntity;
@property (nonatomic, strong) NSString *g_pathOfData;

@property (nonatomic, strong) NSString *mStrEmailAddr;
@property (nonatomic, assign) BOOL mbIsSyncWithOther;
@property (nonatomic, strong) NSString *mStrSyncWithWhat;
@property (nonatomic, strong) NSString *mStrSyncWithPass;
@property (retain, strong) NSWindow *window;
@property (nonatomic, assign) int mRequestTimeStep;
@property (nonatomic, strong) NSString *mStrMailSignName;

- (void)saveSettingDataWithMailAddr:(NSString*)mailAddr timeStep:(int)timeStep syncWithOther:(BOOL)syncWithOther syncWithWhat:(NSString *)syncWithWhat syncWithPass:(NSString *)pass mailSignName:(NSString*)signName;
- (void)loadSettingData;
- (void)startRequestCountdown;

@end

