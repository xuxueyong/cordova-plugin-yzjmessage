//
//  YZJMessageSDKManager.h
//
//  Created by hour on 2019/5/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YZJMessageSDKConfig: NSObject

// 基础域名
@property (nonatomic, strong, nonnull) NSString *baserUrl;
@property (nonatomic, strong, nonnull) NSString *baserImgUrl;

/// mars
@property (nonatomic, strong, nonnull) NSString *pubKey;
@property (nonatomic, strong, nonnull) NSString *longLinkAddress;
@property (nonatomic, assign) unsigned short longLinkPort;
@property (nonatomic, strong, nonnull) NSString *shortLinkAddress;
@property (nonatomic, assign) unsigned short shortLinkPort;

// UI 配置
@property (nonatomic, strong, nullable) UIImage *groupListNavLeftIconImage; // 群组列表导航栏左侧头像图片
@property (nonatomic, strong, nullable) NSString *groupListNavTitle;        // 群组列表导航栏标题，默认："消息"
@property (nonatomic, strong, nullable) UIImage *groupListNavBackImage;     // 群组列表导航背景图片，默认："蓝色"

// + pop 添加按钮
/** eg:
    KDPlusMenuViewModel *chat = [KDPlusMenuViewModel modelWithTitle:NSLocalizedStringFromTableInBundle(@"发起群聊", nil, [YZJLocalized bundle], @"") imageName:@"menu_new_btn_session_normal" selectImageName:@"menu_btn_session_press" selection:^{
 
    ];
*/
@property (nonatomic, strong, nullable) NSArray *plusMenuArray;


//@property (nonatomic, strong, nonnull) NSString *openToken;
//@property (nonatomic, strong, nonnull) NSString *userAgent;
//@property (nonatomic, strong, nonnull) NSString *clientId;

//标记 YES是员工端 NO是客户端
@property(nonatomic,assign) BOOL flag;
@end

//typedef void(^YZJTimelineBlock)(void);
//
@interface YZJTimelineConfig: NSObject
//
///// 标题
//@property (nonatomic, strong, nonnull) NSString *titleName;
//
///// 左边按钮的图片 和 点击操作
//@property (nonatomic, strong, nonnull) UIImage *leftImage;
//@property (nonatomic, copy, nonnull) YZJTimelineBlock leftBlock;
//
@end


@protocol YZJMessageSDKManagerDelegate <NSObject>

/// 未读数变化时会调用
- (void)unreadCountChanged:(NSUInteger)unreadCount;

/// 导航栏左侧头像点击事件
@optional
- (void)onGroupListLeftIconTap;

@end

@interface YZJMessageSDKManager : NSObject


+ (instancetype)shared;

/// 初始参数的配置 只调用一次
- (void)setupWithConfig:(YZJMessageSDKConfig *)config
               delegate:(id<YZJMessageSDKManagerDelegate>)delegate;

/// 用户登录，登录成功后会执行数据初始化操作，建立长连
- (void)loginWithUsername:(NSString *)username password:(NSString *)password;

/// 用户退出登录
- (void)logout;

- (YZJMessageSDKConfig *)config;

- (id<YZJMessageSDKManagerDelegate>)delegate;

/// 消息列表 view controller 注意是：UINavigationController
- (UIViewController *)timelineVC;
- (UINavigationController *)timelineNavVC;

/// 收到推送后 打开推送消息
- (void)openMsgWithGroupId:(NSString *)groupId;

// 获取 token
- (NSMutableDictionary *)getTokenByUserName:(NSString *)userName password:(NSString *)password;
// 双人聊天
- (void)openPersonChat:(NSString *)personNo;

/// 上传 devieceToke flag 标记 YES 为员工端和 NO为客户端
- (void)registerDeviceToken:(NSData *)tokenData;

/**
 * 分享文字接口
 *
 *  @param shareText  分享的文字内容
 */
- (void)shareToChatWithText:(NSString *)text
            addressbookType:(NSString *)addressbookType
             viewController:(UIViewController *)viewController ;

/**
 * 分享图片接口
 *
 *  @param shareText  分享的图片的URL
 */
- (void)shareToChatWithThumbnailUrl:(NSString *)thumbnailUrl
                          originURL:(NSString *)originalUrl
                    addressbookType:(NSString *)addressbookType
                     viewController:(UIViewController *)viewController ;
/**
 * 分享新闻接口
 *
 *  @param shareText  分享的图片的地址
 */
- (void)shareToChatWithTitle:(NSString *)title
                     content:(NSString *)content
                    thumbUrl:(NSString *)thumbUrl
                     webPage:(NSString *)webPage
                     appName:(NSString *)appName
             addressbookType:(NSString *)addressbookType
              viewController:(UIViewController *)viewController ;
/**
 * 分享文件接口
 *
 *  @param shareText  分享的图片的data
 */
- (void)shareToChatWithFileData:(NSData *)fileData
                addressbookType:(NSString *)addressbookType
                 viewController:(UIViewController *)viewController ;

// 推送
- (void)registerRemoteNotifaction;

@end


NS_ASSUME_NONNULL_END
