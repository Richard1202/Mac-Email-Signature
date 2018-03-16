//
//  Util.m
//  EmailSignature
//
//  Created by Alexei Gura on 12/6/17.
//  Copyright © 2017 Alexei Gura. All rights reserved.
//

#import "Util.h"
#import "AppConfig.h"


@implementation Util

+(NSString*)getFileNameWithoutExtFromFullName:(NSString*)filename {
    NSArray *spiltAry = [filename componentsSeparatedByString:@"."];
    return [spiltAry objectAtIndex:0];
}
+(BOOL)isFirstRun {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    return ![[userDefaults valueForKey:DEF_FIRST_RUN_COMPLETE] boolValue];
}
+(void)setFirstRunComplete {
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:YES forKey:DEF_FIRST_RUN_COMPLETE];
    [userDefaults synchronize];
}

+(BOOL)makeDynaSignature:(NSString *)emailAccount {

    NSString *str = [[NSString alloc] initWithUTF8String:"@"];
    NSRange range = [emailAccount rangeOfString:str];
    NSString *username = [emailAccount substringToIndex:range.location];
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    NSString *homeDir = NSHomeDirectory();
    NSString *mailRootDir = [NSString stringWithFormat:@"%@/Library/Mail/", homeDir];
    NSArray *dirAry = [defaultManager contentsOfDirectoryAtPath:mailRootDir error:nil];
    NSString *versionDirName = @"V3";
    for (NSString *versionName in dirAry) {
        if ([versionName isEqualToString:@"V3"]) {
            versionDirName = @"V3";
            break;
        } else if ([versionName isEqualToString:@"V4"]) {
            versionDirName = @"V4";
            break;
        } else if ([versionName isEqualToString:@"V5"]) {
            versionDirName = @"V5";
            break;
        }
        
    }
    NSString *mailDataDir = [NSString stringWithFormat:@"%@/%@/MailData/", mailRootDir, versionDirName];
    NSArray *mailTmpData = [defaultManager contentsOfDirectoryAtPath:mailDataDir error:nil];
    BOOL isExistSignatureDir = NO;
    for (NSString *tmpStr in mailTmpData) {
        if ([tmpStr isEqualToString:@"Signatures"]) {
            isExistSignatureDir = YES;
        }
    }
    NSString *signDir = [NSString stringWithFormat:@"%@/Signatures/", mailDataDir];
    NSString *pathOfAllSign = [NSString stringWithFormat:@"%@/AllSignatures.plist", signDir];
    NSString *pathOfAccountMap = [NSString stringWithFormat:@"%@/AccountsMap.plist", signDir];
    if (!isExistSignatureDir) {
        NSLog(@"Please add 1 signature on mail app.");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"No signature assigned on account.\nPlease add a signature."];
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
        return NO;
    } else {
        
        if (![defaultManager fileExistsAtPath:pathOfAllSign] || ![defaultManager fileExistsAtPath:pathOfAccountMap]) {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:@"No signature assigned on account.\nPlease add a signature."];
            [alert addButtonWithTitle:@"OK"];
            [alert runModal];
            return NO;
        }
    }
    //read account map plist files
    NSMutableArray *allSignAry = [NSMutableArray arrayWithContentsOfFile:pathOfAllSign];
    NSMutableDictionary *accountMapDic = [NSMutableDictionary dictionaryWithContentsOfFile:pathOfAccountMap];
    NSArray *tmpAryValForAccountMap = [accountMapDic allValues];
    NSDictionary *dicToHandle = nil;
    for (NSDictionary *dic in tmpAryValForAccountMap) {
        NSString *accountURL = [dic valueForKey:@"AccountURL"];
        if ([accountURL containsString:username]) {
            dicToHandle = dic;
            break;
        }
    }
    if (dicToHandle == nil) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:[NSString stringWithFormat:@"Email address \"%@\" is not added on Mail.", emailAccount]];
        [alert addButtonWithTitle:@"OK"];
        [alert runModal];
        return NO;
    }
    BOOL isExistProperSignName = NO;
    int properSignNameIndex = -1;
    NSMutableArray *signIDAry = [dicToHandle valueForKey:@"Signatures"];
    for (NSString *validID in signIDAry) {
        for (int i = 0; i < allSignAry.count; i++) {
            NSDictionary *allIDDic = [allSignAry objectAtIndex:i];
            NSString *allID = [allIDDic valueForKey:@"SignatureUniqueId"];
            if ([allID isEqualToString:validID]) {
                NSString *validName = [allIDDic valueForKey:@"SignatureName"];
                if ([validName isEqualToString:DEF_SIGNATURE_NAME]) {
                    properSignNameIndex = i;
                    isExistProperSignName = YES;
                    break;
                }
            }
        }
    }
    if (isExistProperSignName) { //set first index.
        NSDictionary *tmpValidDic = [[allSignAry objectAtIndex:properSignNameIndex] copy];
        [allSignAry removeObjectAtIndex:properSignNameIndex];
        [allSignAry insertObject:tmpValidDic atIndex:0];
    } else {
        
        NSString *signFileName = [Util getRandomSignName];
        
        NSDictionary *dicToInsert = @{@"SignatureUniqueId"  :   signFileName,
                                      @"SignatureName"      :   DEF_SIGNATURE_NAME,
                                      @"SignatureIsRich"    :   @YES};
        [allSignAry insertObject:dicToInsert atIndex:0];
        //get other mailsignature file
        NSArray *otherSigFileAry = [defaultManager contentsOfDirectoryAtPath:signDir error:nil];
        NSString *otherSignName = @"";
        for (NSString *tmpStr in otherSigFileAry) {
          //  int aa = [tmpStr length];
            
            if ([tmpStr containsString:@".mailsignature"]) {
                if ([tmpStr length] > 14) {
                    otherSignName = tmpStr;
                    break;
                }
            }
        }
        if ([otherSignName isEqualToString:@""]) {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setMessageText:@"No signature assigned on account.\nPlease add a signature."];
            [alert addButtonWithTitle:@"OK"];
            [alert runModal];
            return NO;
        }
        [defaultManager copyItemAtPath:[NSString stringWithFormat:@"%@/%@", signDir, otherSignName] toPath:[NSString stringWithFormat:@"%@/%@.mailsignature", signDir, signFileName] error:nil];
        [signIDAry addObject:signFileName];
        [accountMapDic writeToFile:pathOfAccountMap atomically:YES];
    }
    [allSignAry writeToFile:pathOfAllSign atomically:YES];
    
    return YES;
}

