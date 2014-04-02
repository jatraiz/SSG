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
#import <SSGOGL/SSGMathUtils.h>
#import "ButtonViewController.h"

@interface CardDeckExampleViewController ()<ButtonViewControllerDelegate>

@property (nonatomic, strong) SSGOpenGLManager *glmgr;
@property (nonatomic, strong) NSMutableArray *cards;
@property (nonatomic, strong) ButtonViewController *buttonViewController;
@property (nonatomic, assign) BOOL cardsStacked;
@property (nonatomic, strong) SSGModel *touchedModel;
@property (nonatomic, assign) CGPoint selectedColumnAndRow;
@property (nonatomic, assign) NSUInteger selectedCardIndex;
@end

@implementation CardDeckExampleViewController

static const int kNcards = 12;
static const int kNcolumns = 3;
static const int kNrows = 4;
static  GLfloat kDeltCardXPosArr[kNcolumns];
static  GLfloat kDeltCardYPosArr[kNrows];

static const GLfloat kMainZ = -150.0f;
static const GLfloat kDeltPickedUpZAdj = 4.0f;
static const GLfloat kPickUpZChangeDuration = 0.06f;
static const GLfloat kDeltSnapDuration = 0.2f;
static const GLfloat kDeltSnapDelayAdj = 0.1f;
static const GLfloat kDeltDropSortTolerance = 1.0f;
static const GLfloat kXspreadStartPos = -2.25f;
static const GLfloat kYspreadStartPos = 5.0f;
static const GLfloat kXSpacing = 2.25f;
static const GLfloat kYSpacing = 2.5f;
static const GLfloat kZspacing = 0.25f;
static const GLfloat kStackedZTop = -50.0f;
static const GLfloat kPreDealZRotation = 1.0f;
static const GLfloat kRotationMultiplierOnPlaceMin = 0.5f;
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
    self.glmgr.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(5.0f), fabsf(self.view.bounds.size.width / self.view.bounds.size.height), 0.1f, 200.0f);
    self.glmgr.zConverter = [[SSG2DZConverter alloc] initWithScreenHeight:self.view.bounds.size.height ScreenWidth:self.view.bounds.size.width Fov:GLKMathDegreesToRadians(5.0f)];
    
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
    self.view.multipleTouchEnabled = NO;
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
        m.dimensions2d = CGPointMake(2.0f, 2.0f);
        
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
        [m clearAllCommands];
        
        m.alpha = 1.0f;
        m.prs.position = kLowerRightStartingVector;
        m.prs.rz = kPreDealZRotation;
        
        m.isHidden = NO;
        
        
        [m addCommand:[SSGCommand commandWithEnum:kSSGCommand_moveTo Target:command3float(xPos, yPos, kMainZ) Duration:durationOfThrow IsAbsolute:YES Delay:runningDelay]];
        [m addCommand:[SSGCommand commandWithEnum:kSSGCommand_rotateTo Target:command3float(0.0f, 0.0f, [SSGMathUtils randomGLfloatBetweenMin:-0.075f Max:0.075f]) Duration:durationOfThrow IsAbsolute:YES Delay:runningDelay]];
        
        if(i < kNcolumns)
        {
            kDeltCardXPosArr[i] = xPos;
        }
        
        if(rowCount < kNrows)
        {
            kDeltCardYPosArr[rowCount] = yPos;
        }
        
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
        [m clearAllCommands];
        m.isHidden = NO;
        
        GLfloat targetX = 0.0f;
        GLfloat targetY = 0.0f;
        
        if(i != 0)
        {
           targetX = ((GLfloat)(arc4random_uniform(99) + 1) - 50.0f) * 0.005;
           targetY = ((GLfloat)(arc4random_uniform(99) + 1) - 50.0f) * 0.005;
        }
        
        [m addCommand:[SSGCommand commandWithEnum:kSSGCommand_moveTo Target:command3float(targetX, targetY, zPos) Duration:duration IsAbsolute:YES Delay:runningDelay]];
        [m addCommand:[SSGCommand commandWithEnum:kSSGCommand_alpha Target:command1float(0.75f) Duration:duration * 0.5f IsAbsolute:YES Delay:runningDelay]];
        
        if(i == 0)
        {
            [m addCommand:[SSGCommand commandWithEnum:kSSGCommand_alpha Target:command1float(1.0f) Duration:duration * 0.5f IsAbsolute:YES Delay:runningDelay + duration * 0.5f]];
        }
        
        GLfloat randZ = ((GLfloat)(arc4random_uniform(99) + 1) - 50.0f) * 0.001;
  
        [m addCommand:[SSGCommand commandWithEnum:kSSGCommand_rotateTo Target:command3float(0.0f, 0.0f, randZ) Duration:duration IsAbsolute:YES Delay:runningDelay]];
        
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
        m.isHidden = NO;
        
        [m addCommand:[SSGCommand commandWithEnum:kSSGCommand_moveTo Target:command3float(xPos, yPos, kMainZ) Duration:durationOfThrow IsAbsolute:YES Delay:runningDelay]];
        [m addCommand:[SSGCommand commandWithEnum:kSSGCommand_rotateTo Target:command3float(0.0f, 0.0f, [SSGMathUtils randomGLfloatBetweenMin:-0.075f Max:0.075f]) Duration:durationOfThrow IsAbsolute:YES Delay:runningDelay]];
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


