//
//  AppDelegate.m
//  EmailSignature
//
//  Created by Alexei Gura on 12/4/17.
//  Copyright © 2017 Alexei Gura. All rights reserved.
//

#import "AppDelegate.h"


@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [NSApp activateIgnoringOtherApps:YES];
    self.window = nil;
    mTimer = nil;
    _statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    _statusItem.image = [NSImage imageNamed:@"ServiceIcon"];
    _statusItem.highlightMode = YES;
    
    // create menu
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@""];
    NSMenuItem *item1 = [[NSMenuItem alloc] initWithTitle:@"Setting" action:@selector(onClickSetting:) keyEquivalent:@""];
    NSMenuItem *item2 = [[NSMenuItem alloc] initWithTitle:@"Exit" action:@selector(onClickExit:) keyEquivalent:@""];
    
    [menu addItem:item1];
    [menu addItem:[NSMenuItem separatorItem]];
    [menu addItem:item2];
    
    [_statusItem setMenu:menu]; // attach
    
    // Reqeust Entity created!
    self.g_requestEntity = [[DynaSignRequest alloc] init];
    self.g_requestEntity.delegate = self;
    // create directory to temperary
    self.g_pathOfData = [NSTemporaryDirectory() stringByAppendingPathComponent:@"/EmialSignature/"];
    [[NSFileManager defaultManager] createDirectoryAtPath:self.g_pathOfData
                              withIntermediateDirectories:YES attributes:nil error:nil];
    mUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if (![Util isFirstRun]) {
        [self loadSettingData];
        [self startRequestCountdown];
    } else {
        self.mRequestTimeStep = 1;
        mLastRequestTime = 0;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self onClickSetting:nil];
        });
        
    }
}

- (void)startRequestCountdown {
    if (mTimer == nil) {
        mTimer = [NSTimer scheduledTimerWithTimeInterval:DEF_CONNECT_DURATION target:self selector:@selector(manageRequest:) userInfo:nil repeats:YES];
        [mTimer fire];
    }
}

- (void)loadSettingData {
    mLastRequestTime = [[mUserDefaults valueForKey:DEF_LAST_REQUEST_TIME] doubleValue];
    
    self.mRequestTimeStep = [[mUserDefaults valueForKey:DEF_REQUEST_TIME_STEP] intValue];
    if (self.mRequestTimeStep == 0)
        self.mRequestTimeStep = 1;
    self.mStrSyncWithPass = [mUserDefaults valueForKey:DEF_SYNC_WITH_PASS]?[mUserDefaults valueForKey:DEF_SYNC_WITH_PASS]:@"";
    self.mStrEmailAddr = [mUserDefaults valueForKey:DEF_USER_EMAIL_ADDRESS]?[mUserDefaults valueForKey:DEF_USER_EMAIL_ADDRESS]:@"";
    self.mStrSyncWithWhat = [mUserDefaults valueForKey:DEF_SYNC_WITH_WHAT]?[mUserDefaults valueForKey:DEF_SYNC_WITH_WHAT]:@"";
    self.mbIsSyncWithOther = [[mUserDefaults valueForKey:DEF_SYNC_WITH_OTHER] boolValue];
    self.mStrMailSignName = [mUserDefaults valueForKey:DEF_MAIL_SIGN_TO_UPDATE]?[mUserDefaults valueForKey:DEF_MAIL_SIGN_TO_UPDATE]:@"";
}

- (void)saveSettingDataWithMailAddr:(NSString*)mailAddr timeStep:(int)timeStep syncWithOther:(BOOL)syncWithOther syncWithWhat:(NSString *)syncWithWhat syncWithPass:(NSString *)pass mailSignName:(NSString*)signName {
    
    self.mRequestTimeStep = timeStep;
    self.mStrSyncWithPass = pass;
    self.mStrSyncWithWhat = syncWithWhat;
    self.mbIsSyncWithOther = syncWithOther;
    self.mStrEmailAddr = mailAddr;
    self.mStrMailSignName = signName;
    
    [mUserDefaults setValue:mailAddr forKey:DEF_USER_EMAIL_ADDRESS];
    [mUserDefaults setInteger:timeStep forKey:DEF_REQUEST_TIME_STEP];
    [mUserDefaults setBool:syncWithOther forKey:DEF_SYNC_WITH_OTHER];
    [mUserDefaults setValue:syncWithWhat forKey:DEF_SYNC_WITH_WHAT];
    [mUserDefaults setValue:pass forKey:DEF_SYNC_WITH_PASS];
    
    if (![signName isEqualToString:DEF_LBL_SELECT_SIGNATURE])
        [mUserDefaults setValue:signName forKey:DEF_MAIL_SIGN_TO_UPDATE];
    
    [mUserDefaults synchronize];
}

- (void)manageRequest:(id)sender {
    NSTimeInterval curTime = [[NSDate date] timeIntervalSince1970];
    double timeStep = 3600 * self.mRequestTimeStep;
    //double timeStep = self.mRequestTimeStep; //test
    
    int aa =curTime - mLastRequestTime;
    NSLog(@"------>>>>>>>%d", aa);
    if (curTime - mLastRequestTime >= timeStep) {
        [self.g_requestEntity requestForTemplate];
    }
}

- (void)saveRequestTime {
    NSTimeInterval curTime = [[NSDate date] timeIntervalSince1970];
    mLastRequestTime = curTime;
    [mUserDefaults setDouble:curTime forKey:DEF_LAST_REQUEST_TIME];
    [mUserDefaults synchronize];
}

