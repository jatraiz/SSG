//
//  CardDecExampleViewController.m
//  CardDeckExample
//
//  Created by John Stricker on 3/28/14.
//  Copyright (c) 2014 John Stricker. All rights reserved.
//

#import "CardDeckExampleViewController.h"
#import <SSGOGL/SSGOpenGLManager.h>
#import <SSGOGL/SSG2DZConverter.h>
#import <SSGOGL/SSGModel.h>
#import <SSGOGL/SSGAssetManager.h>
#import <SSGOGL/SSGPrs.h>
#import <SSGOGL/SSGCommand.h>
#import "ButtonViewController.h"

@interface CardDeckExampleViewController ()<ButtonViewControllerDelegate>

@property (nonatomic, strong) SSGOpenGLManager *glmgr;
@property (nonatomic, strong) NSMutableArray *cards;
@property (nonatomic, strong) ButtonViewController *buttonViewController;
@property (nonatomic, assign) BOOL cardsStacked;
@end

@implementation CardDeckExampleViewController

static const int kNcards = 12;
static const int kNcolumns = 3;
static const int kNrows = 4;

static const GLfloat kMainZ = -30.0f;
static const GLfloat kXspreadStartPos = -2.25f;
static const GLfloat kYspreadStartPos = 5.0f;
static const GLfloat kXSpacing = 2.25f;
static const GLfloat kYSpacing = 2.5f;
static const GLfloat kZspacing = 0.25f;
static const GLfloat kStackedZTop = -10.0f;
static const GLfloat kPreDealZRotation = 1.0f;
static GLKVector3 kLowerRightStartingVector;


- (void)viewDidLoad
{
    [super viewDidLoad];
    //engine setup
    self.glmgr = [[SSGOpenGLManager alloc] initWithContextRef:((GLKView *)self.view).context andView:(GLKView *)self.view];
    //load the default shader
    [self.glmgr loadDefaultShaderAndSettings];
    
    //main background color of the window (including transparency)
    [self.glmgr setClearColor:GLKVector4Make(0.8f, 0.8f, 0.8f, 1.0f)];
    
    //setting up perspective
    self.glmgr.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(25.0f), fabsf(self.view.bounds.size.width / self.view.bounds.size.height), 0.1f, 100.0f);
    self.glmgr.zConverter = [[SSG2DZConverter alloc] initWithScreenHeight:self.view.bounds.size.width ScreenWidth:self.view.bounds.size.height Fov:GLKMathDegreesToRadians(25.0f)];
    
    //settings for max smoothness in animation & display
    self.preferredFramesPerSecond = 60;
    ((GLKView*)self.view).drawableMultisample = GLKViewDrawableMultisample4X;
    
    kLowerRightStartingVector = GLKVector3Make(10.0f, -10.0f, kMainZ);
    
    [self createCards];
    
    self.buttonViewController = [[ButtonViewController alloc] init];
    CGRect frame = self.buttonViewController.view.frame;
    frame.origin.y = 520;
    self.buttonViewController.view.frame = frame;
    self.buttonViewController.delgate = self;
    [self.view addSubview:self.buttonViewController.view];
}

- (void)createCards
{
    self.cards = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < kNcards; ++i)
    {
        SSGModel *m = [[SSGModel alloc] initWithModelFileName:@"squareCard"];
        [m setTexture0Id:[SSGAssetManager loadTexture:[NSString stringWithFormat:@"image%i",i+1] ofType:@"png" shouldLoadWithMipMapping:YES]];
        [m setProjection:self.glmgr.projectionMatrix];
        [m setDefaultShaderSettings:self.glmgr.defaultShaderSettings];
         m.diffuseColor = GLKVector4Make(1.0f, 1.0f, 1.0f, 1.0f);
        m.shadowMax = 0.5f;
        m.prs.pz = kMainZ;
        m.isHidden = YES;
        
        [self.cards addObject:m];
    }
}

- (void)dealCards
{
    self.cardsStacked = NO;
    
    GLfloat runningDelay = 0.0f;
    GLfloat delayIncrement = 0.2f;
    GLfloat durationOfThrow = 0.2f;
    GLfloat xPos = kXspreadStartPos;
    GLfloat yPos = kYspreadStartPos;
    int rowCount = 0;
    int columnCount = 0;
    
    for(int i = 0; i < kNcards; ++i)
    {
        SSGModel *m = self.cards[i];
        [m.prs removeAllCommands];
        [m clearAllCommands];
        
        m.alpha = 1.0f;
        m.prs.position = kLowerRightStartingVector;
        m.prs.rz = kPreDealZRotation;
        
        m.isHidden = NO;
        
        
        [m.prs moveToVector:GLKVector3Make(xPos, yPos, kMainZ) Duration:durationOfThrow Delay:runningDelay IsAbsolute:YES];
        [m.prs rotateToVector:GLKVector3Make(0, 0, -kPreDealZRotation) Duration:durationOfThrow Delay:runningDelay IsAbsolute:NO];
        
        
        ++columnCount;
        if(columnCount == kNcolumns)
        {
            columnCount = 0;
            ++rowCount;
        }
        
        xPos = kXspreadStartPos + (columnCount * kXSpacing);
        yPos = kYspreadStartPos - (rowCount * kYSpacing);
        
        runningDelay += delayIncrement;
    }
}

