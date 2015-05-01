#import "GameOverScene.h"
#import "GameScene.h"
#import "StartGame.h"


 
@implementation GameOverScene
NSTimeInterval bestTime;
int type=0;

 // game over scence will get the best time and also pass the gameoverTime
-(id)initWithSize:(CGSize)size time:(NSTimeInterval)gameoverTime mode:(int)gamemode{
    if (self = [super initWithSize:size]) {
        [self runAction:[SKAction playSoundFileNamed:@"gameover.mp3" waitForCompletion:YES]];

        // 1
        type=gamemode;
        self.backgroundColor = [SKColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
 
        // 2
        NSString * message;
      
            message = @"Game Over!";
        
        //get the stored best score
        NSTimeInterval savedScore1 = [[NSUserDefaults standardUserDefaults] floatForKey:@"bestScore1"];
        NSTimeInterval savedScore2 = [[NSUserDefaults standardUserDefaults] floatForKey:@"bestScore2"];
        NSTimeInterval savedScore3 = [[NSUserDefaults standardUserDefaults] floatForKey:@"bestScore3"];
        
        switch (gamemode)
        {
            case 0:
                bestTime = savedScore1;
                break;
            case 1:
                bestTime = savedScore2;
                break;
            case 2:
                bestTime = savedScore3;
                break;
            default:
                break;
        }
        
        // check whether gameovertime will be the best time
        if(bestTime < gameoverTime){
            bestTime = gameoverTime;
        }
        
        switch (gamemode)
        {
            case 0:
                savedScore1 = bestTime;
                break;
            case 1:
                savedScore2 = bestTime;
                break;
            case 2:
                savedScore3 = bestTime;
                break;
            default:
                break;
        }
        
        
        // label for gameover time
        CFGregorianDate elapsedTime  = CFAbsoluteTimeGetGregorianDate(gameoverTime, nil);
        NSString *formattedDateString = [NSString stringWithFormat:@"%02d:%02d:%02.1f", elapsedTime.hour, elapsedTime.minute, elapsedTime.second];
        SKLabelNode *myTimeLabel;
        myTimeLabel = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue"];
        NSString * yourtime=@"Your Time: ";
        myTimeLabel.text = [NSString stringWithFormat:@"%@%@", yourtime, formattedDateString];
        myTimeLabel.fontSize = 30;
        myTimeLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)*5/7);
        myTimeLabel.fontColor = [SKColor colorWithRed:0 green:0 blue:0 alpha:1.0];
        myTimeLabel.name = @"myTimeLabel";
        
        
        
        //label for the best time
        CFGregorianDate elapsedTime1  = CFAbsoluteTimeGetGregorianDate(bestTime, nil);
        NSString *formattedDateString1 = [NSString stringWithFormat:@"%02d:%02d:%02.1f", elapsedTime1.hour, elapsedTime1.minute, elapsedTime1.second];
        SKLabelNode *myTimeLabel1;
        myTimeLabel1 = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue"];
        NSString * yourtime1=@"Best Time: ";
        myTimeLabel1.text = [NSString stringWithFormat:@"%@%@", yourtime1, formattedDateString1];
        myTimeLabel1.fontSize = 30;
        myTimeLabel1.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)*7/8);
        myTimeLabel1.fontColor = [SKColor colorWithRed:0 green:0 blue:0 alpha:1.0];
        myTimeLabel1.name = @"myTimeLabel1";

        
        [self addChild:myTimeLabel];
        [self addChild:myTimeLabel1];
        
        //store best score
        [[NSUserDefaults standardUserDefaults] setFloat:savedScore1 forKey:@"bestScore1"];
        [[NSUserDefaults standardUserDefaults] setFloat:savedScore2 forKey:@"bestScore2"];
        [[NSUserDefaults standardUserDefaults] setFloat:savedScore3 forKey:@"bestScore3"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    
        //add the game over
        SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
        label.text = message;
        label.fontSize = 40;
        label.fontColor = [SKColor blackColor];
        label.position = CGPointMake(self.size.width/2, self.size.height/2);
        [self addChild:label];
        [self addChild: [self fireButtonNode]];
        [self addChild: [self startNode]];

    }
    return self;
}


// addd the button on the sence
- (SKSpriteNode *)fireButtonNode
{
    SKSpriteNode *fireNode = [SKSpriteNode spriteNodeWithImageNamed:@"reset"];
    fireNode.size= CGSizeMake(self.frame.size.width/3, self.frame.size.height/16);
    fireNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)*3/5);
    fireNode.name = @"fireButtonNode";//how the node is identified later
    fireNode.zPosition = 1.0;
    return fireNode;
}


- (SKSpriteNode *)startNode
{
    SKSpriteNode *fireNode = [SKSpriteNode spriteNodeWithImageNamed:@"start"];
    fireNode.size= CGSizeMake(self.frame.size.width/2, self.frame.size.height/8);
    fireNode.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame)*3/10);
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
    if ([node.name isEqualToString:@"fireButtonNode"]) {
        [self runAction:[SKAction playSoundFileNamed:@"button.mp3" waitForCompletion:YES]];

        [self runAction:
         
         [SKAction runBlock:^{
            // 5
            SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
            SKScene * myScene = [[GameScene alloc] initWithSize:self.size mode:type];
           [self.view presentScene:myScene transition: reveal];
        }        ]];
    }
    
    
    
    if ([node.name isEqualToString:@"startNode"]) {
        [self runAction:[SKAction playSoundFileNamed:@"button.mp3" waitForCompletion:YES]];

        [self runAction:
         
         [SKAction runBlock:^{
            // 5
            SKTransition *reveal = [SKTransition flipHorizontalWithDuration:0.5];
            SKScene * myScene = [[StartGame alloc] initWithSize:self.size];
            [self.view presentScene:myScene transition: reveal];
        }        ]];
    }

    
    
    
    
}







@end
