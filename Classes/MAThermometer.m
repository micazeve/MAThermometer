//
//  MAThermometer.m
//  MAThermometer-Demo
//
//  Created by Michael Azevedo on 16/06/2014.
//

#import "MAThermometer.h"
#import "MAThermometerBorder.h"

@interface MAThermometer ()
{
    CGFloat customGradientValues[8];
    CGFloat * colorsValue;
}

@property (nonatomic, assign) CGFloat span;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat yOffset;

@property (nonatomic, assign) CGFloat lineWidth;

// Lower part of the thermometer
@property (nonatomic, assign) CGFloat lowerCircleRadius;
@property (nonatomic, assign) CGPoint lowerCircleCenter;
@property (nonatomic, assign) CGPoint lowerCircleFirst;
@property (nonatomic, assign) CGPoint lowerCircleMiddle;
@property (nonatomic, assign) CGPoint lowerCircleSecond;

// Upper part of the thermometer
@property (nonatomic, assign) CGFloat upperCircleRadius;
@property (nonatomic, assign) CGPoint upperCircleCenter;
@property (nonatomic, assign) CGPoint upperCircleFirst;
@property (nonatomic, assign) CGPoint upperCircleMiddle;
@property (nonatomic, assign) CGPoint upperCircleSecond;

@property (nonatomic, strong) MAThermometerBorder * thermometerBorder;
@property (nonatomic, strong) NSMutableArray * arrayPoints;

@end

@implementation MAThermometer

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self customInit];
    }
    return self;
}

-(id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        [self customInit];
    }
    return self;
    
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self customInit];
    }
    return self;
}

-(void)customInit
{
    _thermometerBorder = [[MAThermometerBorder alloc] initWithFrame:self.bounds];
    [self addSubview:_thermometerBorder];
    
    _curValue               = 0;
    _yOffset                = 0;
    _height                 = CGRectGetHeight(self.bounds);
    _arrayPoints            = [[NSMutableArray alloc] init];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    
    if (_height/width > 4) {
        _height = width* 4;
        _yOffset = (CGRectGetHeight(self.bounds) - _height)/2;
    }
    
    _lineWidth              = _height/100.f;
    _lowerCircleRadius      = (_height -2*_lineWidth)/8;
    _lowerCircleCenter      = CGPointMake(CGRectGetMidX(self.bounds), _height - (_lowerCircleRadius + _lineWidth) + _yOffset);
    _lowerCircleFirst       = CGPointMake((_lowerCircleCenter.x - cos(M_PI_4) * _lowerCircleRadius),
                                          (_lowerCircleCenter.y - sin(M_PI_4) * _lowerCircleRadius));
    _lowerCircleMiddle      = CGPointMake(_lowerCircleCenter.x,
                                          _lowerCircleCenter.y + _lowerCircleRadius);
    _lowerCircleSecond      = CGPointMake((_lowerCircleCenter.x + cos(M_PI_4) * _lowerCircleRadius),
                                          (_lowerCircleCenter.y - sin(M_PI_4) * _lowerCircleRadius));
    
    
    _upperCircleRadius      = (_lowerCircleSecond.x - _lowerCircleFirst.x)/2;
    _upperCircleCenter      = CGPointMake(CGRectGetMidX(self.bounds), _lineWidth + _upperCircleRadius+ _yOffset);
    _upperCircleFirst       = CGPointMake(_lowerCircleFirst.x, _upperCircleCenter.y);
    _upperCircleMiddle      = CGPointMake(_upperCircleCenter.x,_upperCircleCenter.y - _upperCircleRadius);
    _upperCircleSecond      = CGPointMake(_lowerCircleSecond.x, _upperCircleCenter.y);
    
    
    [self setArrayColors:@[[UIColor blueColor],
                           [UIColor cyanColor],
                           [UIColor greenColor],
                           [UIColor yellowColor],
                           [UIColor redColor]]];
    [self setMinValue:0 maxValue:100];
        
    // We compute all the points in order to save some time on drawRect method
    
    self.backgroundColor = [UIColor clearColor];
}

