//
//  JQNavigableGameObject.m
//  PacMan
//
//  Created by Javier Quevedo on 7/15/13.
//  Copyright (c) 2013 Javier Quevedo. All rights reserved.
//

#import "JQTravelGameObject.h"

@interface JQTravelGameObject(){
    CGPoint _positionDesination;
}
@end

@implementation JQTravelGameObject

-(id)init{
    if (self = [super init]){
        _currentDirection = JQNavigationDirectionRight;
        _futureDirection = JQNavigationDirectionRight;
        _positionDesination = self.position;
        _speed = 0.0;
    }
    return self;
}

-(id) initWithSpriteFile:(NSString *)spriteFile{
    if (self = [super init]){
        _body = [CCSprite spriteWithFile:spriteFile];
        [self addChild:_body];
        _currentDirection = JQNavigationDirectionRight;
        _futureDirection = JQNavigationDirectionRight;
        [self setContentSize:CGSizeMake(_body.contentSize.width, _body.contentSize.height)];
        _positionDesination = self.position;
        _speed = 0.0;
    }
    return self;
}

-(CGPoint)candidatePositionForDirection:(JQNavigationDirection)direction withDelta:(ccTime)delta{
    CGPoint candidatePosition;
    float distance = delta * [self speed];
    switch (direction) {
        case JQNavigationDirectionDown:{
            candidatePosition = ccpAdd(self.position, CGPointMake(0, -distance));
            break;
        }
        case JQNavigationDirectionUp:{
            candidatePosition =  ccpAdd(self.position, CGPointMake(0, distance));
            break;
        }
        case JQNavigationDirectionLeft:{
            candidatePosition = ccpAdd(self.position, CGPointMake(-distance, 0));
            break;
        }
        case JQNavigationDirectionRight:{
            candidatePosition = ccpAdd(self.position, CGPointMake(distance, 0));
            break;
        }
        default:
            break;
    }
    return candidatePosition;
}

-(CGPoint) nextTileForDirection:(JQNavigationDirection)direction{
    CGPoint nextTile;
    
    switch (direction) {
        case JQNavigationDirectionUp:
            nextTile = ccp(0,-1);
            break;
        case JQNavigationDirectionDown:
            nextTile = ccp(0,1);
            break;
        case JQNavigationDirectionLeft:
            nextTile = ccp(-1,0);
            break;
        case JQNavigationDirectionRight:
            nextTile = ccp(1,0);
            break;
        case JQNavigationDirectionNone:
            nextTile = ccp(0,0);
            break;
        default:
            break;
    }
    CGPoint currentTile = [[self datasource] currentTileForTraveller:self];
    return ccpAdd(currentTile, nextTile);
}

-(float) move:(ccTime)delta{
    float adjustment = 0.0;
    CGPoint positionDifference = ccpSub(_positionDesination, self.position);
    float distance = delta * self.speed;
    
    CGPoint finalDisplacement = ccp(0,0);
    
    if (positionDifference.x != 0){
        if (positionDifference.x < 0){
            finalDisplacement = ccp(-distance,0);
            if (finalDisplacement.x < positionDifference.x){
                adjustment =positionDifference.x - finalDisplacement.x;
                finalDisplacement.x = positionDifference.x;
            }
        }
        else{
            finalDisplacement = ccp(distance,0);
            if (finalDisplacement.x > positionDifference.x){
                adjustment =finalDisplacement.x - positionDifference.x;
                finalDisplacement.x = positionDifference.x;
            }
        }
    }else if (positionDifference.y != 0){
        if (positionDifference.y < 0){
            finalDisplacement = ccp(0,-distance);
            if (finalDisplacement.y < positionDifference.y){
                adjustment = positionDifference.y - finalDisplacement.y;
                finalDisplacement.y = positionDifference.y;
            }
        }else{
            finalDisplacement = ccp(0,distance);
            if (finalDisplacement.y > positionDifference.y){
                adjustment =  finalDisplacement.y - positionDifference.y;
                finalDisplacement.y = positionDifference.y;
            }
        }
    }
    
    CGPoint finalPosition = ccpAdd(self.position, finalDisplacement);
    self.position = finalPosition;
    return adjustment;
}
-(void) adjustWithAmount:(float)adjustment{
    if (adjustment !=0)
    {
        if ([[self delegate] traveler:self canTravelToTile:[self nextTileForDirection:self.futureDirection]]){
            self.currentDirection = self.futureDirection;
        }
        if ([[self delegate] traveler:self canTravelToTile:[self nextTileForDirection:self.currentDirection]]){
            _positionDesination = [[self datasource] coordinateForTile:[self nextTileForDirection:self.currentDirection]];
            switch (self.currentDirection) {
                case JQNavigationDirectionDown:
                    self.position = ccpAdd(self.position, ccp(0,-adjustment));
                    break;
                case JQNavigationDirectionUp:
                    self.position = ccpAdd(self.position, ccp(0,adjustment));
                    break;
                case JQNavigationDirectionLeft:
                    self.position = ccpAdd(self.position, ccp(-adjustment, 0));
                    break;
                case JQNavigationDirectionRight:
                    self.position = ccpAdd(self.position, ccp(adjustment, 0));
                    break;
                default:
                    break;
            }
        }
    }
}

-(void) update:(ccTime)delta
{
    float adjustment = 0.0;
    if (!CGPointEqualToPoint(_positionDesination, self.position)){
        
        adjustment = [self move:delta];
        [self adjustWithAmount:adjustment];
    }else{
        CGPoint nextTile = [[self datasource] currentTileForTraveller:self];
        if ([[self delegate] traveler:self canTravelToTile:[self nextTileForDirection:self.futureDirection]]){
            nextTile = [self nextTileForDirection:self.futureDirection];
            self.currentDirection = self.futureDirection;
            _positionDesination = [[self datasource] coordinateForTile:nextTile];
            adjustment = [self move:delta];
        }
        else if ([[self delegate] traveler:self canTravelToTile:[self nextTileForDirection:self.currentDirection]]){
            nextTile = [self nextTileForDirection:self.currentDirection];
            _positionDesination = [[self datasource] coordinateForTile:nextTile];
            adjustment = [self move:delta];
        }
        else if ([[self delegate] traveler:self canTravelToTile:[[self datasource] currentTileForTraveller:self]]){
            nextTile = [[self datasource] currentTileForTraveller:self];
            _positionDesination = [[self datasource] coordinateForTile:nextTile];
            adjustment = [self move:delta];
        }
        
    }
}
-(void) setFutureDirection:(JQNavigationDirection)futureDirection
{
    _futureDirection = futureDirection;
    if (JQNavigationDirectionOppositeToNavigationDirection(self.currentDirection, futureDirection)){
        _positionDesination = self.position;
    }
}

static inline BOOL JQNavigationDirectionOppositeToNavigationDirection(JQNavigationDirection direction1, JQNavigationDirection direction2)
{
    return (abs(direction1 - direction2) == 1) & (direction1 != JQNavigationDirectionNone & direction2 != JQNavigationDirectionNone);
}


-(void) startNavigating{
    _positionDesination = self.position;
    [self scheduleUpdate];
}

-(void) stopNagivating{
    [self unscheduleUpdate];
}



@end
