//
//  BDKViewController.m
//  BDKCollectionIndexView
//
//  Created by Ben Kreeger on 10/22/13.
//  Contributors: Adrian Maurer
//  Copyright (c) 2013 Ben Kreeger. All rights reserved.
//

#import "BDKViewController.h"

#import "BDKCollectionIndexView.h"

#import "BDKCell.h"

@interface BDKViewController () <UICollectionViewDataSource>

@property (strong, nonatomic) UICollectionView *collectionView;

@property (strong, nonatomic) UICollectionViewFlowLayout *flowLayout;

@property (strong, nonatomic) BDKCollectionIndexView *indexView;

@property (strong, nonatomic) NSArray *sections;

- (void)indexViewValueChanged:(BDKCollectionIndexView *)sender;

@end

@implementation BDKViewController

#pragma mark - Lifecycle

- (void)loadView {
    self.view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.indexView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Create data
    NSMutableArray *sections = [NSMutableArray new];
    for (NSInteger count = 0; count <= 30; count++) {
        [sections addObject:[NSString stringWithFormat:@"%ld", (long)count]];
    }
    
    self.sections = sections.copy;
    self.indexView.indexTitles = self.sections;
}

- (void)viewWillLayoutSubviews {
    const CGFloat indexWidth = 28.0f;
    NSDictionary *views = @{@"iv" : self.indexView};
    
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.indexView
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.topLayoutGuide
                                                          attribute:NSLayoutAttributeBottom
                                                         multiplier:1.0
                                                           constant:0.0]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[iv]-0-|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[iv(w)]-0-|"
                                                                      options:0
                                                                      metrics:@{@"w" : @(indexWidth)}                                                    views:views]];
}

#pragma mark - Properties

- (UICollectionView *)collectionView {
    if (_collectionView) return _collectionView;
    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:self.flowLayout];
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor whiteColor];
    _collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [_collectionView registerClass:[BDKCell class] forCellWithReuseIdentifier:BDKCellID];
    return _collectionView;
}

- (UICollectionViewFlowLayout *)flowLayout {
    if (_flowLayout) return _flowLayout;
    _flowLayout = [UICollectionViewFlowLayout new];
    _flowLayout.itemSize = CGSizeMake(320, 320);
    return _flowLayout;
}

- (BDKCollectionIndexView *)indexView {
    if (_indexView) return _indexView;
    _indexView = [BDKCollectionIndexView indexViewWithFrame:CGRectZero indexTitles:@[]];
    _indexView.translatesAutoresizingMaskIntoConstraints = NO;   // auto layout
    [_indexView addTarget:self action:@selector(indexViewValueChanged:) forControlEvents:UIControlEventValueChanged];
    return _indexView;
}

#pragma mark - Actions

- (void)indexViewValueChanged:(BDKCollectionIndexView *)sender {
    NSIndexPath *path = [NSIndexPath indexPathForItem:0 inSection:sender.currentIndex];
    if (![self collectionView:self.collectionView cellForItemAtIndexPath:path])
        return;

    [self.collectionView scrollToItemAtIndexPath:path atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
    CGFloat yOffset = self.collectionView.contentOffset.y;

    self.collectionView.contentOffset = CGPointMake(self.collectionView.contentOffset.x, yOffset);
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.sections count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BDKCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:BDKCellID forIndexPath:indexPath];
    cell.label.text = self.sections[indexPath.section];
    return cell;
}

@end