- (CGPoint)getRowAndColumnOfModel:(SSGModel *)m
{
    CGPoint point = CGPointZero;
    
    for(int i = 0; i < kNcolumns; ++i)
    {
        if(m.prs.px == kDeltCardXPosArr[i])
        {
            point.x = i;
            break;
        }
    }
    
    for(int i = 0; i < kNrows; ++i)
    {
        if(m.prs.py == kDeltCardYPosArr[i])
        {
            point.y = i;
            break;
        }
    }
    
    return point;
}

- (CGPoint)calculateXYOfModelWithIndex:(int)index
{
    int colNumber = index % kNcolumns;
    int rowNumber = index / kNcolumns;
    
    return CGPointMake(kDeltCardXPosArr[colNumber], kDeltCardYPosArr[rowNumber]);
}

- (void)handleDeltCardDrop
{
    BOOL cardIntersectsAnother = NO;
    NSUInteger intersectionIndex = 0;
    
    for(SSGModel *m in self.cards)
    {
        if(m != self.touchedModel)
        {
            GLfloat xDist = fabsf(self.touchedModel.prs.px - m.prs.px);
            GLfloat yDist = fabsf(self.touchedModel.prs.py - m.prs.py);
            if(xDist + yDist <= kDeltDropSortTolerance)
            {
                cardIntersectsAnother = YES;
                intersectionIndex= [self.cards indexOfObject:m];
                break;
            }
        }
    }
    
    if(cardIntersectsAnother)
    {
        
        [self.cards removeObject:self.touchedModel];
        [self.cards insertObject:self.touchedModel atIndex:intersectionIndex];
        
        GLfloat runningDelay = 0.0f;
        
        for(int i = 0; i < kNcards; ++i)
        {
            SSGModel *m = self.cards[i];
            CGPoint correctPos = [self calculateXYOfModelWithIndex:i];
            if(m.prs.px != correctPos.x || m.prs.py != correctPos.y)
            {
                if(m.prs.rz != 0.0f)
                {
                    GLfloat newRZ =  m.prs.rz * [SSGMathUtils randomGLfloatBetweenMin:kRotationMultiplierOnPlaceMin Max:1.0f];
                    [m addCommand:[SSGCommand commandWithEnum:kSSGCommand_rotateTo Target:command3float(m.prs.rx, m.prs.ry, newRZ) Duration:kDeltSnapDuration IsAbsolute:YES Delay:runningDelay]];
                }
                [m addCommand:[SSGCommand commandWithEnum:kSSGCommand_moveTo Target:command3float(correctPos.x, correctPos.y, kMainZ) Duration:kDeltSnapDuration IsAbsolute:YES Delay:runningDelay]];
                runningDelay += kDeltSnapDelayAdj;
            }
        }
    }
    else
    {
        [self.touchedModel addCommand:[SSGCommand commandWithEnum:kSSGCommand_moveTo Target:command3float(kDeltCardXPosArr[(int)self.selectedColumnAndRow.x],kDeltCardYPosArr[(int)self.selectedColumnAndRow.y] , kMainZ) Duration:kDeltSnapDuration IsAbsolute:YES Delay:0.0f]];
    }
    
    self.touchedModel = nil;
}

- (SSGModel*)getTouchedModelFromTouchPoint:(CGPoint)touchPoint
{
    CGPoint transformedPoint = [self.glmgr.zConverter convertScreenPt:touchPoint ProjecteZ:kMainZ];
    
    for(SSGModel *m in self.cards)
    {
        if([m isTransformedPointWithinModel2d:transformedPoint])
        {
            return m;
        }
    }
    return nil;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.view];
    self.touchedModel = [self getTouchedModelFromTouchPoint:touchPoint];
    if(self.touchedModel)
    {
        self.selectedCardIndex = [self.cards indexOfObject:self.touchedModel];
        self.selectedColumnAndRow = [self getRowAndColumnOfModel:self.touchedModel];
        [self.touchedModel addCommand:[SSGCommand commandWithEnum:kSSGCommand_moveTo Target:command3float(0.0f, 0.0f, kDeltPickedUpZAdj) Duration:kPickUpZChangeDuration IsAbsolute:NO Delay:0.0f]];

    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(self.touchedModel)
    {
        UITouch *touch = [touches anyObject];
        CGPoint currentPoint = [touch locationInView:self.view];
        CGPoint transformedPoint = [self.glmgr.zConverter convertScreenPt:currentPoint ProjecteZ:self.touchedModel.prs.pz];
        self.touchedModel.prs.px = transformedPoint.x;
        self.touchedModel.prs.py = transformedPoint.y;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(self.touchedModel)
    {
        [self handleDeltCardDrop];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(self.touchedModel)
    {
        [self handleDeltCardDrop];
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
