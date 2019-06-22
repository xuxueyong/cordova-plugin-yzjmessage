/*
 *  暴露给js调用的方法
 */

#import "CDVYZJMessage.h"
#import "YZJMessageSDKManager.h"

@interface CDVYZJMessage () <YZJMessageSDKManagerDelegate>
{
    // 是否第一次调用
    BOOL _isFirstLaunch;
    // 发起聊天的员工号
    NSString *_otherPersonNo;
    // 未读消息数
    NSString *_unreadCount;
    // 推送deviceToken
    NSString *_deviceTokenStr;
}

@end

@implementation CDVYZJMessage

// 获取token， 和 userID， 使用参数 员工工号, 密码
- (void)getToken:(CDVInvokedUrlCommand*)command {
    NSLog(@"开始获取token");
    
    // 初始化只做一次
    if (!_isFirstLaunch) {
        [self setup];
        _isFirstLaunch = YES;
    }
    
    _deviceTokenStr = command.arguments[2];
    
    YZJMessageSDKManager *login = [YZJMessageSDKManager shared];
    NSDictionary *dic = [login getTokenByUserName:@"a0018442" password: @"Kingdee.1234"];
    //    NSDictionary *dic = [login getTokenByUserName:command.arguments[0] password: command.arguments[1]];
    CDVPluginResult* pluginResult = nil;
    NSString *result = nil;
    if([[dic objectForKey:@"message"] isEqualToString:@"error"]){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logingSuccessGetToken:) name:@"yzjmessage_login_result" object:nil];
        result=@"errror";
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:result];
        
    } else {
        result= [NSString stringWithFormat:@"%@,%@",[dic objectForKey:@"token"],[dic objectForKey:@"userID"]];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
    }
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)logingSuccessGetToken:(NSNotification *)info {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"yzjmessage_login_result" object:nil];
    NSDictionary *dict = info.userInfo;
    NSError *error;
    NSData *jsonData   = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    NSString *jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"返回的token字典信息：----%@",info);
    
    // 上传deviceToken, 用于推送
    NSData *data = [_deviceTokenStr dataUsingEncoding:NSUTF8StringEncoding];
    [[YZJMessageSDKManager  shared] registerDeviceToken:data];
    
    [self.commandDelegate evalJs:[NSString stringWithFormat:@"cordova.fireDocumentEvent('getTokenSuccess',%@)",jsonString]];
}

// 会话列表
- (void)openMessageListView:(CDVInvokedUrlCommand*)command {
    YZJMessageSDKManager *login = [YZJMessageSDKManager shared];
    NSDictionary *dic = [login getTokenByUserName:@"a0018442" password: @"Kingdee.1234"];
    //    NSDictionary *dic = [login getTokenByUserName:command.arguments[0] password: command.arguments[1]];
    if([[dic objectForKey:@"message"] isEqualToString:@"error"]){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logingSuccessOpenMessageListView:) name:@"yzjmessage_login_result" object:nil];
    } else {
        [self openMessageListVC];
    }
}

- (void)logingSuccessOpenMessageListView:(NSNotification *)info {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"yzjmessage_login_result" object:nil];
    NSDictionary *dict = info.userInfo;
    if ([dict[@"message"] isEqualToString:@"success"]) {
        [self openMessageListVC];
        [self.commandDelegate evalJs:@"cordova.fireDocumentEvent('LoginSuccess')"];
    }
}

- (void)openMessageListVC {
    UINavigationController *nav = [[YZJMessageSDKManager shared] timelineNavVC];
    [[[UIApplication sharedApplication] keyWindow].rootViewController presentViewController:nav animated:YES completion:nil];
}

// 两人会话聊天
- (void)openPersonMessageView:(CDVInvokedUrlCommand*)command {
    _otherPersonNo = command.arguments[1];
    
    YZJMessageSDKManager *login = [YZJMessageSDKManager shared];
    NSDictionary *dic = [login getTokenByUserName:@"a0018442" password: @"Kingdee.1234"];
    //    NSDictionary *dic = [login getTokenByUserName:command.arguments[0] password: command.arguments[1]];
    if([[dic objectForKey:@"message"] isEqualToString:@"error"]){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logingSuccessOpenPersonMessageView:) name:@"yzjmessage_login_result" object:nil];
    } else {
        YZJMessageSDKManager *login = [YZJMessageSDKManager shared];
        //        [login openPersonChat:command.arguments[2]];
        [login openPersonChat:@"a0018442"];
    }
}

- (void)logingSuccessOpenPersonMessageView:(NSNotification *)info {
    YZJMessageSDKManager *login = [YZJMessageSDKManager shared];
    [login openPersonChat:_otherPersonNo];
}

