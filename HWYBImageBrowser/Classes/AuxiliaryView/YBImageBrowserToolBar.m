//
//  YBImageBrowserToolBar.m
//  YBImageBrowserDemo
//
//  Created by 杨波 on 2018/9/12.
//  Copyright © 2018年 杨波. All rights reserved.
//

#import "YBImageBrowserToolBar.h"
#import "YBIBFileManager.h"
#import "YBImageBrowserTipView.h"
#import "YBIBCopywriter.h"
#import "YBIBUtilities.h"
#import "YBImageBrowseCellData.h"
#import "YBVideoBrowseCellData.h"


static CGFloat kToolBarDefaultsHeight = 50.0;

@interface YBImageBrowserToolBar() {
    YBImageBrowserToolBarOperationBlock _operation;
    id<YBImageBrowserCellDataProtocol> _data;
}
@property (nonatomic, strong) UILabel *indexLabel;

@property (nonatomic, strong) CAGradientLayer *gradient;
@end

@implementation YBImageBrowserToolBar

@synthesize yb_browserShowSheetViewBlock = _yb_browserShowSheetViewBlock;

#pragma mark - life cycle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.layer addSublayer:self.gradient];
        [self addSubview:self.indexLabel];

    }
    return self;
}

#pragma mark - public

- (void)setOperationButtonImage:(UIImage *)image title:(NSString *)title operation:(YBImageBrowserToolBarOperationBlock)operation {

    self->_operation = operation;
    self->_operationType = YBImageBrowserToolBarOperationTypeCustom;
}

- (void)hideOperationButton {
    [self setOperationButtonImage:nil title:nil operation:nil];
}

#pragma mark - <YBImageBrowserToolBarProtocol>

- (void)yb_browserUpdateLayoutWithDirection:(YBImageBrowserLayoutDirection)layoutDirection containerSize:(CGSize)containerSize {
    CGFloat height = kToolBarDefaultsHeight, width = containerSize.width, hExtra = 0;
    if (containerSize.height > containerSize.width && YBIB_IS_IPHONEX) height += YBIB_HEIGHT_STATUSBAR;
    if (containerSize.height < containerSize.width && YBIB_IS_IPHONEX) hExtra += YBIB_HEIGHT_EXTRABOTTOM;
    
    self.frame = CGRectMake(0, 0, width, height);
    self.gradient.frame = self.bounds;
}

- (void)yb_browserPageIndexChanged:(NSUInteger)pageIndex totalPage:(NSUInteger)totalPage data:(id<YBImageBrowserCellDataProtocol>)data {
    
    self->_data = data;
    
    NSUInteger sectionTotal = 0;
    NSUInteger sectionIndex = 0;
    
    if ([data isKindOfClass:[YBImageBrowseCellData class]]) {
        YBImageBrowseCellData *imageData = data;
        sectionTotal = imageData.sectionCount;
        sectionIndex = imageData.sectionIndex;
    }else{
        sectionTotal = 1;
    }
    
    if (sectionTotal <= 1) {
        self.indexLabel.hidden = YES;
    } else {
        self.indexLabel.hidden  = NO;
        self.indexLabel.text = [NSString stringWithFormat:@"%ld/%ld", sectionIndex + 1, sectionTotal];
    }
}

#pragma mark - event

- (void)clickOperationButton:(UIButton *)button {
    switch (self->_operationType) {
        case YBImageBrowserToolBarOperationTypeSave: {
            if ([self->_data respondsToSelector:@selector(yb_browserSaveToPhotoAlbum)]) {
                [self->_data yb_browserSaveToPhotoAlbum];
            } else {
                [YBIBGetNormalWindow() yb_showForkTipView:[YBIBCopywriter shareCopywriter].unableToSave];
            }
        }
            break;
        case YBImageBrowserToolBarOperationTypeMore: {
            self.yb_browserShowSheetViewBlock(self->_data);
        }
            break;
        case YBImageBrowserToolBarOperationTypeCustom: {
            if (self->_operation) {
                self->_operation(self->_data);
            }
        }
            break;
    }
}

#pragma mark - getter

- (UILabel *)indexLabel {
    if (!_indexLabel) {
        _indexLabel = [UILabel new];
        _indexLabel.textColor = [UIColor whiteColor];
        _indexLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15*kYBDesignScaleXForIP6];
        _indexLabel.textAlignment = NSTextAlignmentCenter;
        _indexLabel.backgroundColor = YBRGBA(0, 0, 0, 0.3);
        _indexLabel.layer.borderColor = YBRGB(102, 102, 102).CGColor;
        _indexLabel.layer.borderWidth = 0.5;
        _indexLabel.layer.masksToBounds = YES;
        _indexLabel.layer.cornerRadius = 4*kYBDesignScaleXForIP6;
        _indexLabel.frame = CGRectMake(161*kYBDesignScaleXForIP6, ([YBIBUtilities isIphoneX] ? 24 : 0)+26*kYBDesignScaleXForIP6, 54*kYBDesignScaleXForIP6, 29*kYBDesignScaleXForIP6);
    }
    return _indexLabel;
}

- (CAGradientLayer *)gradient {
    if (!_gradient) {
        _gradient = [CAGradientLayer layer];
        _gradient.startPoint = CGPointMake(0.5, 0);
        _gradient.endPoint = CGPointMake(0.5, 1);
        _gradient.colors = @[(id)[UIColor colorWithRed:0  green:0  blue:0 alpha:0.3].CGColor, (id)[UIColor colorWithRed:0  green:0  blue:0 alpha:0].CGColor];
    }
    return _gradient;
}

@end
