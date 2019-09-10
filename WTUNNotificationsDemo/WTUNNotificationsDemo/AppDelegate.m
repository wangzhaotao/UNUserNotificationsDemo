//
//  AppDelegate.m
//  WTUNNotificationsDemo
//
//  Created by tyler on 9/10/19.
//  Copyright © 2019 wzt. All rights reserved.
//

#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>
#import "WTNotificationsManager.h"

#define IOS10 [[[UIDevice currentDevice]systemVersion] floatValue] >= 10.0
#define iApp [UIApplication sharedApplication]

@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //
    //注册推送
    [self setupPushNotification];
    
    
    return YES;
}



- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}




#pragma mark - notification
-(void)setupPushNotification{
    if(IOS10){
        UNUserNotificationCenter *cent = [UNUserNotificationCenter currentNotificationCenter];
        cent.delegate=self;
        [cent requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if(granted)
            {
                NSLog(@"授权成功");
            }
        }];
        
        //cate01
        //        UNNotificationAction *action1=[UNNotificationAction actionWithIdentifier:@"openAction" title:@"Open" options:(UNNotificationActionOptionAuthenticationRequired)];
        UNNotificationAction *action2=[UNNotificationAction actionWithIdentifier:@"ignoreAction" title:@"Ignore" options:(UNNotificationActionOptionDestructive)];
        UNNotificationCategory *cate=[UNNotificationCategory categoryWithIdentifier:@"cateiden" actions:@[action2] intentIdentifiers:@[@""] options:UNNotificationCategoryOptionCustomDismissAction];
        
        [cent setNotificationCategories:[NSSet setWithObjects:cate,nil]];
        [cent getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            NSLog(@"setting:%@",settings);
        }];
    }else{
        
        NSLog(@"Requesting permission for push notifications..."); // iOS 8
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:
                                                UIUserNotificationTypeAlert | UIUserNotificationTypeBadge |
                                                UIUserNotificationTypeSound categories:nil];
        [UIApplication.sharedApplication registerUserNotificationSettings:settings];
        
    }
    //request token
    //[iApp registerForRemoteNotifications];
    //[iApp setApplicationIconBadgeNumber:1];
    [iApp setApplicationIconBadgeNumber:-1];
}

#pragma mark - UNUserNotificationCenterDelegate
//前台收到通知
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    NSLog(@"+++ willPresentNotification:");
    
    [WTNotificationsManager handleForegroundPush:center willPresentNotification:notification withCompletionHandler:completionHandler];
}

//用户点击通知
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler{
    NSLog(@"+++ didReceiveNotificationResponse:");
    completionHandler();
}

#pragma mark - didRegisterForRemoteNotificationsWithDeviceToken&xunmei Delegate
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(nonnull NSData *)deviceToken {
    
    NSLog(@"Registration successful, bundle identifier: %@, device token: %@",
          [NSBundle.mainBundle bundleIdentifier], deviceToken);
    NSString *_deviceToken = [[[[deviceToken description]
                      stringByReplacingOccurrencesOfString: @"<" withString: @""]
                     stringByReplacingOccurrencesOfString: @">" withString: @""]
                    stringByReplacingOccurrencesOfString: @" " withString: @""];
    NSUserDefaults *devid_init=[NSUserDefaults standardUserDefaults];
    
    [devid_init setObject:_deviceToken forKey:@"devicetoken"];
    [devid_init synchronize];
    NSLog(@"the generated device token string is : %@", _deviceToken);
    
    //[FIRMessaging messaging].APNSToken = deviceToken;
}
// Get Device Token Fail
- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    
    
    NSString *str = [NSString stringWithFormat: @"Error: %@",err];
    NSLog(@"%@",str);
}

@end