+(NSMutableArray*)loadCurSignaturesFromMail {
    
    NSMutableArray *retAry = [[NSMutableArray alloc] init];
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    NSString *homeDir = NSHomeDirectory();
    NSString *mailRootDir = [NSString stringWithFormat:@"%@/Library/Mail/", homeDir];
    NSArray *dirAry = [defaultManager contentsOfDirectoryAtPath:mailRootDir error:nil];
    NSString *versionDirName = @"V3";
    for (NSString *versionName in dirAry) {
        if ([versionName isEqualToString:@"V3"]) {
            versionDirName = @"V3";
            break;
        } else if ([versionName isEqualToString:@"V4"]) {
            versionDirName = @"V4";
            break;
        } else if ([versionName isEqualToString:@"V5"]) {
            versionDirName = @"V5";
            break;
        }
        
    }
    NSString *mailDataDir = [NSString stringWithFormat:@"%@/%@/MailData/", mailRootDir, versionDirName];
    NSArray *mailTmpData = [defaultManager contentsOfDirectoryAtPath:mailDataDir error:nil];
    BOOL isExistSignatureDir = NO;
    for (NSString *tmpStr in mailTmpData) {
        if ([tmpStr isEqualToString:@"Signatures"]) {
            isExistSignatureDir = YES;
        }
    }
    NSString *signDir = [NSString stringWithFormat:@"%@/Signatures/", mailDataDir];
    NSString *pathOfAllSign = [NSString stringWithFormat:@"%@/AllSignatures.plist", signDir];
    NSString *pathOfAccountMap = [NSString stringWithFormat:@"%@/AccountsMap.plist", signDir];
    if (!isExistSignatureDir) {
        return nil;
    } else {
        
        if (![defaultManager fileExistsAtPath:pathOfAllSign] || ![defaultManager fileExistsAtPath:pathOfAccountMap]) {
            return nil;
        }
    }
    //read signatures from signature files
    NSMutableArray *allSignAry = [NSMutableArray arrayWithContentsOfFile:pathOfAllSign];
    for (NSDictionary *dic in allSignAry) {
        NSString *signatureName = [dic valueForKey:@"SignatureName"];
        [retAry addObject:signatureName];
    }
    return retAry;
}