#pragma mark - Custom setters

-(void)setCurValue:(CGFloat)curValue
{
    if (curValue < _minValue)
        curValue = _minValue;
    else if (curValue > _maxValue)
        curValue = _maxValue;
    
    _curValue = curValue;
    
    [self setNeedsDisplay];
}

-(void)setMinValue:(CGFloat)minValue
{
    [self setMinValue:minValue maxValue:_maxValue];
}

-(void)setMaxValue:(CGFloat)maxValue
{
    [self setMinValue:_minValue maxValue:maxValue];
}


-(void)setMinValue:(CGFloat)minValue
          maxValue:(CGFloat)maxValue
{
    if (minValue < maxValue) {
        _minValue = minValue;
        _maxValue = maxValue;
    } else {
        _minValue = maxValue;
        _maxValue = minValue;
    }
    _span = _maxValue - _minValue;
    
    [self setCurValue:_curValue];
}

-(void)setDarkTheme:(BOOL)darkTheme
{
    [_thermometerBorder setDarkTheme:darkTheme];
}

-(void)setGlassEffect:(BOOL)glassEffect
{
    [_thermometerBorder setGlassEffect:glassEffect];
}

-(void)setArrayColors:(NSArray *)array
{
   if (array == nil || [array count] == 0)
        return ;
    
    _arrayColors = array;
    
    // If we set only one color, no need to precompute the gradients variables
    if ([_arrayColors count] ==1)
    {
        return;
       
    }
    
    
    if (colorsValue != nil)
        free(colorsValue);
    
    colorsValue = malloc(4* [array count] * sizeof(CGFloat));
    
    [_arrayColors enumerateObjectsUsingBlock:^(UIColor * color, NSUInteger idx, BOOL *stop) {
        
        [color getRed:&(colorsValue[4*idx])
                green:&(colorsValue[4*idx +1])
                 blue:&(colorsValue[4*idx +2])
                alpha:&(colorsValue[4*idx +3])];
    }];
    
    [_arrayPoints removeAllObjects];
    
    NSInteger heightAvailable = _upperCircleMiddle.y - _lowerCircleMiddle.y;
    CGPoint pointTemp;
    for (uint8_t i = 0; i < [_arrayColors count] ; ++i)
    {
        pointTemp = CGPointMake(CGRectGetMidX(self.bounds), _lowerCircleMiddle.y + (i*heightAvailable)/((NSInteger)([_arrayColors count]-1)));
        [_arrayPoints addObject:[NSValue valueWithCGPoint:pointTemp]];
    }
    [self setNeedsDisplay];
}

#pragma mark - Custom getters

-(BOOL)darkTheme
{
    return _thermometerBorder.darkTheme;
}

-(BOOL)glassEffect
{
    return _thermometerBorder.glassEffect;
}

#pragma mark - Drawing methods

