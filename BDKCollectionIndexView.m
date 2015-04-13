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

@synthesize
	delegate = _delegate,
	currentIndex = _currentIndex,
	touchStatusBackgroundColor = _touchStatusBackgroundColor,
    touchStatusViewAlpha = _touchStatusViewAlpha,
    font = _font,
    direction = _direction;

+ (instancetype)indexViewWithFrame:(CGRect)frame indexTitles:(NSArray *)indexTitles {
    return [[self alloc] initWithFrame:frame indexTitles:indexTitles];
}

- (instancetype)initWithFrame:(CGRect)frame indexTitles:(NSArray *)indexTitles {
    self = [super initWithFrame:frame];
    if (!self) return nil;

	if (CGRectGetWidth(frame) > CGRectGetHeight(frame)) {
        _direction = BDKCollectionIndexViewDirectionHorizontal;
	} else {
		_direction = BDKCollectionIndexViewDirectionVertical;
	}

    _currentIndex = 0;
	_touchStatusViewAlpha = 0.25;
	_touchStatusBackgroundColor = [UIColor blackColor];
	self.tintColor = [UIColor blackColor];
    self.backgroundColor = [UIColor clearColor];
	
    SEL handleGestureSelector = @selector(handleGesture:);

    _panner = [[UIPanGestureRecognizer alloc] initWithTarget:self action:handleGestureSelector];
    _panner.delegate = self;
    [self addGestureRecognizer:_panner];
    
    _tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:handleGestureSelector];
    [self addGestureRecognizer:_tapper];
    
    _longPresser = [[UILongPressGestureRecognizer alloc] initWithTarget:self
																 action:handleGestureSelector];
    _longPresser.delegate = self;
    _longPresser.minimumPressDuration = 0.01f;
    [self addGestureRecognizer:_longPresser];

    [self addSubview:self.touchStatusView];
    
    self.indexTitles = indexTitles;
    
    self.isAccessibilityElement = YES;
    self.accessibilityTraits = UIAccessibilityTraitAdjustable;
    self.accessibilityLabel = NSLocalizedString(@"table index", @"title given to the section index control");

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
            
            while (totalLabelsSize > self.bounds.size.width) {
                labelSize = CGSizeMake(labelSize.width - 1, labelSize.height);
                totalLabelsSize = self.indexLabels.count * labelSize.width;
            }
            
            positionOffset = self.bounds.size.width / 2 - totalLabelsSize / 2 - 2;
            break;
        case BDKCollectionIndexViewDirectionVertical:
            dimension = CGRectGetWidth(self.frame);
            if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
                labelSize = CGSizeMake(dimension, dimension - 6);
            } else {
                labelSize = CGSizeMake(dimension, dimension);
            }
            totalLabelsSize = self.indexLabels.count * labelSize.height;
            
            while (totalLabelsSize > self.bounds.size.height) {
                labelSize = CGSizeMake(labelSize.width, labelSize.height - 1);
                totalLabelsSize = self.indexLabels.count * labelSize.height;
            }
            
            positionOffset = self.bounds.size.height / 2 - totalLabelsSize / 2 - 1;
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

- (void)tintColorDidChange {
	if (self.tintAdjustmentMode == UIViewTintAdjustmentModeDimmed) {
		[self.indexLabels makeObjectsPerformSelector:@selector(setTextColor:)
										  withObject:[UIColor lightGrayColor]];
	} else {
		[self.indexLabels makeObjectsPerformSelector:@selector(setTextColor:)
										  withObject:self.tintColor];
    }
}

- (void)accessibilityIncrement {
    NSInteger currentIndex = self.currentIndex;
    NSInteger newIndex = currentIndex - 1;
    if (newIndex >= 0) {
        _currentIndex = newIndex;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
        [self announceNewSection];
    }
}

- (void)accessibilityDecrement {
    NSInteger currentIndex = self.currentIndex;
    NSInteger newIndex = currentIndex + 1;
    if (newIndex < self.indexLabels.count) {
        _currentIndex = newIndex;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
        [self announceNewSection];
    }
}

