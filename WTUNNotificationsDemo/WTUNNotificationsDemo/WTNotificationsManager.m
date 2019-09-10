//
//  WTNotificationsManager.m
//  WTUNNotificationsDemo
//
//  Created by tyler on 9/10/19.
//  Copyright © 2019 wzt. All rights reserved.
//

#import "WTNotificationsManager.h"

void myCleanupBlock(__strong void(^*block)(void)){
    (*block)();
}


@implementation WTNotificationsManager

#pragma mark - IOS 10 处理前台收到通知
+(void)handleForegroundPush:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    __block UNNotificationPresentationOptions option=UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert;
    UNNotificationPresentationOptions *optionPointer=&option;
    onExit{
        completionHandler(*optionPointer);
    };
    
    NSDictionary *userinfo = notification.request.content.userInfo;
    UNNotificationRequest *request = notification.request;
    UNNotificationContent *content = request.content;
    
    NSString *title = content.title;
    NSString *subtitle =content.subtitle;
    NSString *body=content.body;
    NSString *categoryIdentifier = content.categoryIdentifier;
    UNNotificationSound *sound = content.sound;
    NSNumber *badge = content.badge;
    NSString *threadIdentifier = content.threadIdentifier;
    
    
    
    if([notification.request.trigger isKindOfClass:UNPushNotificationTrigger.class]){
        //远程通知
//        [self handleForegroundPush:userinfo cb:^(BCBaseSCTNoti *basenoti) {
//            //不在通知栏提示
//            if(basenoti && !basenoti.showPushWhenForeground){
//                option=UNNotificationPresentationOptionNone;
//            }
//        }];
        
    }else{
        //本地通知
        
        NSLog(@"iOS10 收到本地通知:{\n title:%@,\n subtitle:%@,\n body:%@，\n categoryIdentifier:%@，\n sound：%@，\n badge：%@，\n threadIdentifier：%@，\n launchImageName：%@，\n attachments：%@，\n userInfo：%@\n}",title,subtitle,body,categoryIdentifier,sound,badge,threadIdentifier,content.launchImageName,content.attachments,userinfo);
    }
    
}

@end
