//
//  LGVkontakte.m
//  Bash
//
//  Created by Friend_LGA on 11.11.13.
//  Copyright (c) 2013 Grigory Lutkov. All rights reserved.
//

#import "LGVkontakte.h"
#import "AppDelegate.h"
#import "InfoViewController.h"
#import "LGKit.h"
#import "Settings.h"

static NSString *const kVKAppId = @"3747161";
static NSString *const kVKAccessTokenKey = @"VKAccessToken";

#pragma mark - Private

@interface LGVkontakte () <VKSdkDelegate>

@property (strong, nonatomic) NSString  *text;
@property (strong, nonatomic) UIImage   *image;
@property (strong, nonatomic) NSURL     *link;
@property (strong, nonatomic) void      (^completionHandler)(BOOL result);
@property (assign, nonatomic) BOOL      needsPost;

@end

#pragma mark - Implementation

@implementation LGVkontakte

+ (instancetype)sharedManager
{
    static dispatch_once_t once;
    static id sharedManager = nil;
    
    dispatch_once(&once, ^
                  {
                      sharedManager = [super new];
                  });
    
    return sharedManager;
}

- (id)init
{
    if ((self = [super init]))
    {
        NSLog(@"LGVkontakte: Shared Manager initialization...");
        
        VKAccessToken *accessToken = [VKAccessToken tokenFromDefaults:kVKAccessTokenKey];
        
        if (accessToken) [VKSdk initializeWithDelegate:self andAppId:kVKAppId andCustomToken:accessToken];
        else [VKSdk initializeWithDelegate:self andAppId:kVKAppId];
    }
    return self;
}

- (void)authorize
{
    [VKSdk authorize:@[VK_PER_PHOTOS, VK_PER_WALL, VK_PER_OFFLINE] revokeAccess:YES forceOAuth:NO inApp:YES display:VK_DISPLAY_IOS];
}

- (BOOL)isAuthorized
{
    VKAccessToken *accessToken = [VKAccessToken tokenFromDefaults:kVKAccessTokenKey];
    
    if (accessToken) return YES;
    else return NO;
}

- (BOOL)logout
{
    [VKSdk forceLogout];
    
    if ([self isAuthorized])
    {
        [kStandartUserDefaults removeObjectForKey:kVKAccessTokenKey];
        
        return YES;
    }
    else return NO;
}

- (void)vkSdkShouldPresentViewController:(UIViewController *)controller
{
    [kNavController presentViewController:controller animated:YES completion:nil];
}

- (void)vkSdkNeedCaptchaEnter:(VKError *)captchaError
{
    VKCaptchaViewController *vc = [VKCaptchaViewController captchaControllerWithError:captchaError];
    [vc presentIn:kNavController];
}

- (void)vkSdkTokenHasExpired:(VKAccessToken *)expiredToken
{
    [self authorize];
}

- (void)vkSdkReceivedNewToken:(VKAccessToken *)newToken
{
    [newToken saveTokenToDefaults:kVKAccessTokenKey];
    if (_text || _image) [self postWithText:_text image:_image link:_link completionHandler:_completionHandler];
    
    //[kNavController rotateToInterfaceOrientation:[UIDevice currentDevice].orientation];
    if (kSettings.orientation != LGOrientationAuto) kNavController.rotationBlocked = NO;
}

- (void)vkSdkUserDeniedAccess:(VKError *)authorizationError
{
    if (_completionHandler) _completionHandler(NO);
    
    //[kNavController rotateToInterfaceOrientation:[UIDevice currentDevice].orientation];
    if (kSettings.orientation != LGOrientationAuto) kNavController.rotationBlocked = NO;
}

- (void)vkSdkDidAcceptUserToken:(VKAccessToken *)token
{
    if (_text || _image) [self postWithText:_text image:_image link:_link completionHandler:_completionHandler];
    
    //[kNavController rotateToInterfaceOrientation:[UIDevice currentDevice].orientation];
    if (kSettings.orientation != LGOrientationAuto) kNavController.rotationBlocked = NO;
}

- (void)postWithText:(NSString *)text image:(UIImage *)image link:(NSURL *)link completionHandler:(void(^)(BOOL result))completionHandler
{
    if (kSettings.orientation != LGOrientationAuto) kNavController.rotationBlocked = YES;
    
    _text   = text;
    _image  = image;
    _link   = link;
    _completionHandler = completionHandler;
    
    if ([self isAuthorized])
    {
        if (_completionHandler) _completionHandler(YES);
        
        if (image)
        {
            VKRequest *request = [VKApi uploadWallPhotoRequest:image
                                                    parameters:[VKImageParameters pngImage]
                                                        userId:0
                                                       groupId:0];
            
            [request executeWithResultBlock:^(VKResponse *response)
             {
                 NSLog(@"LGVkontakte: json result1: %@", response.json);
                 
                 VKPhoto *photoInfo = [(VKPhotoArray*)response.parsedModel objectAtIndex:0];
                 
                 VKRequest *post = [[VKApi wall] post:@{ VK_API_MESSAGE     : text,
                                                         VK_API_ATTACHMENTS : [NSString stringWithFormat:@"photo%@_%@,%@", photoInfo.owner_id, photoInfo.id, link] }];
                 
                 [post executeWithResultBlock: ^(VKResponse *response)
                  {
                      NSLog(@"LGVkontakte: json result2: %@", response);
                  }
                                   errorBlock: ^(NSError *error)
                  {
                      NSLog(@"LGVkontakte: error2: %@", error);
                  }];
             }
                                 errorBlock:^(NSError *error)
             {
                 NSLog(@"LGVkontakte: error1: %@", error.localizedDescription);
             }];
        }
        else
        {
            VKRequest *post = [[VKApi wall] post:@{ VK_API_MESSAGE     : text,
                                                    VK_API_ATTACHMENTS : link }];
            
            [post executeWithResultBlock:^(VKResponse *response)
             {
                 NSLog(@"LGVkontakte: json result: %@", response.json);
             }
                              errorBlock:^(NSError *error)
             {
                 NSLog(@"LGVkontakte: error: %@", error.localizedDescription);
             }];
        }
        
        _text   = nil;
        _image  = nil;
        _link   = nil;
        _completionHandler = nil;
        
        if (kSettings.orientation != LGOrientationAuto) kNavController.rotationBlocked = NO;
        
        _needsPost = NO;
    }
    else
    {
        _needsPost = YES;
        
        [self authorize];
    }
}

@end
