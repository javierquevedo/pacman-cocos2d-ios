//
//  JQPacManGameObject.m
//  PacMan
//
//  Created by Javier Quevedo on 7/15/13.
//  Copyright (c) 2013 Javier Quevedo. All rights reserved.
//

#import "JQPacManGameObject.h"
#import "SimpleAudioEngine.h"

#define kShieldFadeDuration 0.10
@interface JQPacManGameObject(){

    CCRepeatForever *_shieldSequence;
    BOOL _shieldIsActive;
}
@property (nonatomic, strong) CCSpriteBatchNode *spriteSheet;
@property (nonatomic, strong) CCAction *eatAction;
@property (nonatomic, strong) NSArray *eatFrames;
@end


@implementation JQPacManGameObject

-(id)init{
//    if (self = [super initWithSpriteFile:@"pacman.png"]){
    if (self = [super init])
    {

        _shield = 0.0;
        _shieldIsActive = NO;
        
        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"pacman.plist"];
        _spriteSheet = [CCSpriteBatchNode batchNodeWithFile:@"pacman.png"];
 
        [self addChild:_spriteSheet];
        [self setContentSize:CGSizeMake(32, 32)];
        
        NSMutableArray *framesTemp = @[].mutableCopy;
        for (int i=0; i<=4; i++) {
            [framesTemp addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"pacman%d.png",i]]];
        }

        for (int i=3; i>=1; i--) {
            [framesTemp addObject:
             [[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
              [NSString stringWithFormat:@"pacman%d.png",i]]];
        }
        _eatFrames = [framesTemp copy];
        CCAnimation *eatAnim = [CCAnimation
                                 animationWithSpriteFrames:_eatFrames delay:0.020f];
        _eatAction = [CCRepeatForever actionWithAction:
                           [CCAnimate actionWithAnimation:eatAnim]];
        self.body = [CCSprite spriteWithSpriteFrameName:@"pacman0.png"];
        
        [[self spriteSheet] addChild:self.body];
        

        
    }
    return self;
}
-(void) setFutureDirection:(JQNavigationDirection)futureDirection{
    [super setFutureDirection:futureDirection];
  
}

-(void) setCurrentDirection:(JQNavigationDirection)currentDirection{
    [super setCurrentDirection:currentDirection];
    switch (currentDirection) {
        case JQNavigationDirectionLeft:
            self.body.flipX = YES;
            self.body.rotation =0;

            break;
        case JQNavigationDirectionRight:
            self.body.flipX = NO;
            self.body.rotation = 0;

            break;
        case JQNavigationDirectionUp:
            self.body.flipX = NO;
            self.body.rotation = 270;
            break;
        case JQNavigationDirectionDown:
            self.body.rotation = 90;

            self.body.flipX = NO;
            
            break;
        default:
            break;
    }
    if (currentDirection == JQNavigationDirectionLeft){
        
    }else{
        
    }
}
-(void) update:(ccTime)delta{
    [super update:delta];
    if (_shieldIsActive){
        _shield -=  delta;
        if (_shield <= 0.0){
            _shieldIsActive = NO;
            _shield = 0.0;
            [self.body stopAction:_shieldSequence];
            [self.body runAction:[CCFadeTo actionWithDuration:kShieldFadeDuration opacity:255]];
        }
    }
}


-(void)setShield:(float)shield{
    if (shield > 0.0 && !_shieldIsActive){
        _shield = shield;
        _shieldIsActive = YES;
        _shieldSequence = [CCRepeatForever actionWithAction:[CCSequence actionOne:[CCFadeTo actionWithDuration:kShieldFadeDuration opacity:0] two:[CCFadeTo actionWithDuration:kShieldFadeDuration opacity:255]]];
        [self.body runAction:_shieldSequence];
    }

}


-(void)die{

    [self unscheduleUpdate];
    [[SimpleAudioEngine sharedEngine] playEffect:@"pacman_death.wav"];
    [self stopAction:_eatAction];
    //self.body = [CCSprite spriteWithSpriteFrameName:@"pacman0.png"];
    
    [self runAction:[CCSequence actions:[CCRotateBy actionWithDuration:1.2 angle:720], [CCCallBlock actionWithBlock:^{
        [self setCurrentDirection:JQNavigationDirectionRight];
        [[self delegate] pacmanDidDie:self];
    }], nil]];
}

-(void)startNavigating{
    [super startNavigating];
    [self.body runAction:_eatAction];
}

-(void) stopNagivating{
    [super stopNagivating];
    [self stopAction:_eatAction];
}

@end
