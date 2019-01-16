//
//  YBImageBrowserBottomBar.m
//  newhwmc
//
//  Created by sunbinhua on 2018/12/12.
//  Copyright © 2018 paidian. All rights reserved.
//

#import "YBImageBrowserBottomBar.h"
#import "YBIBUtilities.h"


@implementation YBImageBrowserBottomBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpUI];
    }
    return self;
}

- (void)setUpUI {
    
    self.miniBtn.frame = CGRectMake(25*kYBDesignScaleXForIP6, 0, 78*kYBDesignScaleXForIP6, 29*kYBDesignScaleXForIP6);
    self.saveBtn.frame = CGRectMake(149*kYBDesignScaleXForIP6, 0, 78*kYBDesignScaleXForIP6, 29*kYBDesignScaleXForIP6);
    self.lookBtn.frame = CGRectMake(272*kYBDesignScaleXForIP6, 0, 78*kYBDesignScaleXForIP6, 29*kYBDesignScaleXForIP6);
    
    [self addSubview:self.miniBtn];
    [self addSubview:self.saveBtn];
    [self addSubview:self.lookBtn];
    
    self.downLoadButton.frame = CGRectMake(55.f * kYBDesignScaleXForIP6, 0, 78*kYBDesignScaleXForIP6, 29*kYBDesignScaleXForIP6);
    self.detailButton.frame = CGRectMake(CGRectGetWidth([UIScreen mainScreen].bounds) - (55.f + 78) * kYBDesignScaleXForIP6, 0, 78*kYBDesignScaleXForIP6, 29*kYBDesignScaleXForIP6);
    
    [self addSubview:self.downLoadButton];
    [self addSubview:self.detailButton];
    
}


#pragma mark - Getter

- (UIButton *)miniBtn{
    if (!_miniBtn) {
        _miniBtn = [[UIButton alloc] init];
        _miniBtn.tag = 0;
        _miniBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12*kYBDesignScaleXForIP6];
        [_miniBtn setTitle:@"小程序码" forState:UIControlStateNormal];
        [_miniBtn setTitleColor:YBRGB(255, 255, 255) forState:UIControlStateNormal];
        _miniBtn.backgroundColor = YBRGBA(0, 0, 0, 0.3);
        _miniBtn.layer.borderColor = YBRGBA(102, 102, 102,0.3).CGColor;
        _miniBtn.layer.borderWidth = 0.5;
        _miniBtn.layer.masksToBounds = YES;
        _miniBtn.layer.cornerRadius = 4*kYBDesignScaleXForIP6;
    }
    return _miniBtn;
}

- (UIButton *)saveBtn{
    if (!_saveBtn) {
        _saveBtn = [[UIButton alloc] init];
        _saveBtn.tag = 1;
        _saveBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12*kYBDesignScaleXForIP6];
        [_saveBtn setTitle:@"保存图片" forState:UIControlStateNormal];
        [_saveBtn setTitleColor:YBRGB(255, 255, 255) forState:UIControlStateNormal];
        _saveBtn.backgroundColor = YBRGBA(0, 0, 0, 0.3);
        _saveBtn.layer.borderColor = YBRGBA(102, 102, 102,0.3).CGColor;
        _saveBtn.layer.borderWidth = 0.5;
        _saveBtn.layer.masksToBounds = YES;
        _saveBtn.layer.cornerRadius = 4*kYBDesignScaleXForIP6;
    }
    return _saveBtn;
}

- (UIButton *)lookBtn{
    if (!_lookBtn) {
        _lookBtn = [[UIButton alloc] init];
        _lookBtn.tag = 2;
        _lookBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12*kYBDesignScaleXForIP6];
        [_lookBtn setTitle:@"查看详情" forState:UIControlStateNormal];
        [_lookBtn setTitleColor:YBRGB(255, 255, 255) forState:UIControlStateNormal];
        _lookBtn.backgroundColor = YBRGBA(0, 0, 0, 0.3);
        _lookBtn.layer.borderColor = YBRGBA(102, 102, 102,0.3).CGColor;
        _lookBtn.layer.borderWidth = 0.5;
        _lookBtn.layer.masksToBounds = YES;
        _lookBtn.layer.cornerRadius = 4*kYBDesignScaleXForIP6;
    }
    return _lookBtn;
}


- (UIButton *)downLoadButton
{
    if (!_downLoadButton) {
        _downLoadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_downLoadButton setTitle:@"下载视频" forState:UIControlStateNormal];
        [_downLoadButton setTitle:@"下载视频" forState:UIControlStateHighlighted];
        _downLoadButton.layer.cornerRadius = 4.f;
        [_downLoadButton setBackgroundColor:YBRGBA(0, 0, 0, 0.3)];
        _downLoadButton.layer.cornerRadius = 4.f;
        _downLoadButton.layer.borderColor = YBRGBA(102, 102, 102,0.3).CGColor;
        _downLoadButton.layer.borderWidth = 0.5;
        _downLoadButton.layer.masksToBounds = YES;
        _downLoadButton.layer.cornerRadius = 4 * kYBDesignScaleXForIP6;
        [_downLoadButton setTitleColor:YBRGB(255, 255, 255) forState:UIControlStateNormal];
        [_downLoadButton setTitleColor:YBRGB(255, 255, 255) forState:UIControlStateHighlighted];
        _downLoadButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12.f * kYBDesignScaleXForIP6];
    }
    return _downLoadButton;
}

- (UIButton *)detailButton
{
    if (!_detailButton) {
        _detailButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _detailButton.layer.cornerRadius = 4.f;
        [_detailButton setBackgroundColor:YBRGBA(0, 0, 0, 0.3)];
        _detailButton.layer.borderColor = YBRGBA(102, 102, 102,0.3).CGColor;
        _detailButton.layer.borderWidth = 0.5;
        _detailButton.layer.masksToBounds = YES;
        _detailButton.layer.cornerRadius = 4*kYBDesignScaleXForIP6;
        [_detailButton setTitleColor:YBRGB(255, 255, 255) forState:UIControlStateNormal];
        [_detailButton setTitleColor:YBRGB(255, 255, 255) forState:UIControlStateHighlighted];
        [_detailButton setTitle:@"查看详情" forState:UIControlStateNormal];
        [_detailButton setTitle:@"查看详情" forState:UIControlStateHighlighted];
        _detailButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12.f * kYBDesignScaleXForIP6];
    }
    return _detailButton;
}
@end
