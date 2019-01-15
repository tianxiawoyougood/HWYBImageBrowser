//
//  YBImageBrowserBottomBar.m
//  newhwmc
//
//  Created by sunbinhua on 2018/12/12.
//  Copyright © 2018 paidian. All rights reserved.
//

#import "YBImageBrowserBottomBar.h"
#import "NSArray+Sudoku.h"
#import "HWDisMaterialModel.h"
#import "HWMineAgentCenter.h"





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
    
    self.miniBtn.frame = CGRectMake(25*kDesignScaleXForIP6, 0, 78*kDesignScaleXForIP6, 29*kDesignScaleXForIP6);
    self.saveBtn.frame = CGRectMake(149*kDesignScaleXForIP6, 0, 78*kDesignScaleXForIP6, 29*kDesignScaleXForIP6);
    self.lookBtn.frame = CGRectMake(272*kDesignScaleXForIP6, 0, 78*kDesignScaleXForIP6, 29*kDesignScaleXForIP6);
    
    [self addSubview:self.miniBtn];
    [self addSubview:self.saveBtn];
    [self addSubview:self.lookBtn];
    
    self.downLoadButton.frame = CGRectMake(55.f * kDesignScaleXForIP6, 0, 78*kDesignScaleXForIP6, 29*kDesignScaleXForIP6);
    self.detailButton.frame = CGRectMake(kScreenWidth - (55.f + 78) * kDesignScaleXForIP6, 0, 78*kDesignScaleXForIP6, 29*kDesignScaleXForIP6);
    
    [self addSubview:self.downLoadButton];
    [self addSubview:self.detailButton];
    
}

- (void)setMateriaModel:(HWDisMaterialModel *)materiaModel{
    
    _materiaModel = materiaModel;
    [self changeTo:materiaModel.type];
    
    if ([materiaModel.type isEqualToNumber:@1]) {
        
        // 更新视图数据
        self.miniBtn.hidden = (materiaModel.goods_info == nil || [HWMineAgentCenter getUserLevelWithLevel:[materiaModel.user_level integerValue] isVip:materiaModel.is_vip] == HWUserLevelStatusCommon );
        self.lookBtn.hidden = (materiaModel.isMaterial || materiaModel.goods_info == nil);
        if (materiaModel.goods_info == nil) {
            [self.miniBtn setLeft:55.f * kDesignScaleXForIP6];
            [self.saveBtn setCenterX:kScreenWidth/2.0];
        }else if (materiaModel.user_level.integerValue < 30){
            if (self.lookBtn.hidden) {
                [self.saveBtn setCenterX:kScreenWidth/2.0];
            }
            else{
                [self.saveBtn setLeft:55.f * kDesignScaleXForIP6];
                [self.lookBtn setRight:(kScreenWidth - 55.f * kDesignScaleXForIP6)];
            }
        }else{
            if (self.miniBtn.hidden) {
                if (self.lookBtn.hidden) {
                    [self.saveBtn setLeft:149.f * kDesignScaleXForIP6];
                }
                else
                {
                    [self.saveBtn setLeft:55.f * kDesignScaleXForIP6];
                    [self.lookBtn setRight:(kScreenWidth - 55.f * kDesignScaleXForIP6)];
                }
            }
            else{
                if (self.lookBtn.hidden) {
                    [self.miniBtn setLeft:55.f * kDesignScaleXForIP6];
                    [self.saveBtn setRight:(kScreenWidth - 55.f * kDesignScaleXForIP6)];
                }
                else
                {
                    [self.miniBtn setLeft:25.f * kDesignScaleXForIP6];
                    [self.saveBtn setLeft:149.f * kDesignScaleXForIP6];
                    [self.lookBtn setRight:(kScreenWidth - 25.f * kDesignScaleXForIP6)];
                }
            }
        }
    }else {
        
        BOOL isShowDetail = materiaModel.goods_info != nil;
        self.detailButton.hidden = !isShowDetail;
        
        if (isShowDetail) {
            [self.downLoadButton setLeft:55.f * kDesignScaleXForIP6];
            
        }else{
            [self.downLoadButton setCenterX:kScreenWidth/2.0];
        }
        
    }
}

- (void)changeTo:(NSNumber *)type {
    
    if ([type isEqualToNumber:@1]) {
        
        [self showImageToolBar:YES];
        [self showVideoToolBar:NO checkGoods_info:NO];
        
    }else {
        
        [self showImageToolBar:NO];
        [self showVideoToolBar:YES checkGoods_info:NO];
    }
}

- (void)showImageToolBar:(BOOL)isShow {

    self.miniBtn.hidden = !isShow;
    self.saveBtn.hidden = !isShow;
    self.lookBtn.hidden = !isShow;
}

