//
//  JQTouchPad.h
//  PacMan
//
//  Created by Javier Quevedo on 7/8/13.
//  Copyright 2013 Javier Quevedo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
@class JQTouchPad;

typedef enum{
    JQTouchPadButtonLeft = 0,
    JQTouchPadButtonRight = 1,
    JQTouchPadButtonUp = 2,
    JQTouchPadButtonDown = 3,
    
}JQTouchPadButton;

@protocol JQTouchPadDelegate <NSObject>
-(void) touchPad:(JQTouchPad *) touchPad didTouchButton:(JQTouchPadButton)button;
@end


@interface JQTouchPad : CCNode <CCTouchOneByOneDelegate> {
   
}

@property (nonatomic, weak) id<JQTouchPadDelegate> delegate;


-(void) touchButton:(JQTouchPadButton)button;
-(void) setGlows:(BOOL)glows;

@end
