//
//  JQGhostGameObject.m
//  PacMan
//
//  Created by Javier Quevedo on 7/15/13.
//  Copyright (c) 2013 Javier Quevedo. All rights reserved.
//

#import "JQGhostGameObject.h"

@implementation JQGhostGameObject
-(id)init{
    if (self = [super initWithSpriteFile:@"ghost.png"]){
        [self schedule:@selector(updateNavigationDirection) interval:1];
    }
    return self;
}

-(void) updateNavigationDirection{
    self.futureDirection = rand()%5;
    while (self.futureDirection == JQNavigationDirectionNone){
            self.futureDirection = arc4random()%5;
    }
}
@end
