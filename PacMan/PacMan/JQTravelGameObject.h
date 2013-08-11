//
//  JQNavigableGameObject.h
//  PacMan
//
//  Created by Javier Quevedo on 7/15/13.
//  Copyright (c) 2013 Javier Quevedo. All rights reserved.
//
//  For game objects that can navigate on the Tiled space based
//  on the navigable tiles
#import "cocos2d.h"

typedef enum {
    JQNavigationDirectionLeft = 0,
    JQNavigationDirectionRight = 1,
    JQNavigationDirectionUp = 4,
    JQNavigationDirectionDown = 3,
    JQNavigationDirectionNone = 2
}JQNavigationDirection;

@class JQTravelGameObject;

@protocol TravelObjectDelegate <NSObject>
-(BOOL) traveler:(JQTravelGameObject *)traveller canTravelToTile:(CGPoint)tileCoord;

@optional
-(BOOL) travellerDidTravelToTile:(CGPoint)tileCoord;
@end

@protocol TravelObjectDatasource <NSObject>
-(CGPoint) coordinateForTile:(CGPoint)tileCoord;
-(CGPoint) currentTileForTraveller:(JQTravelGameObject *)traveller;
@end

@interface JQTravelGameObject : CCNode

-(id) initWithSpriteFile:(NSString *)spriteFile;

@property (nonatomic, assign) float speed;
@property (nonatomic, assign) JQNavigationDirection currentDirection;
@property (nonatomic, assign) JQNavigationDirection futureDirection;
@property (nonatomic, weak) id<TravelObjectDelegate> delegate;
@property (nonatomic, weak) id<TravelObjectDatasource> datasource;
@property (nonatomic, strong) CCSprite *body;


-(void) startNavigating;
-(void) stopNagivating;

@end
