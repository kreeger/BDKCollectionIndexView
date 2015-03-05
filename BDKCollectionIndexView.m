#import "BDKCollectionIndexView.h"

#import <QuartzCore/QuartzCore.h>

@interface BDKCollectionIndexView ()

/**
 A component that shows up under the letters to indicate the view is handling a touch or a pan.
 */
@property (strong, nonatomic) UIView *touchStatusView;

/**
 The collection of label subviews that are displayed (one for each index title).
 */
@property (strong, nonatomic) NSArray *indexLabels;

/**
 A gesture recognizer that handles panning.
 */
@property (strong, nonatomic) UIPanGestureRecognizer *panner;

/**
 A gesture recognizer that handles tapping.
 */
@property (strong, nonatomic) UITapGestureRecognizer *tapper;

/**
 Handles events sent by the tap gesture recognizer.
 
 @param recognizer the sender of the event; usually a UIPanGestureRecognizer.
 */
- (void)handleTap:(UITapGestureRecognizer *)recognizer;

/**
 Handles events sent by the pan gesture recognizer.
 
 @param recognizer the sender of the event; usually a UIPanGestureRecognizer.
 */
- (void)handlePan:(UIPanGestureRecognizer *)recognizer;

/**
 Handles logic for determining which label is under a given touch point, and sets `currentIndex` accordingly.
 
 @param point the touch point.
 */
- (void)setNewIndexForPoint:(CGPoint)point;

/**
 Handles setting the alpha component level for the background color on the `touchStatusView`.
 
 @param flag if `YES`, the `touchStatusView` is set to be visible and dark-ish.
 */
- (void)setBackgroundVisibility:(BOOL)flag;

@end

@implementation BDKCollectionIndexView

@synthesize currentIndex = _currentIndex, direction = _direction, labelColor = _labelColor, backgroundColor = _backgroundColor;

+ (instancetype)indexViewWithFrame:(CGRect)frame indexTitles:(NSArray *)indexTitles {
    return [[self alloc] initWithFrame:frame indexTitles:indexTitles];
}

- (instancetype)initWithFrame:(CGRect)frame indexTitles:(NSArray *)indexTitles {
    self = [super initWithFrame:frame];
    if (!self) return nil;
    
    if (CGRectGetWidth(frame) > CGRectGetHeight(frame))
        _direction = BDKCollectionIndexViewDirectionHorizontal;
    else _direction = BDKCollectionIndexViewDirectionVertical;
    
    _currentIndex = 0;
    _labelColor = [UIColor blackColor];
    _backgroundColor = [UIColor clearColor];
    
    _panner = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self addGestureRecognizer:_panner];
    _tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:_tapper];
    
    [self addSubview:self.touchStatusView];
    
    self.indexTitles = indexTitles;
    
    return self;
}

- (void)layoutSubviews {
    CGSize labelSize;
    CGFloat dimension;
    CGFloat totalLabelsSize;
    CGFloat positionOffset;
    
    switch (_direction) {
        case BDKCollectionIndexViewDirectionHorizontal:
            dimension = CGRectGetHeight(self.frame);
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                labelSize = CGSizeMake(dimension - 6, dimension);
            } else {
                labelSize = CGSizeMake(dimension - 2, dimension);
            }
            totalLabelsSize = self.indexLabels.count * labelSize.width;
            
            while (totalLabelsSize > self.frame.size.width) {
                labelSize = CGSizeMake(labelSize.width - 1, labelSize.height);
                totalLabelsSize = self.indexLabels.count * labelSize.width;
            }
            
            positionOffset = self.frame.size.width / 2 - totalLabelsSize / 2 - 2;
            break;
        case BDKCollectionIndexViewDirectionVertical:
            dimension = CGRectGetWidth(self.frame);
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                labelSize = CGSizeMake(dimension, dimension - 6);
            } else {
                labelSize = CGSizeMake(dimension, dimension - 2);
            }
            totalLabelsSize = self.indexLabels.count * labelSize.height;
            
            while (totalLabelsSize > self.frame.size.height) {
                labelSize = CGSizeMake(labelSize.width, labelSize.height - 1);
                totalLabelsSize = self.indexLabels.count * labelSize.height;
            }
            
            positionOffset = self.frame.size.height / 2 - totalLabelsSize / 2 - 6;
            break;
    }
    
    for (UILabel *label in self.indexLabels) {
        switch (self.direction) {
            case BDKCollectionIndexViewDirectionHorizontal:
                label.frame = (CGRect){ { positionOffset, 0 }, labelSize };
                positionOffset += CGRectGetWidth(label.frame);
                break;
            case BDKCollectionIndexViewDirectionVertical:
                label.frame = (CGRect){ { 0, positionOffset }, labelSize };
                positionOffset += CGRectGetHeight(label.frame);
                break;
        }
    }
    
    self.touchStatusView.frame = CGRectInset(self.bounds, 2, 2);
    self.touchStatusView.layer.cornerRadius = floorf(dimension / 2.75);
}

