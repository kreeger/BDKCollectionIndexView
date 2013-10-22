//
//  BDKCell.m
//  BDKCollectionIndexView
//
//  Created by Ben Kreeger on 10/22/13.
//  Copyright (c) 2013 Ben Kreeger. All rights reserved.
//

#import "BDKCell.h"

NSString * const BDKCellID = @"BDKCell";

@interface BDKCell ()

- (void)setup;

@end

@implementation BDKCell

@synthesize label = _label;

- (instancetype)init {
    self = [super init];
    if (!self) return nil;
    [self setup];
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (!self) return nil;
    [self setup];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;
    [self setup];
    return self;
}

- (void)setup {
    [self.contentView addSubview:self.label];
    self.label.frame = self.contentView.bounds;
    self.layer.borderColor = [[UIColor blackColor] CGColor];
    self.layer.borderWidth = 1;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.label.text = nil;
}

#pragma mark - Properties

- (UILabel *)label {
    if (_label) return _label;
    _label = [UILabel new];
    _label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _label.font = [UIFont boldSystemFontOfSize:64];
    _label.textAlignment = NSTextAlignmentCenter;
    return _label;
}

@end
