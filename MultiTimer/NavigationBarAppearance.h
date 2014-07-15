//
//  NavigationBarAppearance.h
//  VideoBuilder
//
//  Created by Connor Lirot on 1/26/14.
//  Copyright (c) 2014 Taplet. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol NavigationBarAppearance <NSObject>
- (BOOL) prefersTransparentNavigationBar;
- (UIColor *) preferredTitleColor;
@end
