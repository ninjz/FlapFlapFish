//  CCLabelBMFont+Capacity.m

#import "CCLabelBMFont+Capacity.h"

@implementation CCLabelBMFont (Capacity)

- (void) setStringWithCapacity:(NSString*) newString
{
    if (newString) {
        int newCapacity = [newString length] + 1;
        
        if (_textureAtlas.totalQuads < newCapacity) {
            
            CCLOG(@"cocos2d: CCSpriteBatchNode: resizing TextureAtlas capacity from [%u] to [%u].",
                  (unsigned int)_textureAtlas.capacity,
                  (unsigned int)newCapacity);
            
            if( ! [_textureAtlas resizeCapacity:newCapacity] ) {
                // serious problems
                CCLOG(@"cocos2d: WARNING: Not enough memory to resize the atlas");
                NSAssert(NO,@"XXX: SpriteSheet#increaseAtlasCapacity SHALL handle this assert");
            }
        }
    }
    
    [self setString:newString];
}
@end