#pragma mark - Properties

- (UIView *)touchStatusView {
    if (_touchStatusView) return _touchStatusView;
    _touchStatusView = [[UIView alloc] initWithFrame:CGRectInset(self.bounds, 2, 2)];
    _touchStatusView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    CGFloat dimension;
    switch (_direction) {
        case BDKCollectionIndexViewDirectionHorizontal:
            dimension = CGRectGetHeight(self.frame);
        case BDKCollectionIndexViewDirectionVertical:
            dimension = CGRectGetWidth(self.frame);
    }
    _touchStatusView.layer.cornerRadius = dimension / 2;
    _touchStatusView.layer.masksToBounds = YES;
    return _touchStatusView;
}

- (void)setIndexTitles:(NSArray *)indexTitles {
    if (_indexTitles == indexTitles) return;
    _indexTitles = indexTitles;
    [self.indexLabels makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self buildIndexLabels];
}

- (NSString *)currentIndexTitle {
    return self.indexTitles[self.currentIndex];
}

#pragma mark - Subviews

- (void)buildIndexLabels {
    NSMutableArray *workingLabels = [NSMutableArray arrayWithCapacity:self.indexTitles.count];
    NSUInteger tag = 0;
    for (NSString *indexTitle in self.indexTitles) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.text = indexTitle;
        label.tag = tag;
        tag = tag + 1;
        label.font = [UIFont boldSystemFontOfSize:12];
        label.backgroundColor = _backgroundColor;
        label.textColor = _labelColor;
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        [workingLabels addObject:label];
    }
    
    self.indexLabels = [NSArray arrayWithArray:workingLabels];
}

- (void)setNewIndexForPoint:(CGPoint)point {
    for (UILabel *view in self.indexLabels) {
        if (CGRectContainsPoint(view.frame, point)) {
            NSUInteger newIndex = view.tag;
            if (newIndex != _currentIndex) {
                _currentIndex = newIndex;
                [self sendActionsForControlEvents:UIControlEventValueChanged];
            }
        }
    }
}

- (void)setBackgroundVisibility:(BOOL)flag {
    CGFloat alpha = flag ? 0.25 : 0;
    self.touchStatusView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:alpha];
}

#pragma mark - Gestures

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    [self setNewIndexForPoint:touchPoint];
    [self setBackgroundVisibility:YES];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self setBackgroundVisibility:NO];
}

- (void)handleTap:(UITapGestureRecognizer *)recognizer {
    [self setBackgroundVisibility:!(recognizer.state == UIGestureRecognizerStateEnded)];
    [self setNewIndexForPoint:[recognizer locationInView:self]];
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    [self setBackgroundVisibility:!(recognizer.state == UIGestureRecognizerStateEnded)];
    CGPoint translation = [recognizer locationInView:self];
    [self setNewIndexForPoint:translation];
}

@end
