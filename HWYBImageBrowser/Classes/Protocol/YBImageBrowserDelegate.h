//
//  YBImageBrowserDelegate.h
//  YBImageBrowserDemo
//
//  Created by 杨波 on 2018/9/10.
//  Copyright © 2018年 杨波. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YBImageBrowserCellDataProtocol.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, YBImageBrowserBottomBarClickedType) {
    YBImageBrowserBottomBarClickedTypeMini,//小程序
    YBImageBrowserBottomBarClickedTypeSave,//保存
    YBImageBrowserBottomBarClickedTypeLook,//图片查看详情
    YBImageBrowserBottomBarClickedTypeDownload,//下载
    YBImageBrowserBottomBarClickedTypeDetail,//视频查看详情
};

@class YBImageBrowser;

@protocol YBImageBrowserDelegate <NSObject>

@optional

- (void)yb_imageBrowser:(YBImageBrowser *)imageBrowser pageIndexChanged:(NSUInteger)index data:(id<YBImageBrowserCellDataProtocol>)data;

- (void)yb_imageBrowser:(YBImageBrowser *)imageBrowser respondsToLongPress:(UILongPressGestureRecognizer *)longPress;

- (void)yb_imageBrowser:(YBImageBrowser *)imageBrowser transitionAnimationEndedWithIsEnter:(BOOL)isEnter;

- (void)yb_imageBrowser:(YBImageBrowser *)imageBrowser showVideoBottomBar:(BOOL)isShow data:(id<YBImageBrowserCellDataProtocol>)data;

- (void)yb_imageBrowser:(YBImageBrowser *)imageBrowser bottomBarClickedType:(YBImageBrowserBottomBarClickedType)type data:(id<YBImageBrowserCellDataProtocol>)data;

@end

NS_ASSUME_NONNULL_END
