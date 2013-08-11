//
//  PacManLevelLayer.m
//  PacMan
//
//  Created by Javier Quevedo on 7/9/13.
//  Copyright 2013 Javier Quevedo. All rights reserved.
//

#import "PacManLevelLayer.h"
#import "CCBReader.h"
#import "CCControlButton.h"
#import "CCScale9Sprite.h"
#import "WelcomeMenu.h"
#import "SimpleAudioEngine.h"

#define kPlayerLives 2
#define kGhostCount 10
#define kShieldDuration 5.0
#define kMinimumGhostSpawnDistance 150.0

@interface PacManLevelLayer ()
{
    NSString *_name;
    int _score;
    int  _coinsCount;
    CGPoint _spawnPoint;
    JQPacManGameObject *_player;
    CCSpriteBatchNode *_buttonSprites;
    JQTouchPad *_touchPad;
}

@property (nonatomic, strong) JQPacManGameObject *player;
@property (nonatomic, strong) CCTMXTiledMap *tileMap;
@property (nonatomic, strong) CCTMXLayer *background;
@property (nonatomic, strong) CCTMXLayer *meta;
@property (nonatomic, strong) CCTMXLayer *coins;
@property (nonatomic, strong) CCLabelTTF *scoreLabel;
@property (nonatomic, strong) CCLabelTTF *livesLabel;
@property (nonatomic, strong) NSMutableArray *ghosts;
@end

@implementation PacManLevelLayer

+(CCScene *) scene
{
	CCScene *scene = [CCScene node];
	PacManLevelLayer *layer = [PacManLevelLayer node];
	[scene addChild: layer];
	
	return scene;
}

-(id) init
{
	if( (self=[super init]) ) {
        _score = 0;
        
		self.tileMap = [CCTMXTiledMap tiledMapWithTMXFile:@"Level1.tmx"];
        self.background = [_tileMap layerNamed:@"Background"];
       
        self.meta = [_tileMap layerNamed:@"Meta"]; 
        _meta.visible = NO;
        
        self.coins = [_tileMap layerNamed:@"Coins"];
        [self addChild:_tileMap z:-1];
        
        _coinsCount = [_coins numberOfTilesInLayer];
        
        
        CCTMXObjectGroup *objectGroup = [_tileMap objectGroupNamed:@"Objects"];
        NSAssert(objectGroup != nil, @"tile map has no objects object layer");
        
        NSDictionary *spawnPoint = [objectGroup objectNamed:@"SpawnPoint"];
        
        int x = [spawnPoint[@"x"] integerValue];
        int y = [spawnPoint[@"y"] integerValue];
        
        CGPoint startTileCoord = [self tileCoordForPosition:ccp(x,y)];
        x = (startTileCoord.x * _tileMap.tileSize.width) + _tileMap.tileSize.width/2;
        y = (_tileMap.tileSize.height * _tileMap.mapSize.height) -  (startTileCoord.y * _tileMap.tileSize.height) + _tileMap.tileSize.height/2;
		_spawnPoint = ccp(x,y);
		CGSize size = [[CCDirector sharedDirector] winSize];
        
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"PacMan: Level 1" fontName:@"Marker Felt" fontSize:20];
        label.color = ccBLACK;
        label.position =  ccp(80 , size.height - 40 );
		[self addChild: label];
		
        _scoreLabel = [CCLabelTTF labelWithString:@"Score: 0" fontName:@"Marker Felt" fontSize:20];
        _scoreLabel.color = ccBLACK;
        _scoreLabel.position =  ccp(size.width - 100  , size.height - 30 );
		[self addChild:_scoreLabel];
        
        _livesLabel = [CCLabelTTF labelWithString:@"" fontName:@"Marker Felt" fontSize:20];
        _livesLabel.color = ccBLACK;
        _livesLabel.position =  ccp(size.width - 100  , size.height - 60 );
        
		[self addChild:_livesLabel];
        
        _player = [[JQPacManGameObject alloc] init];
        [self addChild:_player];
        [_player setPosition:ccp(x,y)];
        [_player setSpeed:150.0];
        [_player setDelegate:self];
        [_player setDatasource:self];
        [_player setLives:kPlayerLives];

        [self loadGhosts];
        [[SimpleAudioEngine sharedEngine] preloadBackgroundMusic:@"pacman_chomp.wav"];
        
        [self updateLivesWithValue:_player.lives];

        _touchPad = [[JQTouchPad alloc] init];
        [self addChild:_touchPad];
        [_touchPad setPosition:CGPointMake(150, 100)];
        [_touchPad setDelegate:self];
        [_touchPad setVisible:YES];
        //[_touchPad setScale:0.7];
        [_touchPad touchButton:JQTouchPadButtonRight];

        [[CCSpriteFrameCache sharedSpriteFrameCache] addSpriteFramesWithFile:@"ccbResources/ccbDefaultImages.plist"];
        _buttonSprites = [CCSpriteBatchNode batchNodeWithFile:@"ccbResources/ccbDefaultImages.png"];

        [[SimpleAudioEngine sharedEngine] playEffect:@"pacman_beginning.wav"];

        
        CCLabelTTF *startLabel = [CCLabelTTF labelWithString:@"Ready!" fontName:@"Marker Felt" fontSize:48];
        startLabel.color = ccBLACK;
        startLabel.position =  ccp(size.width/2, size.height/2);
        [self addChild:startLabel];
        [startLabel runAction:[CCSequence actions:[CCEaseBackIn actionWithAction:[CCScaleTo actionWithDuration:0.7 scale:1.5]], [CCEaseBackOut actionWithAction:[CCScaleTo actionWithDuration:0.7 scale:1.0]],[CCCallBlock actionWithBlock:^{
            startLabel.string = @"Set!";
            [startLabel runAction:[CCSequence actions:[CCEaseBackIn actionWithAction:[CCScaleTo actionWithDuration:0.7 scale:1.5]], [CCEaseBackOut actionWithAction:[CCScaleTo actionWithDuration:0.7 scale:1.0]],[CCCallBlock actionWithBlock:^{
                startLabel.string = @"Go!";
                [startLabel runAction:[CCSequence actions:[CCEaseBackIn actionWithAction:[CCScaleTo actionWithDuration:0.7 scale:1.5]], [CCEaseBackOut actionWithAction:[CCScaleTo actionWithDuration:0.7 scale:1.0]],[CCCallBlock actionWithBlock:^{
                    [_player startNavigating];
                    [_ghosts makeObjectsPerformSelector:@selector(startNavigating)];
                    [self scheduleUpdate];

                    [startLabel runAction:[CCSequence actionOne:[CCFadeOut actionWithDuration:0.5] two:[CCCallBlock actionWithBlock:^{
                        [self removeChild:startLabel];
                    }]]];
                
                    }],nil]];
            }],nil]];

            
        }], nil]];
        
	}
	return self;
}

