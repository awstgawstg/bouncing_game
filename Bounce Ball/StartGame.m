

#import "GameOverScene.h"
#import "GameScene.h"
#import "StartGame.h"



@implementation StartGame


// game over scence will get the best time and also pass the gameoverTime
-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        
        // 1
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        [self addChild: [self startNode]];
        [self addChild: [self startNode1]];
        [self addChild: [self startNode2]];
        SKLabelNode *myTimeLabel=[SKLabelNode labelNodeWithFontNamed:@"Times"];
        NSString * yourtime=@"Welcome To Bounce Ball";
        myTimeLabel.text = yourtime;
        myTimeLabel.fontSize = 30;
        myTimeLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)*9/7);
        myTimeLabel.fontColor = [SKColor colorWithRed:0 green:0 blue:0 alpha:1.0];
        myTimeLabel.name = @"myTimeLabel";
        [self addChild:myTimeLabel];
    }
    return self;
}




- (SKSpriteNode *)startNode
{
    SKSpriteNode *fireNode = [SKSpriteNode spriteNodeWithImageNamed:@"start"];
    fireNode.size= CGSizeMake(self.frame.size.width/2, self.frame.size.height/8);
    fireNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)*7/10);
    fireNode.name = @"startNode";//how the node is identified later
    fireNode.zPosition = 1.0;
    return fireNode;
}





- (SKSpriteNode *)startNode1
{
    SKSpriteNode *fireNode = [SKSpriteNode spriteNodeWithImageNamed:@"start"];
    fireNode.size= CGSizeMake(self.frame.size.width/2, self.frame.size.height/8);
    fireNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)*5/10);
    fireNode.name = @"startNode1";//how the node is identified later
    fireNode.zPosition = 1.0;
    return fireNode;
}




- (SKSpriteNode *)startNode2
{
    SKSpriteNode *fireNode = [SKSpriteNode spriteNodeWithImageNamed:@"start"];
    fireNode.size= CGSizeMake(self.frame.size.width/2, self.frame.size.height/8);
    fireNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)*3/10);
    fireNode.name = @"startNode2";//how the node is identified later
    fireNode.zPosition = 1.0;
    return fireNode;
}





//get the touch button action
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    //if fire button touched, bring the rain
    if ([node.name isEqualToString:@"startNode"]) {
        [self runAction:[SKAction playSoundFileNamed:@"button.mp3" waitForCompletion:YES]];

        [self runAction:
         
         [SKAction runBlock:^{
            // 5
            SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
            SKScene * myScene = [[GameScene alloc] initWithSize:self.size mode:1];
            [self.view presentScene:myScene transition: reveal];
        }        ]];
    }
    
    
    
    if ([node.name isEqualToString:@"startNode1"]) {
        [self runAction:[SKAction playSoundFileNamed:@"button.mp3" waitForCompletion:YES]];

        [self runAction:
         
         [SKAction runBlock:^{
            // 5
            SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
            SKScene * myScene = [[GameScene alloc] initWithSize:self.size mode:2];
            [self.view presentScene:myScene transition: reveal];
        }        ]];
        
    }
    
    
    if ([node.name isEqualToString:@"startNode2"]) {
        [self runAction:[SKAction playSoundFileNamed:@"button.mp3" waitForCompletion:YES]];
        [self runAction:
         
         [SKAction runBlock:^{
            // 5
            SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
            SKScene * myScene = [[GameScene alloc] initWithSize:self.size mode:0];
            [self.view presentScene:myScene transition: reveal];
        }        ]];
    }


}









@end
