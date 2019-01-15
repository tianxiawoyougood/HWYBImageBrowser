//
//  YBImageBrowserBottomBar.h
//  newhwmc
//
//  Created by sunbinhua on 2018/12/12.
//  Copyright © 2018 paidian. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class HWDisMaterialModel;
@interface YBImageBrowserBottomBar : UIView

@property (nonatomic, strong) UIButton *miniBtn;
@property (nonatomic, strong) UIButton *saveBtn;
@property (nonatomic, strong) UIButton *lookBtn;

@property (nonatomic, strong) UIButton * downLoadButton;
@property (nonatomic, strong) UIButton * detailButton;

@property (nonatomic, strong) HWDisMaterialModel *materiaModel;


- (void)showVideoToolBar:(BOOL)isShow  checkGoods_info:(BOOL)isCheck;

@end

NS_ASSUME_NONNULL_END