-(void) retryButtonWasTapped:(id)sender
{
    [[CCDirector sharedDirector] replaceScene:[PacManLevelLayer scene]];
}

-(void) goHomeButtonWasTapped:(id)sender
{
    [[CCDirector sharedDirector] popToRootScene];
}

#pragma mark - Protocols
#pragma mark JQTouchPad
-(void)touchPad:(JQTouchPad *)touchPad didTouchButton:(JQTouchPadButton)button{
    switch (button) {
        case JQTouchPadButtonDown:{
            [_player setFutureDirection:JQNavigationDirectionDown];
            break;
        }
        case JQTouchPadButtonUp:{
            [_player setFutureDirection:JQNavigationDirectionUp];
            break;
        }
        case JQTouchPadButtonLeft:{
            [_player setFutureDirection:JQNavigationDirectionLeft];
            break;
        }
        case JQTouchPadButtonRight:{
            [_player setFutureDirection:JQNavigationDirectionRight];
            break;
        }
        default:
            break;
    }
}

-(BOOL)isTileNavigable:(CGPoint)tileCoord
{
    int tileGid = [_meta tileGIDAt:tileCoord];
    if (tileGid){
        NSDictionary *properties = [_tileMap propertiesForGID:tileGid];
        if (properties)
        {
            NSString *collision = properties[@"Navigable"];
            if (collision && [collision isEqualToString:@"True"])
                return YES;
        }
    }
    return NO;
}

#pragma mark Traveler Object Delegate
-(BOOL)traveler:(JQTravelGameObject *)traveller canTravelToTile:(CGPoint)tileCoord{
    CGPoint tileCenter = [self positionForTileCoord:tileCoord];
    BOOL areAligned = (traveller.position.x == tileCenter.x | traveller.position.y == tileCenter.y);
    if ([self isTileNavigable:tileCoord] && areAligned){
        return YES;
    }
    return NO;
    
}

