//
//  AppConfig.h
//  EmailSignature
//
//  Created by Alexei Gura on 12/5/17.
//  Copyright © 2017 Alexei Gura. All rights reserved.
//

#ifndef AppConfig_h
#define AppConfig_h

#define SERVER_ADDR @"http://192.168.12.76:8080/dynasignature-api/api.php?email=" //for test api
#define IIS_SERVER  @"http://169.254.110.60/pub/Service.svc"
#define SERVER_SOAP_ACTION  @"http://tempuri.org/IService/SetSignature"
//#define SERVER_ADDR @"http://www.dynasend.com/signatures/get.php?email=" //for real api


#define EDIT_SIGN_SERVER_ADDR   @"http://www.dynasend.com/signatures/redir.php?email="

#define DEF_FIRST_RUN_COMPLETE          @"first_run_complete"
#define DEF_REQUEST_TIME_STEP           @"request_time_step"
#define DEF_USER_EMAIL_ADDRESS          @"user_email_addr"
#define DEF_LAST_REQUEST_TIME           @"last_request_time"
#define DEF_SYNC_WITH_OTHER             @"sync_with_other"
#define DEF_SYNC_WITH_WHAT              @"sync_with_what"
#define DEF_SYNC_WITH_PASS              @"sync_with_pass"
#define DEF_MAIL_SIGN_TO_UPDATE         @"mail_sign_to_update"

#define DEF_MAIL_SIGN_INSTALLER_NAME        @"mac-signature-installer.command"
#define DEF_OUTLOOK_SIGN_INSTALLER_NAME    @"OutlookSigs.scpt"
#define DEF_OUTLOOK_SIGN_INSTALLER_NAME_STR    @"OutlookSigns.txt"
#define DEF_MAIL_SIGN_INSTALLER_NAME_STR    @"MailSIgnScript.txt"
#define DEF_MAIL_MAKE_SIGNATURE_DIRECTORY_USING_SCRIPT    @"MailMakeSignatureDirect.txt"

#define DEF_SIGNATURE_NAME                  @"Dynamic Signature"
#define DEF_CONNECT_DURATION        1
#define DEF_LBL_SELECT_SIGNATURE            @"Select the signature"

#endif /* AppConfig_h */