- (void)showVideoToolBar:(BOOL)isShow  checkGoods_info:(BOOL)isCheck {
    
    self.downLoadButton.hidden = !isShow;
    self.detailButton.hidden = !isShow;
    
    if (isCheck) {
        BOOL isShowDetail = self.materiaModel.goods_info != nil;
        self.detailButton.hidden = !isShowDetail;
    }
}


#pragma mark - Getter

- (UIButton *)miniBtn{
    if (!_miniBtn) {
        _miniBtn = [[UIButton alloc] init];
        _miniBtn.tag = 0;
        _miniBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12*kDesignScaleXForIP6];
        [_miniBtn setTitle:@"小程序码" forState:UIControlStateNormal];
        [_miniBtn setTitleColor:RGB(255, 255, 255) forState:UIControlStateNormal];
        _miniBtn.backgroundColor = RGBA(0, 0, 0, 0.3);
        _miniBtn.layer.borderColor = RGBA(102, 102, 102,0.3).CGColor;
        _miniBtn.layer.borderWidth = 0.5;
        _miniBtn.layer.masksToBounds = YES;
        _miniBtn.layer.cornerRadius = 4*kDesignScaleXForIP6;
    }
    return _miniBtn;
}

- (UIButton *)saveBtn{
    if (!_saveBtn) {
        _saveBtn = [[UIButton alloc] init];
        _saveBtn.tag = 1;
        _saveBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12*kDesignScaleXForIP6];
        [_saveBtn setTitle:@"保存图片" forState:UIControlStateNormal];
        [_saveBtn setTitleColor:RGB(255, 255, 255) forState:UIControlStateNormal];
        _saveBtn.backgroundColor = RGBA(0, 0, 0, 0.3);
        _saveBtn.layer.borderColor = RGBA(102, 102, 102,0.3).CGColor;
        _saveBtn.layer.borderWidth = 0.5;
        _saveBtn.layer.masksToBounds = YES;
        _saveBtn.layer.cornerRadius = 4*kDesignScaleXForIP6;
    }
    return _saveBtn;
}

- (UIButton *)lookBtn{
    if (!_lookBtn) {
        _lookBtn = [[UIButton alloc] init];
        _lookBtn.tag = 2;
        _lookBtn.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12*kDesignScaleXForIP6];
        [_lookBtn setTitle:@"查看详情" forState:UIControlStateNormal];
        [_lookBtn setTitleColor:RGB(255, 255, 255) forState:UIControlStateNormal];
        _lookBtn.backgroundColor = RGBA(0, 0, 0, 0.3);
        _lookBtn.layer.borderColor = RGBA(102, 102, 102,0.3).CGColor;
        _lookBtn.layer.borderWidth = 0.5;
        _lookBtn.layer.masksToBounds = YES;
        _lookBtn.layer.cornerRadius = 4*kDesignScaleXForIP6;
    }
    return _lookBtn;
}


- (UIButton *)downLoadButton
{
    if (!_downLoadButton) {
        _downLoadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_downLoadButton setTitle:@"下载视频"];
        _downLoadButton.layer.cornerRadius = 4.f;
        [_downLoadButton setBackgroundColor:RGBA(0, 0, 0, 0.3)];
        _downLoadButton.layer.cornerRadius = 4.f;
        _downLoadButton.layer.borderColor = RGBA(102, 102, 102,0.3).CGColor;
        _downLoadButton.layer.borderWidth = 0.5;
        _downLoadButton.layer.masksToBounds = YES;
        _downLoadButton.layer.cornerRadius = 4 * kDesignScaleXForIP6;
        [_downLoadButton setTitleColor:UIColorFromRGB(0xffffff)];
        _downLoadButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12.f * kDesignScaleXForIP6];
    }
    return _downLoadButton;
}

- (UIButton *)detailButton
{
    if (!_detailButton) {
        _detailButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _detailButton.layer.cornerRadius = 4.f;
        [_detailButton setBackgroundColor:RGBA(0, 0, 0, 0.3)];
        _detailButton.layer.borderColor = RGBA(102, 102, 102,0.3).CGColor;
        _detailButton.layer.borderWidth = 0.5;
        _detailButton.layer.masksToBounds = YES;
        _detailButton.layer.cornerRadius = 4*kDesignScaleXForIP6;
        [_detailButton setTitleColor:UIColorFromRGB(0xffffff)];
        [_detailButton setTitle:@"查看详情"];
        _detailButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12.f * kDesignScaleXForIP6];
    }
    return _detailButton;
}
@end