+(NSString*)getSignatureUniqueIdWithSignName:(NSString *)signName {
    
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    NSString *homeDir = NSHomeDirectory();
    NSString *mailRootDir = [NSString stringWithFormat:@"%@/Library/Mail/", homeDir];
    NSArray *dirAry = [defaultManager contentsOfDirectoryAtPath:mailRootDir error:nil];
    NSString *versionDirName = @"V3";
    for (NSString *versionName in dirAry) {
        if ([versionName isEqualToString:@"V3"]) {
            versionDirName = @"V3";
            break;
        } else if ([versionName isEqualToString:@"V4"]) {
            versionDirName = @"V4";
            break;
        } else if ([versionName isEqualToString:@"V5"]) {
            versionDirName = @"V5";
            break;
        }
        
    }
    NSString *mailDataDir = [NSString stringWithFormat:@"%@/%@/MailData/", mailRootDir, versionDirName];
    NSArray *mailTmpData = [defaultManager contentsOfDirectoryAtPath:mailDataDir error:nil];
    BOOL isExistSignatureDir = NO;
    for (NSString *tmpStr in mailTmpData) {
        if ([tmpStr isEqualToString:@"Signatures"]) {
            isExistSignatureDir = YES;
        }
    }
    NSString *signDir = [NSString stringWithFormat:@"%@/Signatures/", mailDataDir];
    NSString *pathOfAllSign = [NSString stringWithFormat:@"%@/AllSignatures.plist", signDir];
    NSString *pathOfAccountMap = [NSString stringWithFormat:@"%@/AccountsMap.plist", signDir];
    if (!isExistSignatureDir) {
        return nil;
    } else {
        
        if (![defaultManager fileExistsAtPath:pathOfAllSign] || ![defaultManager fileExistsAtPath:pathOfAccountMap]) {
            return nil;
        }
    }
    //read signatures from signature files
    NSMutableArray *allSignAry = [NSMutableArray arrayWithContentsOfFile:pathOfAllSign];
    for (NSDictionary *dic in allSignAry) {
        NSString *signatureName = [dic valueForKey:@"SignatureName"];
        if ([signatureName isEqualToString:signName]) {
            return [dic valueForKey:@"SignatureUniqueId"];
        }
    }
    return nil;
}

+(BOOL)setLockSignFile:(NSString *)uniqueId  withLock:(BOOL)isLock {
    NSString *fileName = [NSString stringWithFormat:@"%@.mailsignature", uniqueId];
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    NSString *homeDir = NSHomeDirectory();
    NSString *mailRootDir = [NSString stringWithFormat:@"%@/Library/Mail/", homeDir];
    NSArray *dirAry = [defaultManager contentsOfDirectoryAtPath:mailRootDir error:nil];
    NSString *versionDirName = @"V3";
    for (NSString *versionName in dirAry) {
        if ([versionName isEqualToString:@"V3"]) {
            versionDirName = @"V3";
            break;
        } else if ([versionName isEqualToString:@"V4"]) {
            versionDirName = @"V4";
            break;
        } else if ([versionName isEqualToString:@"V5"]) {
            versionDirName = @"V5";
            break;
        }
        
    }
    NSString *mailDataDir = [NSString stringWithFormat:@"%@/%@/MailData/", mailRootDir, versionDirName];
    NSArray *mailTmpData = [defaultManager contentsOfDirectoryAtPath:mailDataDir error:nil];
    BOOL isExistSignatureDir = NO;
    for (NSString *tmpStr in mailTmpData) {
        if ([tmpStr isEqualToString:@"Signatures"]) {
            isExistSignatureDir = YES;
        }
    }
    NSString *signDir = [NSString stringWithFormat:@"%@/Signatures/", mailDataDir];
    NSString *signAllPath = [NSString stringWithFormat:@"%@/%@", signDir, fileName];
    NSDictionary *attribs = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:isLock] forKey:NSFileImmutable];
    NSError *error;
    [defaultManager setAttributes:attribs ofItemAtPath:signAllPath error:&error];
    if (error == nil) {
        return YES;
    }
    return NO;
}

