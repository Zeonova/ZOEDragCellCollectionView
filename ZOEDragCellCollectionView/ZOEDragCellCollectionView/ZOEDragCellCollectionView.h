//
//  ZOEDragCellCollectionView.h
//  TestCollectionView
//
//  Created by zhangwei on 16/6/29.
//  Copyright © 2016年 qiushi. All rights reserved.
//  ZOEDragCellCollectionView





//  仅测试过单个session




///ZOEDragCellCollectionViewDataSource 协议
#import <UIKit/UIKit.h>
@class ZOEDragCellCollectionView;

@protocol  ZOEDragCellCollectionViewDataSource
@required
/**
 *  返回整个CollectionView的数据，必须实现，需根据数据进行移动后的数据重排
 */
- (NSArray * _Nonnull)dataSourceArrayOfCollectionView:(ZOEDragCellCollectionView * _Nonnull)collectionView;
@end













/**
 *  回调block
 *
 *  @param newData     移动后重组的新数据
 *  @param notMovePath 如果移动位置没有变化则返回对应的path，如果有变化则为nil
 */
typedef void (^completeDragCallBack) (NSArray * _Nonnull newData,NSIndexPath *_Nullable notMovePath);
@interface ZOEDragCellCollectionView : UICollectionView
/**
 *  初始化方法
 *
 *  @param frame             坐标
 *  @param layout            布局
 *  @param data              初始化数据
 *  @param completeDragblock 回调block
 *
 *  @return ZOEDragCellCollectionView
 */
- (_Nonnull instancetype)initWithFrame:(CGRect)frame collectionViewLayout:( UICollectionViewLayout *_Nonnull)layout whitData:(NSArray *_Nonnull)data completeBlock:(completeDragCallBack _Nonnull)completeDragblock;


/**
 *  必须实现的代理
 */
@property (nonatomic, weak, nullable) id <ZOEDragCellCollectionViewDataSource> viewDelegate;


/**
 *  最后一个是否可以移动
 */
@property(nonatomic,assign)BOOL lastMove;
/**
 *  长按时间，默认1.5；
 */
@property (nonatomic) CFTimeInterval minimumPressTime;
/**
 *  抖动等级，0则关闭，最大10,默认不抖动
 */
@property (nonatomic) CGFloat shakeMaxLevel;
@end