- (void)execCommandLineForMailSignWithFilepath:(NSString *)path signatureName:(NSString*)signatureName htmlPath:(NSString *)htmlPath{
    NSArray *args = [NSArray arrayWithObjects:signatureName, htmlPath, nil];
    [[NSTask launchedTaskWithLaunchPath:path arguments:args] waitUntilExit];
}

#pragma mark - DynaSignRequestDelegate
-(void)doneRequestAndExtract:(BOOL)result FilePath:(NSString *)filePath{
    
    if (result) {
        
        [self saveRequestTime];
        NSString *htmFilePath = filePath;
        mHtmlFilePath = filePath;
        
        // set signature for Mac Mail
        if (![self.mStrMailSignName isEqualToString:DEF_LBL_SELECT_SIGNATURE]) {
            NSString *signId = [Util getSignatureUniqueIdWithSignName:self.mStrMailSignName];
            [Util setLockSignFile:signId withLock:NO];
            
            NSString *bundlePath = [[NSBundle mainBundle] pathForResource:[[DEF_MAIL_SIGN_INSTALLER_NAME componentsSeparatedByString:@"."] objectAtIndex:0]   ofType:[[DEF_MAIL_SIGN_INSTALLER_NAME componentsSeparatedByString:@"."] objectAtIndex:1]];
            NSString *installerName = bundlePath;
        
            [self execCommandLineForMailSignWithFilepath:installerName signatureName:self.mStrMailSignName htmlPath:htmFilePath];
        
            [Util setLockSignFile:signId withLock:YES];
            
            NSUserNotification *notification = [[NSUserNotification alloc] init];
            [notification setTitle:@"Mail signature is updated."];
            [notification setInformativeText:@"You should restart the Mail to use new signature."];
            [notification setActionButtonTitle:@"Restart"];
            [notification setDeliveryDate:[NSDate date]];
            NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
            [center deliverNotification:notification];
            center.delegate = self;
        }
        
        // set signature for Mac Outlook
        BOOL signSetResultForOutlook = [Util setSignatureOnOutlookWithHtmlFile:mHtmlFilePath];
        if (signSetResultForOutlook) {
            NSUserNotification *notification = [[NSUserNotification alloc] init];
            [notification setTitle:@"Outlook signature is updated."];
            [notification setSubtitle:@"Open Outlook."];
            [notification setActionButtonTitle:@"Open"];
            [notification setDeliveryDate:[NSDate date]];
            NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
            [center deliverNotification:notification];
            center.delegate = self;
        }
        
        queue_request_forOffice365 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        
        if (self.mbIsSyncWithOther) {
            dispatch_async(queue_request_forOffice365, ^{
                RequestForOffice365* request = [[RequestForOffice365 alloc] init];
                request.delegate = self;
                [request callWebServiceWithHtmlPath:mHtmlFilePath password:self.mStrSyncWithPass emailAddress:self.mStrEmailAddr];
            });
        }
        
    } else {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"Can't connect the server to download signature file."];
        [alert setAlertStyle:NSWarningAlertStyle];
        [alert runModal];
    }
}

#pragma mark - Request office 365 delegate
-(void)resultRequestForOffice365:(BOOL)isSuccess {
    if (isSuccess) {
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        [notification setTitle:@"Office 365"];
        [notification setInformativeText:@"The signature is updated."];
        [notification setHasActionButton:NO];
        [notification setDeliveryDate:[NSDate date]];
        NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
        [center deliverNotification:notification];
    } else {
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        [notification setTitle:@"Office 365"];
        [notification setInformativeText:@"The signature is not updated successfully."];
        [notification setHasActionButton:NO];
        [notification setDeliveryDate:[NSDate date]];
        NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
        [center deliverNotification:notification];
    }
}

#pragma mark - NSUserNotification deleage
-(void)userNotificationCenter:(NSUserNotificationCenter *)center didDeliverNotification:(NSUserNotification *)notification {
    
}

-(void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification {
    if ([notification.title isEqualToString:@"Mail signature is updated."]) {
        [Util killMailApplication];
        [Util openMailAppOnlyApp];
    } else if ([notification.title isEqualToString:@"Outlook signature is updated."]) {
        [Util openOutlookApp];
    }
}

-(BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification {
    return YES;
}

#pragma mark - menu method

- (void)onClickSetting:(id)sender {
    NSStoryboard *storyBoard = [NSStoryboard storyboardWithName:@"Main" bundle:nil];
    NSViewController *SettingViewController = [storyBoard instantiateControllerWithIdentifier:@"SettingViewController"];
    
    NSRect screenRct = [[NSScreen mainScreen] frame];
    int xx = screenRct.size.width / 2 - 582 / 2;
    int yy = screenRct.size.height / 2 - 348 / 2;
    NSRect frame = NSMakeRect(xx, yy, 582, 348);
    if (self.window == nil) {
        self.window  = [[NSWindow alloc] initWithContentRect:frame
                                                   styleMask:NSMiniaturizableWindowMask|NSGrooveBorder
                                                     backing:NSBackingStoreBuffered
                                                       defer:NO];
        [self.window setRepresentedFilename: @""]; 
        [self.window setReleasedWhenClosed:NO];
        [self.window setTitle:@"DynaSend Outlook Signature Deployment Tool"];
        [self.window setContentViewController:SettingViewController];
    }
    [self.window makeKeyAndOrderFront:NSApp];
}

- (void)onClickExit:(id)sender {
    [NSApp terminate:nil];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
