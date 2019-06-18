//
//  YZJLoginManager.h
//  Pods-YZJLogin_Example
//
//  Created by hour on 2019/2/21.
//

#import <Foundation/Foundation.h>

typedef void(^LoginBlock)(NSDictionary<NSString *, id> *);
typedef void(^LogoutBlock)();

NS_ASSUME_NONNULL_BEGIN

@interface YZJLoginManager : NSObject

+ (instancetype)sharedInstance;

- (void)login;

- (void)logout;

- (BOOL)isLogin;

@end

NS_ASSUME_NONNULL_END