#pragma mark Pacman Object Delegate
-(void) pacmanDidDie:(JQPacManGameObject *)pacman{
    if (--pacman.lives !=0){
        [self resumeGame];
    }else{
        [self loose];
    }
    [self updateLivesWithValue:pacman.lives];

}

#pragma mark Scheduled Actions

-(void) update:(ccTime)delta
{
    // Checks for Coins
    CGPoint playerTile = [self tileCoordForPosition:self.player.position];
    int tileGid = [_coins tileGIDAt:playerTile];
    if (tileGid){
        NSDictionary *properties = [_tileMap propertiesForGID:tileGid];
        if (properties){
            if ([properties[@"Collectable"] isEqual:@"True"])
            {
                [_coins removeTileAt:playerTile];
                NSString *points = properties[@"Points"];
                [self updateScoreWithValue:[points integerValue]];
                --_coinsCount == 0 ? [self win] : nil;
                [[SimpleAudioEngine sharedEngine] playEffect:@"pacman_chomp.wav" pitch:1.5 pan:0.0 gain:1.0];
            }
            else if ([properties[@"PowerUp"] isEqual:@"true"])
            {
                [_player setShield:kShieldDuration];
                [_coins removeTileAt:playerTile];
                --_coinsCount == 0 ? [self win] : nil;
            }
        }
    }
    //Checks for Ghosts
    for (JQGhostGameObject *ghost in self.ghosts)
    {
        if (CGRectIntersectsRect(CGRectInset(self.player.boundingBox, 10, 10), ghost.boundingBox))
        {
            if ([_player shield] > 0.0)
            {
                [ghost stopNagivating];
                [self.ghosts removeObject:ghost];
                [self updateScoreWithValue:500];
                [[SimpleAudioEngine sharedEngine] playEffect:@"pacman_eatghost.wav"];
                [self removeChild:ghost];
                break;
            }
            else
            {
                [self stopGame];
                [_player die];
            }
        }
    }
}

-(void) stopGame
{
    [self unscheduleUpdate];
    [_ghosts makeObjectsPerformSelector:@selector(stopNagivating)];
    [_player stopNagivating];
}

-(void)resumeGame
{
    [_player setPosition:_spawnPoint];
    [_player startNavigating];
   
    for (JQGhostGameObject *ghost in _ghosts){
        [self removeChild:ghost];
    }
    [self loadGhosts];
    [_ghosts makeObjectsPerformSelector:@selector(startNavigating)];

    [self scheduleUpdate];
}

-(void) displayActionButtons
{
    CCScale9Sprite *retryButtonBackground = [CCScale9Sprite spriteWithSpriteFrameName:@"ccbButton.png"];
    CCScale9Sprite *homeButtonBackground = [CCScale9Sprite spriteWithSpriteFrameName:@"ccbButton.png"];
    CCLabelTTF *playAgainLable = [CCLabelTTF labelWithString:@"Retry" fontName:@"Helvetica" fontSize:30];
    CCLabelTTF *backHomeLabel  = [CCLabelTTF labelWithString:@"Main Menu" fontName:@"Helvetica" fontSize:30];
    playAgainLable.color = ccc3(159, 168, 176);
    backHomeLabel.color = ccc3(159, 168, 176);
    CCControlButton *retryButton = [CCControlButton buttonWithLabel:playAgainLable backgroundSprite:retryButtonBackground];
    CCControlButton *goHomeButton = [CCControlButton buttonWithLabel:backHomeLabel backgroundSprite:homeButtonBackground];
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    CCLayerColor *buttonsLayer = [CCLayerColor layerWithColor:ccc4(200, 200, 200, 140) width:400 height:140];
    [self addChild:buttonsLayer];
    
    // Why isn't the position of anchored around its center?
    // Why doesn't it even work if I manually set the anchorPoint to half of its width and height?
    [buttonsLayer setPosition:ccp((int)((screenSize.width/2) - buttonsLayer.contentSize.width/2), (int)((screenSize.height/2)-(buttonsLayer.contentSize.height/2)))];
    [retryButton setPosition:ccp(buttonsLayer.contentSize.width/2,buttonsLayer.contentSize.height / 2 + 26)];
    [goHomeButton setPosition:ccp(buttonsLayer.contentSize.width/2,buttonsLayer.contentSize.height / 2 - 26)];
    [buttonsLayer addChild:retryButton];
    [buttonsLayer addChild:goHomeButton];
    [retryButton addTarget:self action:@selector(retryButtonWasTapped:) forControlEvents:CCControlEventTouchUpInside];
    [goHomeButton addTarget:self action:@selector(goHomeButtonWasTapped:) forControlEvents:CCControlEventTouchUpInside];
    [retryButton setEnabled:YES];
    [buttonsLayer setScale:0];
    [buttonsLayer runAction:[CCSequence actions:[CCEaseInOut actionWithAction:[CCScaleTo actionWithDuration:0.5 scale:1.5] rate:2], [CCScaleTo actionWithDuration:0.2 scale:1.0], nil]];
    
}

