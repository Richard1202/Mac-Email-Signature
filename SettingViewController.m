//
//  ViewController.m
//  EmailSignature
//
//  Created by Alexei Gura on 12/4/17.
//  Copyright © 2017 Alexei Gura. All rights reserved.
//

#import "SettingViewController.h"

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear {
    [super viewDidAppear];
    self.appDelegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
    // Do any additional setup after loading the view.
    [self.mPopMenuMailKind setEnabled:NO];
    [self.mChkSync setState:0];
    [self.mtxtPassword setEnabled:NO];
    [[self.mSelSelectSignature menu] setDelegate:self];
    
    
    [[self.mSelSelectSignature menu] removeAllItems];
    
    NSMenuItem *item0 = [[NSMenuItem alloc] init];
    [item0 setTitle:DEF_LBL_SELECT_SIGNATURE];
    NSMenuItem *item1 = [[NSMenuItem alloc] init];
    [item1 setTitle:@""];
    
    [[self.mSelSelectSignature menu] addItem:item0];
    [[self.mSelSelectSignature menu] addItem:item1];
    
    mAryMailSigns = [Util loadCurSignaturesFromMail];
    
    if (mAryMailSigns != nil && mAryMailSigns.count > 0) {
        
        [[self.mSelSelectSignature menu] removeItemAtIndex:1];
        for (NSString *sign in mAryMailSigns) {
            NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:sign action:@selector(onItemSelected:) keyEquivalent:@""];
            [[self.mSelSelectSignature menu] addItem:item];
            if ([self.appDelegate.mStrMailSignName isEqualToString:sign]) {
                [self.mSelSelectSignature setTitle:self.appDelegate.mStrMailSignName];
            }
        }
    }

    if (![Util isFirstRun]) {
        [self.mtxtEmailAdress setStringValue:self.appDelegate.mStrEmailAddr];
        [self.mTxtRequestTimeStep setStringValue:[NSString stringWithFormat:@"%d", self.appDelegate.mRequestTimeStep]];
        self.mStepperHour.intValue = self.appDelegate.mRequestTimeStep;
        if (self.appDelegate.mbIsSyncWithOther) {
            [self.mChkSync setState:1];
            [self.mPopMenuMailKind setEnabled:YES];
            [self.mtxtPassword setEnabled:YES];
        }
        [self.mtxtPassword setStringValue:self.appDelegate.mStrSyncWithPass];
        
    } else {
        
    }
    
}

-(void)onItemSelected:(NSMenuItem *)sender {
    [self.mSelSelectSignature setTitle:sender.title];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)onDownloadSignNow:(id)sender {
    if (![self validateEmailAddr]) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Email adress should be format follow as \"ed.edwards@tscg.com\"."];
        [alert addButtonWithTitle:@"Ok"];
        [alert runModal];
        return;
    }
    
    if ([self.mSelSelectSignature.title isEqualToString:DEF_LBL_SELECT_SIGNATURE]) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"No Mac Mail signature is selected.\nWould you continue without Mac Mail?"];
        [alert addButtonWithTitle:@"Ok"];
        [alert addButtonWithTitle:@"Cancel"];
        NSModalResponse retType = [alert runModal];
        if (retType == NSAlertFirstButtonReturn) {
            [self.appDelegate saveSettingDataWithMailAddr:self.mtxtEmailAdress.stringValue timeStep:[self.mTxtRequestTimeStep.stringValue intValue] syncWithOther:self.mChkSync.state==0?NO:YES syncWithWhat:@"Office365" syncWithPass:self.mtxtPassword.stringValue mailSignName:self.mSelSelectSignature.title];
            [self.appDelegate.g_requestEntity requestForTemplate];
            return;
        }
    } else {
        [self.appDelegate saveSettingDataWithMailAddr:self.mtxtEmailAdress.stringValue timeStep:[self.mTxtRequestTimeStep.stringValue intValue] syncWithOther:self.mChkSync.state==0?NO:YES syncWithWhat:@"Office365" syncWithPass:self.mtxtPassword.stringValue mailSignName:self.mSelSelectSignature.title];
        [self.appDelegate.g_requestEntity requestForTemplate];
    }
}

- (IBAction)onCheckSync:(NSButton*)sender {
    if (sender.state == 0) {
        [self.mPopMenuMailKind setEnabled:NO];
        [self.mtxtPassword setEnabled:NO];
    } else if (sender.state == 1) {
        [self.mPopMenuMailKind setEnabled:YES];
        [self.mtxtPassword setEnabled:YES];
    }
}

- (IBAction)onEditSign:(id)sender {
//    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
//    [userDefaults setBool:NO forKey:DEF_FIRST_RUN_COMPLETE];
//    [userDefaults synchronize];
//
    if (![self validateEmailAddr]) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Email adress should be format follow as \"ed.edwards@tscg.com\"."];
        [alert addButtonWithTitle:@"Ok"];
        [alert runModal];
        return;
    }
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", EDIT_SIGN_SERVER_ADDR, self.mtxtEmailAdress.stringValue]];
    if (![[NSWorkspace sharedWorkspace] openURL:url]) {
        NSLog(@"Failed to open url: %@", [url description]);
    }
}

- (IBAction)onSaveExit:(id)sender {
   
    if (![self validateEmailAddr]) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Email adress should be format follow as \"ed.edwards@tscg.com\"."];
        [alert addButtonWithTitle:@"Ok"];
        [alert runModal];
        return;
    }
    if ([self.mSelSelectSignature.title isEqualToString:DEF_LBL_SELECT_SIGNATURE]) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"No Mac Mail signature is selected.\nWould you continue without Mac Mail?"];
        [alert addButtonWithTitle:@"Ok"];
        [alert addButtonWithTitle:@"Cancel"];
        NSModalResponse retType = [alert runModal];
        if (retType == NSAlertFirstButtonReturn) {
            
            [self.appDelegate saveSettingDataWithMailAddr:self.mtxtEmailAdress.stringValue timeStep:[self.mTxtRequestTimeStep.stringValue intValue] syncWithOther:self.mChkSync.state==0?NO:YES syncWithWhat:@"Office365" syncWithPass:self.mtxtPassword.stringValue mailSignName:self.mSelSelectSignature.title];
            [self.appDelegate startRequestCountdown];
            [Util setFirstRunComplete];
            NSWindow *curWin = [NSApplication sharedApplication].keyWindow;
            [curWin close];
        }
    } else {
        
        [self.appDelegate saveSettingDataWithMailAddr:self.mtxtEmailAdress.stringValue timeStep:[self.mTxtRequestTimeStep.stringValue intValue] syncWithOther:self.mChkSync.state==0?NO:YES syncWithWhat:@"Office365" syncWithPass:self.mtxtPassword.stringValue mailSignName:self.mSelSelectSignature.title];
        [self.appDelegate startRequestCountdown];
        [Util setFirstRunComplete];
        NSWindow *curWin = [NSApplication sharedApplication].keyWindow;
        [curWin close];
    }
    
    

}

- (BOOL)validateEmailAddr {
    NSString *mailAddr = self.mtxtEmailAdress.stringValue;
    NSString *emailRegex = @"^[_A-Za-z0-9-\\+]+(\\.[_A-Za-z0-9-]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:mailAddr];
}

- (IBAction)onCancel:(id)sender {
    NSWindow *curWin = [NSApplication sharedApplication].keyWindow;
    [curWin close];
}

- (IBAction)onUpDownHour:(NSStepper *)sender {
    [self.mTxtRequestTimeStep setStringValue:[NSString stringWithFormat:@"%d", sender.intValue]];
}

@end
