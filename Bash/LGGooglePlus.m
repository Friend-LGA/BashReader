//
//  LGGooglePlus.m
//  Rush
//
//  Created by Admin on 30.05.14.
//  Copyright (c) 2014 SoftInvent. All rights reserved.
//

#import "LGGooglePlus.h"
#import "GooglePlus.h"
#import "GTLPlusConstants.h"

static NSString *const kClientID = @"785609554109-sj6bbvcpdd1v0laekoavs3q3hc4phhfk.apps.googleusercontent.com";

#pragma mark - Private

@interface LGGooglePlus () <GPPSignInDelegate, GPPShareDelegate>

@property (strong, nonatomic) GPPSignIn *signIn;
@property (strong, nonatomic) GPPShare  *share;
@property (strong, nonatomic) NSString  *text;
@property (strong, nonatomic) UIImage   *image;
@property (strong, nonatomic) NSURL     *link;
@property (strong, nonatomic) void      (^completionHandler)(BOOL result);
@property (assign, nonatomic) BOOL      needsPost;

@end

#pragma mark - Implementation

@implementation LGGooglePlus

+ (instancetype)sharedManager
{
    static dispatch_once_t once;
    static id sharedManager;
    
    dispatch_once(&once, ^(void)
                  {
                      sharedManager = [super new];
                  });
    
    return sharedManager;
}

- (id)init
{
    if (self = [super init])
    {
        NSLog(@"LGGooglePlus: Shared Manager initialization...");
        
        _signIn = [GPPSignIn sharedInstance];
        _signIn.delegate = self;
        _signIn.clientID = kClientID;
        _signIn.scopes = [NSArray arrayWithObjects:
                          kGTLAuthScopePlusLogin, // определяется в файле GTLPlusConstants.h
                          nil];
        
        _share = [GPPShare sharedInstance];
        _share.delegate = self;
    }
    return self;
}

- (BOOL)isAuthorized
{
    return (_signIn.authentication == nil ? NO : YES);
}

- (void)authorize
{
    if (![_signIn trySilentAuthentication]) [_signIn authenticate];
}

- (void)postWithText:(NSString *)text image:(UIImage *)image link:(NSURL *)link completionHandler:(void(^)(BOOL result))completionHandler
{
    _text   = text;
    _image  = image;
    _link   = link;
    _completionHandler = completionHandler;
    
    if ([self isAuthorized])
    {
        //if (_completionHandler) _completionHandler(YES);
        
        id <GPPNativeShareBuilder> shareBuilder = [_share nativeShareDialog];
        
        // Подставляются заголовок, описание, эскиз и ссылка,
        // связанные с передаваемым URL.
        if (link) [shareBuilder setURLToShare:link];
        if (text) [shareBuilder setPrefillText:text];
        if (image) [shareBuilder attachImage:image];
        
        /* This line passes the deepLinkID to our application
         if somebody opens the link on a supported mobile device */
        if (link) [shareBuilder setContentDeepLinkID:@"share"];
        
        // Вручную подставим заголовок, описание и эскиз
        // для передаваемого контента.
        //[shareBuilder setTitle:@"Uro+"
        //           description:text
        //          thumbnailURL:link];
        
        [shareBuilder open];
        
        _needsPost = NO;
    }
    else
    {
        _needsPost = YES;
        
        [self authorize];
    }
}

- (void)signOut
{
    [_signIn signOut];
}

- (void)disconnect
{
    [_signIn disconnect];
}

- (void)didDisconnectWithError:(NSError *)error
{
    if (error)
    {
        NSLog(@"LGGooglePlus: Received error %@", error);
    }
    else
    {
        // Пользователь вышел и отключился.
        // Удалим данные пользователя в соответствии с Условиями использования Google+.
    }
}

#pragma mark -

- (void)finishedSharing:(BOOL)shared
{
    //if (_completionHandler) _completionHandler(YES);
}

- (void)finishedSharingWithError:(NSError *)error
{
    if (error)
    {
        NSLog(@"LGGooglePlus: Received error %@", error);
        
        if (_completionHandler) _completionHandler(NO);
    }
    else if (_completionHandler) _completionHandler(YES);
    
    _text   = nil;
    _image  = nil;
    _link   = nil;
    _completionHandler = nil;
}

- (void)finishedWithAuth:(GTMOAuth2Authentication *)auth error:(NSError *)error
{
    if (error)
    {
        NSLog(@"LGGooglePlus: Received error %@ and auth object %@", error, auth);
        
        if (_completionHandler) _completionHandler(NO);
        
        _text   = nil;
        _image  = nil;
        _link   = nil;
        _completionHandler = nil;
    }
    else if (_text || _image) [self postWithText:_text image:_image link:_link completionHandler:_completionHandler];
}

@end
