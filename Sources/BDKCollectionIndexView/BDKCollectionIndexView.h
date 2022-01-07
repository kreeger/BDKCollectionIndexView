#import <UIKit/UIKit.h>

@protocol BDKCollectionIndexViewDelegate;

/**
 The direction in which the control is oriented. Assists in determining layout values.
 */
typedef NS_ENUM(NSInteger, BDKCollectionIndexViewDirection) {
    BDKCollectionIndexViewDirectionVertical = 0,
    BDKCollectionIndexViewDirectionHorizontal
};

/**
 An index-title-scrubber-bar, for use with a UICollectionView (or even a PSTCollectionView). Gives a collection
 view the index title bar that a UITableView gets for (almost) free. A huge thank you to
 @Yang from http://stackoverflow.com/a/14443540/194869, which saved my bacon here.
 */
@interface BDKCollectionIndexView : UIControl

@property (weak, nonatomic) id<BDKCollectionIndexViewDelegate> delegate;

/**
 A collection of string values that represent section index titles.
 */
@property (strong, nonatomic) NSArray *indexTitles;

/**
 Indicates the position of the last-selected index title. Should map directly to a table view / collection section.
 */
@property (readonly, nonatomic) NSUInteger currentIndex;

/**
 The direction in which the control is oriented; this is automatically set based on the frame given.
 */
@property (readonly) BDKCollectionIndexViewDirection direction;

/**
 The index title at the index of `currentIndex`.
 */
@property (readonly) NSString *currentIndexTitle;

/**
 Preferred font of the index labels. By default, bold system font of size 12.
 */
@property (strong, nonatomic) UIFont *font;

/**
 The background color of the "touch status view" that appears when the view is touched.
 */
@property (strong, nonatomic) UIColor *touchStatusBackgroundColor;

/**
 The amount of alpha applied to the "touch status view" that appears when the view is touched.
 */
@property (nonatomic) CGFloat touchStatusViewAlpha;
//@property (strong, nonatomic) UIColor *backgroundColor;


/**
 A class message to initialize and return an index view control, given a frame and a list of index titles.
 
 @param frame the frame to use when initializing the control.
 @param indexTitles the index titles to be rendered out in the control.
 @return an instance of the class.
 */
+ (instancetype)indexViewWithFrame:(CGRect)frame indexTitles:(NSArray *)indexTitles;

/**
 A message to initialize and return an index view control, given a frame and a list of index titles.
 
 @param frame the frame to use when initializing the control.
 @param indexTitles the index titles to be rendered out in the control.
 @return an instance of the class.
 */
- (instancetype)initWithFrame:(CGRect)frame indexTitles:(NSArray *)indexTitles;

/**
 An instance method to force the index view control to reload the data. Invoked by -setIndexTitles:.
 */
- (void)reloadData;

@end

@protocol BDKCollectionIndexViewDelegate <NSObject>

@optional

- (void)collectionIndexView:(BDKCollectionIndexView *)collectionIndexView isPressedOnIndex:(NSUInteger)pressedIndex indexTitle:(NSString *)indexTitle;
- (void)collectionIndexView:(BDKCollectionIndexView *)collectionIndexView liftedFingerFromIndex:(NSUInteger)pressedIndex;

@end