+(NSString*)getRandomSignName {
    NSString *retVal = @"";
    for (int i = 0; i < 36; i++) {
        if (i == 8 || i==13 || i==18) {
            retVal = [retVal stringByAppendingString:@"-"];
            continue;
        }
        NSInteger onestr = [Util MyRandomIntegerBetween:0 max:9];
        retVal = [retVal stringByAppendingString:[NSString stringWithFormat:@"%ld", (long)onestr]];
    }
    return retVal;
}

+(NSInteger) MyRandomIntegerBetween:(NSInteger)min max:(NSInteger)max {
    return (random() % (max - min + 1)) + min;
}

+(BOOL)isRunningMailApp {
    NSString *mailProcInfo = [Util getMailProcessInfo];
    if ([mailProcInfo isEqualToString:@""]) {
        return NO;
    }
    return YES;
}

+(BOOL)killMailApplication {
    NSString *mailProcInfo = [Util getMailProcessInfo];
    if ([mailProcInfo isEqualToString:@""]) {
        return NO;
    }
    NSArray *aryTmp = [mailProcInfo componentsSeparatedByString:@" "];
    NSString *mailProcID = @"";
    for (int i = 1; i < aryTmp.count; i++) {
        NSString *tmpProcID = [aryTmp objectAtIndex:i];
        if (![tmpProcID isEqualToString:@""]) {
            mailProcID = [tmpProcID copy];
            break;
        }
    }
    
    NSTask *task = [[NSTask alloc] init];
    
    [task setLaunchPath:@"/bin/kill"];
    [task setArguments:[NSArray arrayWithObjects:mailProcID, nil]];
    
    NSPipe *aPipe = [[NSPipe alloc] init];
    [task setStandardOutput:aPipe];
    
    [task launch];
    [task waitUntilExit];
    // You can get rid of all the NSLog once you have finish testing
    NSData *outputData = [[aPipe fileHandleForReading] readDataToEndOfFile];
    NSString *outputString = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
    return YES;
}

+(BOOL)startMailApplication {
    NSString *mailProcInfo = [Util getMailProcessInfo];
    if (![mailProcInfo isEqualToString:@""]) {
        return NO;
    }
    system("/Applications/Mail.app/Contents/MacOS/Mail >/dev/null 2>&1 &");
    return YES;
}

+(NSString*)getMailProcessInfo {
    NSTask *task = [[NSTask alloc] init];
    NSString *commandStr = @"aux";
    [task setLaunchPath:@"/bin/ps"];
    [task setArguments:[NSArray arrayWithObjects:commandStr, nil]];
    
    NSPipe *aPipe = [[NSPipe alloc] init];
    [task setStandardOutput:aPipe];
    
    [task launch];
    [task waitUntilExit];
    
    
    // You can get rid of all the NSLog once you have finish testing
    NSData *outputData = [[aPipe fileHandleForReading] readDataToEndOfFile];
    NSString *outputString = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
    NSArray *tmpary = [outputString componentsSeparatedByString:@"\n"];
    NSString *mailProcInfo = @"";
    for (NSString *tmpProc in tmpary) {
        if ([tmpProc containsString:@"/Applications/Mail.app/Contents/MacOS/Mail"]) {
            mailProcInfo = [tmpProc copy];
            break;
        }
    }
    return mailProcInfo;
}

+(NSString *)getStringWithAppResourceFile:(NSString *)fileName {
    NSString *retVal = @"";
    NSArray *fileNameAry = [fileName componentsSeparatedByString:@"."];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:[fileNameAry objectAtIndex:0] ofType:[fileNameAry objectAtIndex:1]];
    retVal = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    return retVal;
}

+(NSString*)getStringWithFilePath:(NSString *)filePath {
    NSString *retVal = @"";
    retVal = [Util getEscapedString:[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil]];
    return retVal;
}

+(NSString*)getEscapedString:(NSString*)inputStr {
    if ([inputStr isEqualToString:@""] || inputStr == nil)
        return @"";
    const char *chars = [inputStr UTF8String];
    NSMutableString *escapedString = [NSMutableString string];
    while (*chars)
    {
        if (*chars == '\\')
            [escapedString appendString:@"\\\\"];
        else if (*chars == '"')
            [escapedString appendString:@"\\\""];
//        else if (*chars < 0x1F || *chars == 0x7F)
//            [escapedString appendFormat:@"\\u%04X", (int)*chars];
        else
            [escapedString appendFormat:@"%c", *chars];
        ++chars;
    }
    return escapedString;
}