-(void)endGameMessage:(NSString *)message
{
    [_touchPad setGlows:NO];
    CCLabelTTF *label = [CCLabelTTF labelWithString:message fontName:@"HelveticaNeue-Medium" fontSize:120];
    label.color = ccBLACK;
    CGSize screenSize =  [[CCDirector sharedDirector] winSize];
    [label setPosition:CGPointMake((int) screenSize.width/2, (int) screenSize.height/2)];
    [label setScale:0.1];
    [self addChild: label];
    [label runAction:[CCSequence actions:[CCSpawn actions:[CCFadeIn actionWithDuration:1.0],[CCScaleTo actionWithDuration:2.5 scale:1.0], [CCEaseInOut actionWithAction:[CCRotateTo actionWithDuration:2.5 angle:360*3] rate:2] , nil], [CCCallBlock actionWithBlock:^{
        [label runAction:[CCSequence actionOne:[CCFadeOut actionWithDuration:0.5] two:[CCCallBlock actionWithBlock:^{
            [self removeChild:label];
        }]]];
        [self displayActionButtons];
    }], nil]];
}

-(void) win
{
    [self stopGame];
    [self endGameMessage:@"You Won!!"];
}

-(void) loose
{
    [self stopGame];
    [self endGameMessage:@"Game Over!!"];    
}

#pragma mark - Helper Methods
-(CGPoint) randomGhostCoordinates{
    float tileX, tileY = 0;
    while (true)
    {
        tileX = (float)(arc4random() % ((int)self.tileMap.mapSize.width-1));
        tileY =(float)( arc4random() % ((int)self.tileMap.mapSize.height-1));
        if ([self isTileNavigable:ccp(tileX, tileY)] &&  ccpDistance([self positionForTileCoord:ccp(tileX, tileY)], _player.position) > kMinimumGhostSpawnDistance)
        {
            return [self positionForTileCoord:ccp(tileX, tileY)];
        }
    }
    
}
-(void) loadGhosts
{
    _ghosts = @[].mutableCopy;
    for (int i = 0; i< kGhostCount; i++){
        JQGhostGameObject *ghost = [self spawnGhost];
        [_ghosts addObject:ghost];
    }
}

-(JQGhostGameObject *) spawnGhost
{
    JQGhostGameObject *ghost = [[JQGhostGameObject alloc] init];
    if (ghost){
        [self addChild:ghost];
        [ghost setSpeed:80.0];
        [ghost setDelegate:self];
        [ghost setDatasource:self];
        CGPoint coordinate = [self randomGhostCoordinates];
        [ghost setPosition:coordinate];
    }
    return ghost;
}

- (CGPoint)tileCoordForPosition:(CGPoint)position
{
    int x = position.x / _tileMap.tileSize.width;
    int y = ((_tileMap.mapSize.height * _tileMap.tileSize.height) - position.y) / _tileMap.tileSize.height;
    return ccp(x, y);
}

-(CGPoint)positionForTileCoord:(CGPoint)coord
{
    float x = (_tileMap.tileSize.width * coord.x) + _tileMap.tileSize.width/2;
    float y = (_tileMap.tileSize.height * coord.y) + _tileMap.tileSize.height/2;
    y = (_tileMap.mapSize.height * _tileMap.tileSize.height) - y;
    
    return ccp(x,y);
}

-(CGPoint) coordinateForTile:(CGPoint)tileCoord
{
    return [self positionForTileCoord:tileCoord];    
}

-(CGPoint) currentTileForTraveller:(JQTravelGameObject *)traveller
{
    return [self tileCoordForPosition:traveller.position];
}

-(void) updateScoreWithValue:(int)value
{
    _score +=value;
    [[self scoreLabel] setString:[NSString stringWithFormat:@"Score: %d", _score]];
}

-(void) updateLivesWithValue:(int)value
{
    [[self livesLabel] setString:[NSString stringWithFormat:@"%d UP!", value]];
}



@end