- (void)stackCards
{
    self.cardsStacked = YES;
    
    GLfloat zPos = kStackedZTop;
    GLfloat duration = 0.25f;
    GLfloat runningDelay = 0.0f;
    GLfloat delayIncrement = 0.1f;
    
    for(int i = kNcards-1; i >= 0; --i)
    {
        zPos = kStackedZTop - (kZspacing * i);
        
        SSGModel *m = self.cards[i];
        [m.prs removeAllCommands];
        [m clearAllCommands];
        m.isHidden = NO;
        
        GLfloat targetX = 0.0f;
        GLfloat targetY = 0.0f;
        
        if(i != 0)
        {
           targetX = ((GLfloat)(arc4random_uniform(99) + 1) - 50.0f) * 0.005;
           targetY = ((GLfloat)(arc4random_uniform(99) + 1) - 50.0f) * 0.005;
        }
        
        [m.prs moveToVector:GLKVector3Make(targetX, targetY, zPos) Duration:duration Delay:runningDelay IsAbsolute:YES];
        
        [m addCommand:[SSGCommand commandWithEnum:kSSGCommand_alpha Target:command1float(0.75f) Duration:duration * 0.5f IsAbsolute:YES Delay:runningDelay]];
        
        if(i == 0)
        {
            [m addCommand:[SSGCommand commandWithEnum:kSSGCommand_alpha Target:command1float(1.0f) Duration:duration * 0.5f IsAbsolute:YES Delay:runningDelay + duration * 0.5f]];
        }
        
        GLfloat randZ = ((GLfloat)(arc4random_uniform(99) + 1) - 50.0f) * 0.001;
  
        [m.prs rotateToVector:GLKVector3Make(0.0f, 0.0f, randZ) Duration:duration Delay:runningDelay IsAbsolute:YES];
        
        runningDelay += delayIncrement;
    }
    
}

- (void)sortCards
{
    int count = (int)[self.cards count];
    int shuffleNumber = 5;
    
    for(int i = 0; i < shuffleNumber; ++i)
    {
        for(int j = 0; j < count; ++j)
        {
            int nElements = count - i;
            int n = arc4random_uniform(nElements)+i;
            [self.cards exchangeObjectAtIndex:i withObjectAtIndex:n];
        }
    }
    
    if(self.cardsStacked)
    {
        [self sortStackedCards];
    }
    else
    {
        [self sortDealtCards];
    }
}

- (void)sortDealtCards
{
    self.cardsStacked = NO;
    
    GLfloat runningDelay = 0.0f;
    GLfloat delayIncrement = 0.0f;
    GLfloat durationOfThrow = 0.2f;
    GLfloat xPos = kXspreadStartPos;
    GLfloat yPos = kYspreadStartPos;
    int rowCount = 0;
    int columnCount = 0;
    
    for(int i = 0; i < kNcards; ++i)
    {
        SSGModel *m = self.cards[i];
        [m.prs removeAllCommands];
        [m clearAllCommands];
        
        m.alpha = 1.0f;
      //  m.prs.position = kLowerRightStartingVector;
      //  m.prs.rz = kPreDealZRotation;
        
        m.isHidden = NO;
        
        
        [m.prs moveToVector:GLKVector3Make(xPos, yPos, kMainZ) Duration:durationOfThrow Delay:runningDelay IsAbsolute:YES];
    //    [m.prs rotateToVector:GLKVector3Make(0, 0, -kPreDealZRotation) Duration:durationOfThrow Delay:runningDelay IsAbsolute:NO];
        
        
        ++columnCount;
        if(columnCount == kNcolumns)
        {
            columnCount = 0;
            ++rowCount;
        }
        
        xPos = kXspreadStartPos + (columnCount * kXSpacing);
        yPos = kYspreadStartPos - (rowCount * kYSpacing);
        
        runningDelay += delayIncrement;
    }

}

- (void)sortStackedCards
{
    [self stackCards];
}

- (void)update
{
  for(SSGModel *m in self.cards)
  {
      [m updateWithTime:self.timeSinceLastUpdate];
  }
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    for(SSGModel *m in self.cards)
    {
        [m draw];
    }
  
}

- (void)buttonViewDealPressed
{
    [self dealCards];
}

- (void)buttonViewStackPressed
{
    [self stackCards];
}

- (void)buttonViewSortPressed
{
    [self sortCards];
}
@end