+(BOOL)setSignatureOnOutlookWithHtmlFile:(NSString*) htmFilePath{
    //set signature for Mac Outlook
    NSDictionary *error1;
    NSString *deleteAppleScriptStr = @"tell application id \"com.microsoft.Outlook\"\ndelete signature \"Dynamic Signature\"\nend tell";
    NSAppleScript *deleteAppleScript = [[NSAppleScript alloc] initWithSource:deleteAppleScriptStr];
    [deleteAppleScript executeAndReturnError:&error1];
    
    NSString *htmStr = [Util getStringWithFilePath:htmFilePath];
    NSString * strScript = [Util getStringWithAppResourceFile:DEF_OUTLOOK_SIGN_INSTALLER_NAME_STR];
    NSString *completeScript = [NSString stringWithFormat:strScript, htmStr];
    NSAppleScript *appleScript = [[NSAppleScript alloc] initWithSource:completeScript];
    NSDictionary *error;
    [appleScript executeAndReturnError:&error];
    if (error == nil)
        return true;
    return false;
}

+(BOOL)setSignatureOnMailWithHtmlFile:(NSString*) htmFilePath signatureName:(NSString *)signatureName{
    //set signature for Mac Mail
    NSString *htmStr = [Util getStringWithFilePath:htmFilePath];
    NSString * strScript = [NSString stringWithFormat:[Util getStringWithAppResourceFile:DEF_MAIL_SIGN_INSTALLER_NAME_STR], signatureName];
    
    NSString *completeScript = [NSString stringWithFormat:strScript, htmStr];
    NSAppleScript *appleScript = [[NSAppleScript alloc] initWithSource:completeScript];
    NSDictionary *error;
    [appleScript executeAndReturnError:&error];
    if (error == nil) {
        return true;
    }
    
    return false;
}

+(void)openMailAppOnlyApp {
    NSString *strToOpen = @"tell application \"Mail\"\nactivate\nend tell";
    NSAppleScript *appleScript = [[NSAppleScript alloc] initWithSource:strToOpen];
    [appleScript executeAndReturnError:nil];
}

+(void)openMailApp {
    NSString *strToOpen = @"tell application \"Mail\"\nactivate\nend tell\ntell application \"System Events\"\ntell application process \"Mail\"\nkeystroke \",\" using command down\ndelay 0.5\n\ntell window 1\nclick button \"Signatures\" of toolbar 1\nend tell\nend tell\nend tell";
    NSAppleScript *appleScript = [[NSAppleScript alloc] initWithSource:strToOpen];
    [appleScript executeAndReturnError:nil];
}

+(void)openOutlookApp {
    NSString *strToOpen = @"tell application \"Microsoft Outlook\"\nactivate\nend tell\ntell application \"System Events\"\ntell application process \"Microsoft Outlook\"\nkeystroke \",\" using command down\ndelay 0.5\n\ntell window 1\nclick button 7\nend tell\nend tell\nend tell";
    NSAppleScript *appleScript = [[NSAppleScript alloc] initWithSource:strToOpen];
    [appleScript executeAndReturnError:nil];
}

+ (NSString *)uploadXmlFileForEWSAPIWithHtml:(NSString *)filePath {
    NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
    NSString *urlString =[NSString stringWithFormat:@"http://www.yoursite.com/accept.php"];
    // to use please use your real website link.
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = @"_187934598797439873422234";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    [request setValue:@"text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
    [request setValue:@"Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_5) AppleWebKit/536.26.14 (KHTML, like Gecko) Version/6.0.1 Safari/536.26.14" forHTTPHeaderField:@"User-Agent"];
    [request setValue:@"http://google.com" forHTTPHeaderField:@"Origin"];
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"Content-Length %lu\r\n\r\n", (unsigned long)[data length] ] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"picture\"; filename=\"%@.png\"\r\n", @"newfile"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    [body appendData:[NSData dataWithData:data]];
    
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    [request setHTTPBody:body];
    [request addValue:[NSString stringWithFormat:@"%lu", (unsigned long)[body length]] forHTTPHeaderField:@"Content-Length"];
    
    
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    NSLog(@"%@", returnString);
    return returnString;
}
@end
