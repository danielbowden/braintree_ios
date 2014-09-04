#import "BTHorizontalButtonStackCollectionViewFlowLayout.h"
#import "BTHorizontalButtonStackSeparatorLineView.h"


NSString *BTHorizontalButtonStackCollectionViewFlowLayoutLineSeparatorDecoratorViewKind = @"BTHorizontalButtonStackCollectionViewFlowLayoutLineSeparatorDecoratorViewKind";

@interface BTHorizontalButtonStackCollectionViewFlowLayout ()
@end

@implementation BTHorizontalButtonStackCollectionViewFlowLayout

- (id)init {
    self = [super init];
    if (self) {
        [self registerClass:[BTHorizontalButtonStackSeparatorLineView class] forDecorationViewOfKind:BTHorizontalButtonStackCollectionViewFlowLayoutLineSeparatorDecoratorViewKind];
    }
    return self;
}

- (void)prepareLayout {
    [super prepareLayout];

    NSParameterAssert(self.collectionView.numberOfSections == 1);
    NSInteger numberOfItems = [self.collectionView numberOfItemsInSection:0];
    CGFloat totalWidth = self.collectionView.frame.size.width;
    NSParameterAssert(numberOfItems > 0);
    self.itemSize = CGSizeMake(totalWidth/numberOfItems, self.collectionView.frame.size.height);
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray *layoutAttributes = [[super layoutAttributesForElementsInRect:rect] mutableCopy];

    for (UICollectionViewLayoutAttributes *attributes in [layoutAttributes subarrayWithRange:NSMakeRange(0, [layoutAttributes count] - 1)]) {
        UICollectionViewLayoutAttributes *separatorAttributes = [UICollectionViewLayoutAttributes layoutAttributesForDecorationViewOfKind:BTHorizontalButtonStackCollectionViewFlowLayoutLineSeparatorDecoratorViewKind
                                                                                                                            withIndexPath:attributes.indexPath];
        separatorAttributes.frame = CGRectMake(attributes.frame.origin.x + attributes.frame.size.width, attributes.frame.origin.y, 1/2.0f, attributes.frame.size.height);
        [layoutAttributes addObject:separatorAttributes];
    }

    return layoutAttributes;
}

@end
