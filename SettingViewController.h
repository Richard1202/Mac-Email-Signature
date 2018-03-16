//
//  ViewController.h
//  EmailSignature
//
//  Created by Alexei Gura on 12/4/17.
//  Copyright © 2017 Alexei Gura. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"

@interface SettingViewController : NSViewController<NSMenuDelegate> {
    NSMutableArray *mAryMailSigns;
}

@property (strong) IBOutlet NSTextField *mtxtEmailAdress;
@property (strong) AppDelegate *appDelegate;
@property (strong) IBOutlet NSPopUpButton *mPopMenuMailKind;
@property (strong) IBOutlet NSTextField *mTxtRequestTimeStep;
@property (strong) IBOutlet NSStepper *mStepperHour;
@property (strong) IBOutlet NSButton *mChkSync;
@property (strong) IBOutlet NSTextField *mtxtPassword;
@property (strong) IBOutlet NSPopUpButton *mSelSelectSignature;


@end

