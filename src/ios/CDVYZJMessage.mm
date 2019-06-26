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
    
//    _deviceTokenStr = command.arguments[2];
    
    YZJMessageSDKManager *login = [YZJMessageSDKManager shared];
//  NSDictionary *dic = [login getTokenByUserName:@"A0015867" password: @"Kingdee123"];
    NSDictionary *dic = [login getTokenByUserName:command.arguments[0] password: command.arguments[1]];
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
//    NSData *data = [_deviceTokenStr dataUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"devoice_token_key"];
    [[YZJMessageSDKManager  shared] registerDeviceToken:data];
    
    [self.commandDelegate evalJs:[NSString stringWithFormat:@"cordova.fireDocumentEvent('getTokenSuccess',%@)",jsonString]];
}

// 会话列表
- (void)openMessageListView:(CDVInvokedUrlCommand*)command {
    YZJMessageSDKManager *login = [YZJMessageSDKManager shared];
//    NSDictionary *dic = [login getTokenByUserName:@"A0015867" password: @"Kingdee123"];
    NSDictionary *dic = [login getTokenByUserName:command.arguments[0] password: command.arguments[1]];
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
    dispatch_async(dispatch_get_main_queue(), ^{
        UINavigationController *nav = [[YZJMessageSDKManager shared] timelineNavVC];
        if (!self.viewController.presentedViewController) {
            [self.viewController presentViewController:nav animated:YES completion:nil];
        }
    });
}

// 两人会话聊天
- (void)openPersonMessageView:(CDVInvokedUrlCommand*)command {
    _otherPersonNo = command.arguments[1];
    
    YZJMessageSDKManager *login = [YZJMessageSDKManager shared];
//    NSDictionary *dic = [login getTokenByUserName:@"A0015867" password: @"Kingdee123"];
    NSDictionary *dic = [login getTokenByUserName:command.arguments[0] password: command.arguments[1]];
    if([[dic objectForKey:@"message"] isEqualToString:@"error"]){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logingSuccessOpenPersonMessageView:) name:@"yzjmessage_login_result" object:nil];
    } else {
        YZJMessageSDKManager *login = [YZJMessageSDKManager shared];
        [login openPersonChat:command.arguments[2]];
//        [login openPersonChat:@"a0018442"];
    }
}

- (void)logingSuccessOpenPersonMessageView:(NSNotification *)info {
    YZJMessageSDKManager *login = [YZJMessageSDKManager shared];
    [login openPersonChat:_otherPersonNo];
}

// 分享
- (void)shareMessageToSDK:(CDVInvokedUrlCommand*)command
{
    if (command.arguments.count == 8) {
        NSDictionary *tempdic;
        NSMutableArray *arry = [[NSMutableArray alloc]init];
        [arry addObject:command.arguments[0]];
        //  工号，appName，shareNews,标题，内容，图片，网址
        tempdic = @{@"key":command.arguments[0],@"shareNews":@"ShareNews",@"appName":command.arguments[2],@"title":command.arguments[4],@"content":command.arguments[5],@"thumhUrl":command.arguments[6],@"pageUrl":command.arguments[7],@"addressbooktype":@"预留"};
        
        if ([tempdic objectForKey:@"shareNews"] != nil) {
            YZJMessageSDKManager *manger = [YZJMessageSDKManager shared];
            UIViewController *presentParentVC = [UIApplication sharedApplication].keyWindow.rootViewController;
            [manger shareToChatWithTitle:[tempdic objectForKey:@"title"] content:[tempdic objectForKey:@"content"] thumbUrl:[tempdic objectForKey:@"thumhUrl"] webPage:[tempdic objectForKey:@"pageUrl"] appName:[tempdic objectForKey:@"appName"] addressbookType:[tempdic objectForKey:@"addressbooktype"] viewController:presentParentVC];
        }
    } else {
        NSLog(@"分享传参有误");
    }
}

// 获取未读消息数
- (void)getUnreadCount:(CDVInvokedUrlCommand*)command {
    if (!_unreadCount) {
        _unreadCount = @"0";
    }
    NSDictionary *dict = @{@"unreadCount": _unreadCount};
    NSError *error;
    NSData *jsonData   = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    NSString *jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"未读消息数：----%@",dict);
    
    [self.commandDelegate evalJs:[NSString stringWithFormat:@"cordova.fireDocumentEvent('getUnreadCountSuccess',%@)",jsonString]];
}

// 打开推送消息
- (void)openMessageByGroupID:(CDVInvokedUrlCommand*)command {
    [[YZJMessageSDKManager shared] openMsgWithGroupId:command.arguments[2]];
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
    config.flag = YES;
    
    [[YZJMessageSDKManager shared] setupWithConfig:config delegate:self];
}

#pragma mark - YZJMessageSDKManagerDelegate

- (void)onGroupListLeftIconTap {
    UIViewController *presentVC = self.viewController.presentedViewController;
    [presentVC dismissViewControllerAnimated:YES completion:nil];
}

- (void)unreadCountChanged:(NSUInteger)unreadCount {
    _unreadCount = [NSString stringWithFormat:@"%lu", (unsigned long)unreadCount];
}

#pragma mark - 退出登录
- (void)messageLogout:(CDVInvokedUrlCommand*)command {
    [[YZJMessageSDKManager shared] logout];
}

@end