- (void)announceNewSection {
    NSString *title = self.indexTitles[self.currentIndex];
    NSString *selectedString = NSLocalizedString(@"selected", @"word that indicates an item is selected");
    NSString *titleToAnnounce = title.accessibilityLabel;
    if (!titleToAnnounce) {
        titleToAnnounce = title;
    }
    NSString *annoucement = [NSString stringWithFormat:@"%@ ,%@", titleToAnnounce, selectedString];
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, annoucement);
}

#pragma mark - Properties

- (UIView *)touchStatusView {
    if (_touchStatusView) return _touchStatusView;
    _touchStatusView = [[UIView alloc] initWithFrame:CGRectInset(self.bounds, 2, 2)];
    _touchStatusView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
	
    CGFloat dimension;
    switch (_direction) {
        case BDKCollectionIndexViewDirectionHorizontal:
            dimension = CGRectGetHeight(self.bounds);
        case BDKCollectionIndexViewDirectionVertical:
            dimension = CGRectGetWidth(self.bounds);
    }
	
    _touchStatusView.layer.cornerRadius = dimension / 2;
    _touchStatusView.layer.masksToBounds = YES;
    return _touchStatusView;
}

- (void)setIndexTitles:(NSArray *)indexTitles {
    if (_indexTitles == indexTitles) return;
    _indexTitles = indexTitles;
	[self reloadData];
}

- (void)reloadData {
    [self.indexLabels makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self buildIndexLabels];
}

- (NSString *)currentIndexTitle {
    return self.indexTitles[self.currentIndex];
}

- (UIFont *)font {
    return _font ? _font : [UIFont boldSystemFontOfSize:12.0f];
}

- (void)setFont:(UIFont *)font {
    _font = font;
    for (UILabel *label in self.indexLabels) {
        label.font = font;
    }
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
        label.font = self.font;
        label.backgroundColor = self.backgroundColor;
        label.textColor = self.tintColor;
        label.textAlignment = NSTextAlignmentCenter;
        label.isAccessibilityElement = NO;
        [self addSubview:label];
        [workingLabels addObject:label];
    }
    
    self.indexLabels = [NSArray arrayWithArray:workingLabels];
}

- (void)setNewIndexForPoint:(CGPoint)point {
    NSInteger newIndex = -1;
    
    for (UILabel *view in self.indexLabels) {
		if (!CGRectContainsPoint(view.frame, point)) { continue; }
		newIndex = view.tag;
		break;
    }
    
    if (newIndex == -1) {
        UILabel *topLabel = self.indexLabels[0];
        UILabel *bottomLabel = self.indexLabels[self.indexLabels.count - 1];
        
        if (point.y < topLabel.frame.origin.y) {
            newIndex = topLabel.tag;
        } else if (point.y > bottomLabel.frame.origin.y) {
            newIndex = bottomLabel.tag;
        }
    }
    
    if (newIndex != -1 && newIndex != _currentIndex) {
        _currentIndex = newIndex;
        [self sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

- (void)setBackgroundVisibility:(BOOL)flag {
    CGFloat alpha = flag ? self.touchStatusViewAlpha : 0;
    self.touchStatusView.backgroundColor = [self.touchStatusBackgroundColor colorWithAlphaComponent:alpha];
}

#pragma mark - Gestures

- (void)handleGesture:(UIGestureRecognizer *)recognizer {
    [self setBackgroundVisibility:!(recognizer.state == UIGestureRecognizerStateEnded)];
    [self setNewIndexForPoint:[recognizer locationInView:self]];
	
	if (recognizer != _longPresser) { return; }
	if (recognizer.state == UIGestureRecognizerStateEnded) {
		if ([self.delegate respondsToSelector:@selector(collectionIndexView:liftedFingerFromIndex:)]) {
			[self.delegate collectionIndexView:self liftedFingerFromIndex:self.currentIndex];
		}
	} else {
		if ([self.delegate respondsToSelector:@selector(collectionIndexView:isPressedOnIndex:indexTitle:)]) {
			
			[self.delegate collectionIndexView:self isPressedOnIndex:self.currentIndex indexTitle:self.currentIndexTitle];
		}
	}
	
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
	shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return gestureRecognizer != _longPresser;
}

@end
