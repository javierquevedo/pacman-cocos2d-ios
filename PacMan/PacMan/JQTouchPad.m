//
//  JQTouchPad.m
//  PacMan
//
//  Created by Javier Quevedo on 7/8/13.
//  Copyright 2013 Javier Quevedo. All rights reserved.
//

#import "JQTouchPad.h"
#import "CCSprite+EmptyColored.h"

@interface JQTouchPad(){
    
}

@property (nonatomic, strong) NSDictionary *arrows;
@property (nonatomic, strong) CCSprite *glowSprite;
@property (nonatomic, strong) CCRepeatForever *glowRepeat;
@end

@implementation JQTouchPad

-(id) init{
    if (self = [super init]){
        CCSprite *left = [CCSprite blankSpriteWithSize:CGSizeMake(96, 96)];
        CCSprite *right = [CCSprite blankSpriteWithSize:CGSizeMake(96, 96)];
        CCSprite *up = [CCSprite blankSpriteWithSize:CGSizeMake(96, 96)];
        CCSprite *down = [CCSprite blankSpriteWithSize:CGSizeMake(96, 96)];

        left.position = CGPointMake(0, 0);
        down.position = CGPointMake(100, 0);
        right.position = CGPointMake(200, 0);
        up.position = CGPointMake(100,100);
        [[[CCDirector sharedDirector] touchDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:NO];
        
        
        _arrows = @{@(JQTouchPadButtonLeft): left, @(JQTouchPadButtonRight) : right, @(JQTouchPadButtonUp) : up, @(JQTouchPadButtonDown) : down}.copy;
        
        [_arrows enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [self addChild:(CCSprite *)obj];
        }];

        

        

    }
    
    return self;
}
- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    
    [[self arrows] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        if (CGRectContainsPoint([(CCSprite *)obj boundingBox], [self convertTouchToNodeSpace:touch])){
            if ([[self delegate] respondsToSelector:@selector(touchPad:didTouchButton:)]){
                [[self delegate] touchPad:self didTouchButton:[(NSNumber *)key intValue]];
            }
            
            self.glowSprite.position = ((CCSprite *)obj).position;
            
        }
    }];
    return YES;
}

-(void) touchButton:(JQTouchPadButton)button{
    CCSprite *theButton = self.arrows[@(button)];
    self.glowSprite.position = theButton.position;
    if ([[self delegate] respondsToSelector:@selector(touchPad:didTouchButton:)]){
        [[self delegate] touchPad:self didTouchButton:button];
    }
    

    
}


-(CCSprite *)glowSprite{
    if (!_glowSprite){
        _glowSprite = [CCSprite spriteWithFile:@"ccbResources/ccbParticleFire.png"];
        [self addChild:_glowSprite];
        _glowSprite.position = ccp(400,400);
        //        _glowSprite.color
        ccColor3B color = {255,0,0};
        [_glowSprite setColor:color];
        //ccBlendFunc blend = {GL_ONE, GL_ONE_MINUS_CONSTANT_COLOR};
        //[_glowSprite setBlendFunc:blend];
        CCScaleTo *scale1 = [CCScaleTo actionWithDuration:0.9 scaleX:6 scaleY:6];
        CCScaleTo *scale2 = [CCScaleTo actionWithDuration:0.9 scaleX:4 scaleY:4];
        
        CCSequence *glowSequence = [CCSequence actionOne:scale1 two:scale2];
        self.glowRepeat = [CCRepeatForever actionWithAction:glowSequence];
        [_glowSprite runAction:self.glowRepeat];
    }
    return _glowSprite;
}

-(void) setGlows:(BOOL)glows{
    if (glows){
        [self.glowSprite runAction:self.glowRepeat];
        [self addChild:self.glowSprite];
    }
    else{
        [_glowSprite stopAction:self.glowRepeat];
        [self removeChild:self.glowSprite];

    }
    
//    [_glowSprite stopAction:r];
}


@end
