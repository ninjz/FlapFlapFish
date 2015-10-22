//
//  CharSelectLayer.m
//  floppyFish
//
//  Created by sh0gun on 2/15/2014.
//  Copyright 2014 JAC studios. All rights reserved.
//

#import "CharSelectLayer.h"
#import "FFFModalView.h"
#import "MenuScene.h"
#import "GameScene.h"

#import "Angler.h"
#import "Narwhal.h"
#import "BlowFish.h"
#import "Piranha.h"
#import "Skelly.h"

@implementation CharSelectLayer
{
    CGSize winSize;
    CCSprite *frame;
    
}


-(id)init
{
    self = [super init];
    if (!self) return(nil);
    
    winSize = [[CCDirector sharedDirector] viewSize];
    
    [self initFrame];
    
    return self;
}

-(void)initFrame
{// Create Frame image
    frame = [CCSprite spriteWithImageNamed:@"Fish-Select-Screen.png"];
    [frame setScale:2];
    [frame setPosition:ccp( winSize.width/2, winSize.height/2.5)];
    [self addChild:frame];
    
    
    // Create a Menu button
    CCButton *menuButton = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"button-menu.png"]];
    menuButton.scale = 2;
    [menuButton setPosition:ccp(winSize.width/2, frame.position.y - frame.contentSize.width)];
    [menuButton setTarget:[MenuScene sharedMenuScene] selector:@selector(transitionFromCharSelectToMain)];
    [self addChild:menuButton];
    
    
    NSDictionary * fishDic = [[GameState sharedGameState] unlockedFishes];
    
    //make array for fishbuttons to decide on which image to load.
    CCButton *fish1,*fish2,*fish3,*fish4,*fish5;
    
    
    // create buttons for the chars
    if ([[fishDic objectForKey:@"main_fish"] isEqualToNumber:[NSNumber numberWithBool:YES]] ){ //unlocked
        fish1 = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Character-Puffer-Jump-1.png"]];
        
        
    }else //locked
    {
        fish1 = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Character-Puffer-1-Imprint.png"]];
    }
    
    
    
    if ([[fishDic objectForKey:@"narwhal"] isEqualToNumber:[NSNumber numberWithBool:YES]]){ //unlocked
        fish2 = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Character-Narwhal-1.png"]];
        
        
    }else //locked
    {
        fish2 = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Character-Narwhal-1-Imprint.png"]];
    }
    
    
    
    
    if ([[fishDic objectForKey:@"piranha"] isEqualToNumber:[NSNumber numberWithBool:YES]]){ //unlocked
        fish3 = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Character-Piranha-1.png"]];
        
        
    }else //locked
    {
        fish3 = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Character-Piranha-1-Imprint.png"]];
    }
    
    if ([[fishDic objectForKey:@"angler"] isEqualToNumber:[NSNumber numberWithBool:YES]]){ //unlocked
        fish4 = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Character-Angler-1.png"]];
        
        
    }else //locked
    {
        fish4 = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Character-Angler-1-Imprint.png"]];
    }
    
    if ([[fishDic objectForKey:@"zombie"] isEqualToNumber:[NSNumber numberWithBool:YES]]){ //unlocked
        fish5 = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Character-Skelly-1.png"]];
        
        
    }else //locked
    {
        fish5 = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"Character-Skelly-1.png"]];
        [fish5 setVisible:NO];
    }
    
    fish1.scale = 2;
    fish2.scale = 2;
    fish3.scale = 2;
    fish4.scale = 2;
    fish5.scale = 2;
    
    //setting positions of the fish buttons
    [fish1 setPosition:ccp(frame.position.x - frame.contentSize.width/3 - fish1.contentSize.width/2, frame.position.y + frame.contentSize.height/4 + fish1.contentSize.height/2)];
    //this line should change the fish
    [fish1 setTarget:self selector:@selector(fish1Selected)];
    [self addChild:fish1];
    [fish2 setPosition:ccp(frame.position.x + frame.contentSize.width/3.5 + fish2.contentSize.width/2, frame.position.y +frame.contentSize.height/4 + fish2.contentSize.height/2)];
    //[fish2 setPosition: ccp(frame.position.x, frame.position.y)];
    //this line should change the fish
    [fish2 setTarget:self selector:@selector(fish2Selected)];
    [self addChild:fish2];
    
    [fish3 setPosition:ccp(frame.position.x - frame.contentSize.width/3 - fish3.contentSize.width/2, frame.position.y - frame.contentSize.height/4 - fish3.contentSize.height/2)];
    //this line should change the fish
    [fish3 setTarget:self selector:@selector(fish3Selected)];
    [self addChild:fish3];
    
    [fish4 setPosition:ccp(frame.position.x + frame.contentSize.width/3.2 + fish4.contentSize.width/2, frame.position.y - frame.contentSize.height/4 - fish4.contentSize.height/2)];
    //this line should change the fish
    [fish4 setTarget:self selector:@selector(fish4Selected)];
    [self addChild:fish4];
    
    [fish5 setPosition:ccp(frame.position.x, frame.position.y)];
    //this line should change the fish
    [fish5 setTarget:self selector:@selector(fish5Selected)];
    [self addChild:fish5];
    
    
    _unlockText = [[CCLabelBMFont alloc] initWithFile:@"krackgames-font.png" capacity:10];
    [_unlockText setFntFile:@"krackgames-font.fnt"];
    _unlockText.anchorPoint = ccp(0.5f,0.5f);
    _unlockText.scale = 0.8f;
    _unlockText.positionType = CCPositionTypeNormalized;
    [_unlockText setPosition:ccp(0.5f, 0.1f)];
    [frame addChild:_unlockText];
    [_unlockText setVisible:NO];
}


