//
//  WTNotificationsManager.h
//  WTUNNotificationsDemo
//
//  Created by tyler on 9/10/19.
//  Copyright © 2019 wzt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UserNotifications/UserNotifications.h>

void myCleanupBlock(__strong void(^*block)(void));

#define onExit \
__strong void(^block)(void) __attribute__((cleanup(myCleanupBlock), unused)) = ^


@interface WTNotificationsManager : NSObject

#pragma mark - IOS 10 处理前台收到通知
+(void)handleForegroundPush:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler;

@end

