//
//  ViewController.m
//  WTUNNotificationsDemo
//
//  Created by tyler on 9/10/19.
//  Copyright © 2019 wzt. All rights reserved.
//

#import "ViewController.h"
#import <UserNotifications/UserNotifications.h>

static NSString *kPushNotificationId = @"com.wzt.push_test";

@interface ViewController ()
- (IBAction)addOneLocalNotificationAction:(UIButton *)sender;
- (IBAction)updateLocalNotificationAction:(UIButton *)sender;
- (IBAction)removeLocalNotificationAction:(UIButton *)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //
    
    
    
}


- (IBAction)addOneLocalNotificationAction:(UIButton *)sender {
    
    NSString *imgName = nil;
    static int flag = 0;
    if (flag%2==0) {
        //imgName = @"timg.png";
    }else{
        imgName = @"onevcat.jpg";
    }
    flag++;
    
    [self pushNotification_IOS_10_Body:@"这是一条本地推送" promptTone:nil soundName:nil imageName:imgName movieName:nil Identifier:kPushNotificationId];
}

- (IBAction)updateLocalNotificationAction:(UIButton *)sender {
    
    UNUserNotificationCenter * center  = [UNUserNotificationCenter currentNotificationCenter];
    [center getDeliveredNotificationsWithCompletionHandler:^(NSArray<UNNotification *> * _Nonnull notifications) {
        //获取已展示的推送
        for (UNNotification *notification in notifications) {
            UNNotificationRequest *request = notification.request;
            if ([request.identifier isEqualToString:kPushNotificationId]) {
                UNMutableNotificationContent *content = [request.content mutableCopy];
                //
                NSError * error;
                NSString * path = [[NSBundle mainBundle]pathForResource:@"onevcat" ofType:@"jpg"];
                UNNotificationAttachment * attachment = [UNNotificationAttachment attachmentWithIdentifier:[NSString stringWithFormat:@"notificationAtt_%@",@"jpg"] URL:[NSURL fileURLWithPath:path] options:nil error:&error];
                if (error) {
                    NSLog(@"attachment error %@", error);
                }
                content.attachments = @[attachment];
                content.launchImageName = @"onevcat.jpg";
            }
        }
    }];
//    [center getPendingNotificationRequestsWithCompletionHandler:^(NSArray<UNNotificationRequest *> * _Nonnull requests) {
//        //获取
//    }];
}

- (IBAction)removeLocalNotificationAction:(UIButton *)sender {
    
    UNUserNotificationCenter * center  = [UNUserNotificationCenter currentNotificationCenter];
    
    //[center removeDeliveredNotificationsWithIdentifiers:@[kPushNotificationId]];
    [center removePendingNotificationRequestsWithIdentifiers:@[kPushNotificationId]];
    //[center removeAllDeliveredNotifications];
}





/**
 IOS 10的通知   推送消息 支持的音频 <= 5M(现有的系统偶尔会出现播放不出来的BUG)  图片 <= 10M  视频 <= 50M  ，这些后面都要带上格式；
 @param body 消息内容
 @param promptTone 提示音
 @param soundName 音频
 @param imageName 图片
 @param movieName 视频
 @param identifier 消息标识
 */
