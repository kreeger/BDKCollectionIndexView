#import "BDKCollectionIndexView.h"

#import <QuartzCore/QuartzCore.h>

@interface BDKCollectionIndexView () <UIGestureRecognizerDelegate>

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
 A gesture recognizer that handles long presses.
 */
@property (strong, nonatomic) UILongPressGestureRecognizer *longPresser;

@property (readonly) CGFloat theDimension;

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

@synthesize currentIndex = _currentIndex, direction = _direction, theDimension = _theDimension, labelColor = _labelColor, backgroundColor = _backgroundColor;

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
    _endPadding = 2;
    _labelColor = [UIColor blackColor];
    _backgroundColor = [UIColor clearColor];
    
    SEL handleGestureSelector = @selector(handleGesture:);

    _panner = [[UIPanGestureRecognizer alloc] initWithTarget:self action:handleGestureSelector];
    _panner.delegate = self;
    [self addGestureRecognizer:_panner];
    
    _tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:handleGestureSelector];
    [self addGestureRecognizer:_tapper];
    
    _longPresser = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:handleGestureSelector];
    _longPresser.delegate = self;
    _longPresser.minimumPressDuration = 0.01f;
    [self addGestureRecognizer:_longPresser];

    [self addSubview:self.touchStatusView];

    self.indexTitles = indexTitles;

    return self;
}

- (void)layoutSubviews {

    CGFloat maxLength = 0.0;
    switch (_direction) {
        case BDKCollectionIndexViewDirectionHorizontal:
            _theDimension = CGRectGetHeight(self.frame);
            maxLength = CGRectGetWidth(self.frame) - (self.endPadding * 2);
            break;
        case BDKCollectionIndexViewDirectionVertical:
            _theDimension = CGRectGetWidth(self.frame);
            maxLength = CGRectGetHeight(self.frame) - (self.endPadding * 2);
            break;
    }

    self.touchStatusView.frame = CGRectInset(self.bounds, 2, 2);
    self.touchStatusView.layer.cornerRadius = floorf(self.theDimension / 2.75);

    CGFloat cumulativeLength = self.endPadding;
    CGSize labelSize = CGSizeMake(self.theDimension, self.theDimension);

    CGFloat otherDimension = floorf(maxLength / self.indexLabels.count);
    for (UILabel *label in self.indexLabels) {
        switch (self.direction) {
            case BDKCollectionIndexViewDirectionHorizontal:
                labelSize.width = otherDimension;
                label.frame = (CGRect){ { cumulativeLength, 0 }, labelSize };
                cumulativeLength += CGRectGetWidth(label.frame);
                break;
            case BDKCollectionIndexViewDirectionVertical:
                labelSize.height = otherDimension;
                label.frame = (CGRect){ { 0, cumulativeLength }, labelSize };
                cumulativeLength += CGRectGetHeight(label.frame);
                break;
        }
    }
}

- (void)tintColorDidChange {
    if (self.tintAdjustmentMode == UIViewTintAdjustmentModeDimmed) {
        for (UILabel *label in self.subviews) {
            label.textColor = [UIColor lightGrayColor];
        }
    } else {
        for (UILabel *label in self.subviews) {
            label.textColor = self.labelColor;
        }
    }
}

#pragma mark - Properties

- (UIView *)touchStatusView {
    if (_touchStatusView) return _touchStatusView;
    _touchStatusView = [[UIView alloc] initWithFrame:CGRectInset(self.bounds, 2, 2)];
    _touchStatusView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    _touchStatusView.layer.cornerRadius = self.theDimension / 2;
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

- (void)setEndPadding:(CGFloat)endPadding {
    if (_endPadding == endPadding) return;
    _endPadding = endPadding;

    [self.indexTitles makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self buildIndexLabels];
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

- (void)handleGesture:(UIGestureRecognizer *)recognizer {
    [self setBackgroundVisibility:!(recognizer.state == UIGestureRecognizerStateEnded)];
    [self setNewIndexForPoint:[recognizer locationInView:self]];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return gestureRecognizer != _longPresser;
}

@end