-(void)fish1Selected
{
    
    if([[GameState sharedGameState] curSelectedFish] != 0){
        [[GameState sharedGameState] setCurSelectedFish:0 ];
        [[GameState sharedGameState] saveState];
        [[MenuScene sharedMenuScene] selectNewFish:[[BlowFish alloc]init]];
        
    }
    
    [[MenuScene sharedMenuScene] transitionFromCharSelectToMain];
    
}


-(void)fish2Selected
{
    
    if ([[[[GameState sharedGameState] unlockedFishes] objectForKey:@"narwhal"] isEqualToNumber:[NSNumber numberWithBool:YES]]) {
        if([[GameState sharedGameState] curSelectedFish] != 1){
            [[GameState sharedGameState] setCurSelectedFish:1 ];
            [[GameState sharedGameState] saveState];
            [[MenuScene sharedMenuScene] selectNewFish:[[Narwhal alloc]init]];
        }
        
        [[MenuScene sharedMenuScene] transitionFromCharSelectToMain];
    }else{
        FFFModalView *modal = [[FFFModalView alloc] initBuyNarwhalModal];
        [self addChild:modal z:30];
        [modal displayModal];
    
    }

    
}

-(void)fish3Selected
{
    if ([[[[GameState sharedGameState] unlockedFishes] objectForKey:@"piranha"] isEqualToNumber:[NSNumber numberWithBool:YES]]) {
        if([[GameState sharedGameState] curSelectedFish] != 2){
            [[GameState sharedGameState] setCurSelectedFish:2];
            [[GameState sharedGameState] saveState];
            [[MenuScene sharedMenuScene] selectNewFish:[[Piranha alloc]init]];
        }
        [[MenuScene sharedMenuScene] transitionFromCharSelectToMain];
    }else{
        FFFModalView *modal = [[FFFModalView alloc] initBuyPiranhaModal];
        [self addChild:modal z:30];
        [modal displayModal];
    }
    
}

-(void)fish4Selected
{
    if ([[[[GameState sharedGameState] unlockedFishes] objectForKey:@"angler"] isEqualToNumber:[NSNumber numberWithBool:YES]] ) {
        if([[GameState sharedGameState] curSelectedFish] != 3){
            [[GameState sharedGameState] setCurSelectedFish:3];
            [[GameState sharedGameState] saveState];
            [[MenuScene sharedMenuScene] selectNewFish:[[Angler alloc]init]];
        }
        [[MenuScene sharedMenuScene] transitionFromCharSelectToMain];
    }else{
        [_unlockText setVisible:YES];
        [_unlockText setString:@"score ??? to unlock"];

    }
}

-(void)fish5Selected
{
    if ([[[[GameState sharedGameState] unlockedFishes] objectForKey:@"zombie"] isEqualToNumber:[NSNumber numberWithBool:YES]] ) {
        if([[GameState sharedGameState] curSelectedFish] != 4){
            [[GameState sharedGameState] setCurSelectedFish:4];
            [[GameState sharedGameState] saveState];
            [[MenuScene sharedMenuScene] selectNewFish:[[Skelly alloc]init]];
        }
        [[MenuScene sharedMenuScene] transitionFromCharSelectToMain];
    }else{
    }
}


-(void) dealloc
{
    CCLOG(@"removing charselect");
    
    [self removeAllChildrenWithCleanup:YES];
    [frame removeAllChildrenWithCleanup:YES];
    frame = nil;
}




@end