// 分享
- (void)shareMessageToSDK:(CDVInvokedUrlCommand*)command
{
    NSDictionary *tempdic;
    if (command.arguments.count>=3) {
        if ([command.arguments[2] rangeOfString:@"shareText"].location != NSNotFound) {
            NSMutableArray *arry = [[NSMutableArray alloc]init];
            [arry addObject:command.arguments[0]];
            tempdic = @{@"key":arry,@"shareText":command.arguments[1],@"addressbooktype":command.arguments[2]};
        } else if ([command.arguments[2] rangeOfString:@"sharePicture"].location != NSNotFound){
            NSMutableArray *arry = [[NSMutableArray alloc]init];
            [arry addObject:command.arguments[0]];
            tempdic = @{@"key":arry,@"sharePicture":command.arguments[1],@"addressbooktype":command.arguments[2]};
        } else if ([command.arguments[2] rangeOfString:@"shareNews"].location != NSNotFound){
            NSMutableArray *arry = [[NSMutableArray alloc]init];
            [arry addObject:command.arguments[0]];
            //  工号，appName，shareNews,标题，内容，图片，网址
            tempdic = @{@"key":arry,@"shareNews":@"ShareNews",@"appName":command.arguments[1],@"title":command.arguments[3],@"content":command.arguments[4],@"thumhUrl":command.arguments[5],@"pageUrl":command.arguments[6],@"addressbooktype":command.arguments[7]};
        } else if ([command.arguments[2] rangeOfString:@"jpush"].location != NSNotFound){
            NSMutableArray *arry = [[NSMutableArray alloc]init];
            [arry addObject:command.arguments[0]];
            //  工号，appName，shareNews,标题，内容，图片，网址
            tempdic = @{@"key":arry,@"mode":@"1",@"groupId":command.arguments[3],@"jpush":@"jpush"};
        } else {
            tempdic = @{@"key":command.arguments};
        }
    } else {
        tempdic = @{@"key":command.arguments};
    }
    
    // 如果包含分享内容
    YZJMessageSDKManager *create = [YZJMessageSDKManager shared];
    UIViewController *presentParentVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    if ([tempdic objectForKey:@"shareText"] != nil) {
        [create shareToChatWithText:[tempdic objectForKey:@"shareText"] addressbookType:[tempdic objectForKey:@"addressbooktype"] viewController:presentParentVC];
        
    } else if ([tempdic objectForKey:@"sharePicture"] != nil) {
        [create shareToChatWithThumbnailUrl:[tempdic objectForKey:@"sharePicture"] originURL:[tempdic objectForKey:@"sharePicture"] addressbookType:[tempdic objectForKey:@"addressbooktype"] viewController:presentParentVC];
        
    } else if ([tempdic objectForKey:@"shareNews"] != nil) {
        //工号，appName，shareNews,标题，内容，图片，网址
        [create shareToChatWithTitle:[tempdic objectForKey:@"title"] content:[tempdic objectForKey:@"content"] thumbUrl:[tempdic objectForKey:@"thumhUrl"] webPage:[tempdic objectForKey:@"pageUrl"] appName:[tempdic objectForKey:@"appName"] addressbookType:[tempdic objectForKey:@"addressbooktype"] viewController:presentParentVC];
        
    } else if ([tempdic objectForKey:@"jpush"] != nil) { // 推送
        
    } else if (([tempdic objectForKey:@"key"] != nil)) { // 会话列表， 使用员工号参数
        if (command.arguments.count == 1) { // 1. 列表 1个参数
            
            UINavigationController *nav = [[YZJMessageSDKManager shared] timelineNavVC];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, int64_t (3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:nav animated:YES completion:nil];
            });
        } else { // 2. 单个私聊， 2个参数
            [[YZJMessageSDKManager shared] openPersonChat:@"a0018442"];
        }
    }
}

// 获取未读消息数
- (void)getUnreadCount:(CDVInvokedUrlCommand*)command {
    NSDictionary *dict = @{@"unreadCount": _unreadCount};
    NSError *error;
    NSData *jsonData   = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    NSString *jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"未读消息数：----%@",dict);
    
    [self.commandDelegate evalJs:[NSString stringWithFormat:@"cordova.fireDocumentEvent('getUnreadCountSuccess',%@)",jsonString]];
}

#pragma mark - 初始化域名配置
- (void)setup {
    YZJMessageSDKConfig *config = [[YZJMessageSDKConfig alloc] init];
    
    config.baserUrl = @"https://i.haier.net";
    config.baserImgUrl = @"https://i.haier.net/";
    
    config.pubKey = @"-----BEGIN PUBLIC KEY-----\nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDG2wgfTaiRBjI9Js4x3e9rOmKW\nCr8ScNnuzrkj7AnJb7JzS8NPgWnqSVFRLrXQrgofj3fARcEWXrcSC638k9EVgdWG\njPtloPenThEFMSN/Lh2wxH3jBF8N2T/vvGl3O19Dz1pxrwCgr8zq7u5mJaiouLYT\nIgta84Bf3mcCErb7cQIDAQAB\n-----END PUBLIC KEY-----";
    config.longLinkAddress = @"i.haier.net";
    config.longLinkPort = 20080;
    config.shortLinkAddress = @"i.haier.net";
    config.shortLinkPort = 20443;
    
    [[YZJMessageSDKManager shared] setupWithConfig:config delegate:self];
}

#pragma mark - YZJMessageSDKManagerDelegate

- (void)onGroupListLeftIconTap {
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *presentVC = vc.presentedViewController;
    [presentVC dismissViewControllerAnimated:YES completion:nil];
}

- (void)unreadCountChanged:(NSUInteger)unreadCount {
    _unreadCount = [NSString stringWithFormat:@"%ld", unreadCount];
}

#pragma mark - 退出登录
- (void)messageLogout:(CDVInvokedUrlCommand*)command {
    [[YZJMessageSDKManager shared] logout];
}

@end