- (void)drawRect:(CGRect)rect
{
	//FIX: optimise and save some reusable stuff
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextClearRect(context, rect);
    
    
    CGContextAddEllipseInRect(context, CGRectMake(_lowerCircleCenter.x - _lowerCircleRadius, _lowerCircleCenter.y - _lowerCircleRadius,
                                                  _lowerCircleRadius*2, _lowerCircleRadius*2));
    
    CGContextMoveToPoint(context, _lowerCircleFirst.x, _lowerCircleFirst.y);
    
    CGContextAddLineToPoint(context, _upperCircleFirst.x, _upperCircleFirst.y);
    CGContextAddArcToPoint(context, _upperCircleFirst.x, _upperCircleMiddle.y,
                           _upperCircleMiddle.x, _upperCircleMiddle.y, _upperCircleRadius);
    
    CGContextAddArcToPoint(context, _upperCircleSecond.x, _upperCircleMiddle.y,
                           _upperCircleSecond.x,_upperCircleSecond.y, _upperCircleRadius);
    CGContextAddLineToPoint(context, _lowerCircleSecond.x, _lowerCircleSecond.y);
    
    CGContextClosePath(context);
    CGContextSaveGState(context);
    CGContextClip(context);

    NSInteger index = 0;
    CGFloat valueMin = _minValue;
    CGFloat valueMax = 0;
    
    if ([_arrayColors count] == 1)
    {
        CGContextSetFillColorWithColor(context, ((UIColor *)_arrayColors[0]).CGColor);
        
        CGFloat originY = _lowerCircleMiddle.y - (_lowerCircleMiddle.y -_upperCircleMiddle.y)*(_curValue-_minValue)/_span;
        
        CGContextAddRect(context, CGRectMake(CGRectGetMinX(self.bounds),
                                             originY,
                                             CGRectGetWidth(self.bounds),
                                             _lowerCircleMiddle.y - originY));
        
        CGContextFillPath(context);
        
        return;
    }
    
    
    while (_curValue > valueMin)
    {
        valueMax = (index+1)/((CGFloat)([_arrayColors count]-1))*_span;
        
        if (_curValue > _minValue + valueMax)
        {
            [self drawFullGradientNum:index withBaseSpace:baseSpace inContext:context];
        }
        else
        {
            [self drawIntermediateGradientNum:index withBaseSpace:baseSpace inContext:context];
        }
        valueMin = valueMax;
        index ++;
    }
    
    CGContextRestoreGState(context);
    CGColorSpaceRelease(baseSpace), baseSpace = NULL;
<<<<<<< HEAD
=======
    
>>>>>>> FETCH_HEAD
}


-(void)drawFullGradientNum:(uint8_t)numGrad withBaseSpace:(CGColorSpaceRef) baseSpace inContext:(CGContextRef) context
{
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, colorsValue + numGrad*4, NULL, 2);
    CGContextDrawLinearGradient(context, gradient,  [_arrayPoints[numGrad] CGPointValue],  [_arrayPoints[numGrad+1] CGPointValue], 0);
    CGGradientRelease(gradient), gradient = NULL;
}

-(void)drawIntermediateGradientNum:(uint8_t)numGrad withBaseSpace:(CGColorSpaceRef) baseSpace inContext:(CGContextRef) context
{
    CGFloat percent = (_curValue - _minValue)/(_maxValue - _minValue);
    CGFloat percentGradient = ([_arrayColors count] -1) * percent - numGrad;
 
    CGFloat rValue = percentGradient * colorsValue[((numGrad+1)*4)] + (1.f-percentGradient) * colorsValue[(numGrad *4)];
    CGFloat gValue = percentGradient * colorsValue[((numGrad+1)*4) +1] + (1.f-percentGradient) * colorsValue[(numGrad *4) +1];
    CGFloat bValue = percentGradient * colorsValue[((numGrad+1)*4) +2] + (1.f-percentGradient) * colorsValue[(numGrad *4) +2];
    CGFloat aValue = percentGradient * colorsValue[((numGrad+1)*4) +3] + (1.f-percentGradient) * colorsValue[(numGrad *4) +3];
    
    customGradientValues[0]     = colorsValue[numGrad *4];
    customGradientValues[1]     = colorsValue[(numGrad *4) +1];
    customGradientValues[2]     = colorsValue[(numGrad *4) +2];
    customGradientValues[3]     = colorsValue[(numGrad *4) +3];
    customGradientValues[4]     = rValue;
    customGradientValues[5]     = gValue;
    customGradientValues[6]     = bValue;
    customGradientValues[7]     = aValue;
    
    CGPoint sommet = CGPointMake([_arrayPoints[numGrad] CGPointValue].x,
                                 [_arrayPoints[numGrad] CGPointValue].y + ([_arrayPoints[numGrad+1] CGPointValue].y - [_arrayPoints[numGrad] CGPointValue].y)*percentGradient);
    
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, customGradientValues, NULL, 2);
    CGContextDrawLinearGradient(context, gradient,  [_arrayPoints[numGrad] CGPointValue], sommet, 0);
    CGGradientRelease(gradient), gradient = NULL;
}

#pragma mark - Memory management

-(void)dealloc
{
    if (colorsValue != nil)
    free(colorsValue);
}

@end
