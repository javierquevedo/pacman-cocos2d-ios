//
//  CCSprite+EmptyColored.m
//  PacMan
//
//  Created by Javier Quevedo on 7/8/13.
//  Copyright (c) 2013 Javier Quevedo. All rights reserved.
//

#import "CCSprite+EmptyColored.h"

@implementation CCSprite (EmptyColored)


+ (CCSprite*)blankSpriteWithSize:(CGSize)size
{
    CCSprite *sprite = [CCSprite node];
    
    GLubyte *buffer = malloc(sizeof(GLubyte)*4);
    
    for (int i=0;i<4;i++)
    {
        buffer[i]=255;
    }
    
    CCTexture2D *tex = [[CCTexture2D alloc] initWithData:buffer pixelFormat:kCCTexture2DPixelFormat_RGB5A1 pixelsWide:1 pixelsHigh:1 contentSize:size];
    [sprite setTexture:tex];
    [sprite setTextureRect:CGRectMake(0, 0, size.width, size.height)];
    [sprite setOpacity:192];
    free(buffer);
    
    
    return sprite;
}
@end
