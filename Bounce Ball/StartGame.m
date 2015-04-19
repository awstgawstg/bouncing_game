

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




- (SKSpriteNode *)howToPlayNode
{
    SKSpriteNode *fireNode = [SKSpriteNode spriteNodeWithImageNamed:@"start"];
    fireNode.size= CGSizeMake(self.frame.size.width/2, self.frame.size.height/8);
    fireNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)*6/10);
    fireNode.name = @"startNode";//how the node is identified later
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
        [self runAction:
         
         [SKAction runBlock:^{
            // 5
            SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
            SKScene * myScene = [[GameScene alloc] initWithSize:self.size];
            [self.view presentScene:myScene transition: reveal];
        }        ]];
    }
}









@end