-(void)pushNotification_IOS_10_Body:(NSString *)body
                         promptTone:(NSString *)promptTone
                          soundName:(NSString *)soundName
                          imageName:(NSString *)imageName
                          movieName:(NSString *)movieName
                         Identifier:(NSString *)identifier {
    //获取通知中心用来激活新建的通知
    UNUserNotificationCenter * center  = [UNUserNotificationCenter currentNotificationCenter];
    
    UNMutableNotificationContent * content = [[UNMutableNotificationContent alloc]init];
    
    content.body = body;
    //通知的提示音
    if (promptTone && [promptTone containsString:@"."]) {
        
        UNNotificationSound *sound = [UNNotificationSound soundNamed:promptTone];
        content.sound = sound;
        
    }
    
    __block UNNotificationAttachment *imageAtt;
    __block UNNotificationAttachment *movieAtt;
    __block UNNotificationAttachment *soundAtt;
    
    if (imageName && [imageName containsString:@"."]) {
        
        [self addNotificationAttachmentContent:content attachmentName:imageName options:nil withCompletion:^(NSError *error, UNNotificationAttachment *notificationAtt) {
            
            imageAtt = [notificationAtt copy];
        }];
    }
    
    if (soundName && [soundName containsString:@"."]) {
        
        
        [self addNotificationAttachmentContent:content attachmentName:soundName options:nil withCompletion:^(NSError *error, UNNotificationAttachment *notificationAtt) {
            
            soundAtt = [notificationAtt copy];
            
        }];
        
    }
    
    if (movieName && [movieName containsString:@"."]) {
        // 在这里截取视频的第10s为视频的缩略图 ：UNNotificationAttachmentOptionsThumbnailTimeKey
        [self addNotificationAttachmentContent:content attachmentName:movieName options:@{@"UNNotificationAttachmentOptionsThumbnailTimeKey":@10} withCompletion:^(NSError *error, UNNotificationAttachment *notificationAtt) {
            
            movieAtt = [notificationAtt copy];
            
        }];
        
    }
    
    NSMutableArray * array = [NSMutableArray array];
    if (soundAtt) {
        [array addObject:soundAtt];
    }
    if (imageAtt) {
        [array addObject:imageAtt];
    }
    if (movieAtt) {
        [array addObject:movieAtt];
    }
    content.attachments = array;
    
    //添加通知下拉动作按钮
    NSMutableArray * actionMutableArray = [NSMutableArray array];
    UNNotificationAction * actionA = [UNNotificationAction actionWithIdentifier:@"identifierNeedUnlock" title:@"进入应用" options:UNNotificationActionOptionAuthenticationRequired];
    UNNotificationAction * actionB = [UNNotificationAction actionWithIdentifier:@"identifierRed" title:@"忽略" options:UNNotificationActionOptionDestructive];
    [actionMutableArray addObjectsFromArray:@[actionA,actionB]];
    
    if (actionMutableArray.count > 1) {
        
        UNNotificationCategory * category = [UNNotificationCategory categoryWithIdentifier:@"categoryNoOperationAction" actions:actionMutableArray intentIdentifiers:@[] options:UNNotificationCategoryOptionCustomDismissAction];
        [center setNotificationCategories:[NSSet setWithObjects:category, nil]];
        content.categoryIdentifier = @"categoryNoOperationAction";
    }
    
    //UNTimeIntervalNotificationTrigger   延时推送
    //UNCalendarNotificationTrigger       定时推送
    //UNLocationNotificationTrigger       位置变化推送
    
    UNTimeIntervalNotificationTrigger * tirgger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:10 repeats:NO];
    
    //建立通知请求
    UNNotificationRequest * request = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:tirgger];
    
    //将建立的通知请求添加到通知中心
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        
        NSLog(@"%@本地推送 :( 报错 %@",identifier,error);
        
    }];
}
/**
 增加通知附件
 @param content 通知内容
 @param attachmentName 附件名称
 @param options 相关选项
 @param completion 结果回调
 */
-(void)addNotificationAttachmentContent:(UNMutableNotificationContent *)content attachmentName:(NSString *)attachmentName  options:(NSDictionary *)options withCompletion:(void(^)(NSError * error , UNNotificationAttachment * notificationAtt))completion{
    
    
    NSArray * arr = [attachmentName componentsSeparatedByString:@"."];
    
    NSError * error;
    
    NSString * path = [[NSBundle mainBundle]pathForResource:arr[0] ofType:arr[1]];
    
    UNNotificationAttachment * attachment = [UNNotificationAttachment attachmentWithIdentifier:[NSString stringWithFormat:@"notificationAtt_%@",arr[1]] URL:[NSURL fileURLWithPath:path] options:options error:&error];
    
    if (error) {
        
        NSLog(@"attachment error %@", error);
        
    }
    
    completion(error,attachment);
    //获取通知下拉放大图片
    content.launchImageName = attachmentName;
    
}


@end
