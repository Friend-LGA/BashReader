//
//  NavBarButton.h
//  Bash
//
//  Created by Friend_LGA on 22.01.14.
//  Copyright (c) 2014 Grigory Lutkov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NavBarButton : UIButton

typedef enum
{
    LGNavBarButtonLeft,
    LGNavBarButtonRight
}
LGNavBarButtonType;

@property (assign, nonatomic) LGNavBarButtonType type;

@end
