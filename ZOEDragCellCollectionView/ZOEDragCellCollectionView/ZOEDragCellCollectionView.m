//
//  ZOEDragCellCollectionView.m
//  TestCollectionView
//
//  Created by zhangwei on 16/6/29.
//  Copyright © 2016年 qiushi. All rights reserved.
//

#import "ZOEDragCellCollectionView.h"

@implementation ZOEDragCellCollectionView{
    UILongPressGestureRecognizer *_longPressGesture;
    UIView *_tempMoveCell;
    CGPoint _lastPoint;
    NSIndexPath *_originalIndexPath;
    NSIndexPath *_moveIndexPath;
    NSIndexPath *_notMoveIndexPath;

    NSArray *_data;
    completeDragCallBack _completeDragCallBack;
    
    BOOL _dontGoLongPress;
    
    
    UILongPressGestureRecognizer * _longPress;

}
- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(nonnull UICollectionViewLayout *)layout whitData:(NSArray *)data completeBlock:(completeDragCallBack)completeDragCallBack
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        [self initalizeProperty];
        _data = data;
        _completeDragCallBack = [completeDragCallBack copy];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initalizeProperty];
    }
    return self;
}

-(void)initalizeProperty
{
    _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(zoe_longPressed:)];
    //设置长按时间
    _longPress.minimumPressDuration = 0.5;
    [self addGestureRecognizer:_longPress];
}
-(void)setMinimumPressTime:(CFTimeInterval)minimumPressTime
{
    //设置长按时间
    [_longPress setMinimumPressDuration:minimumPressTime];
}
#pragma mark -  抖动动画
#define angelToRandian(x)  ((x)/180.0*M_PI)
- (void)zoe_shakeAllCell{
    
    
    if (_shakeMaxLevel <= 0.1) {
        return;
    }else if (_shakeMaxLevel > 10.0){
        _shakeMaxLevel = 10.0;
    }
    CGFloat _shakeLevel = _shakeMaxLevel;
    CAKeyframeAnimation* anim=[CAKeyframeAnimation animation];
    anim.keyPath=@"transform.rotation";
    anim.values=@[@(angelToRandian(-_shakeLevel)),@(angelToRandian(_shakeLevel)),@(angelToRandian(-_shakeLevel))];
    anim.repeatCount=MAXFLOAT;
    anim.duration=0.2;
    NSArray *cells = [self visibleCells];
    for (UICollectionViewCell *cell in cells) {
        /**如果加了shake动画就不用再加了*/
        if (![cell.layer animationForKey:@"shake"]) {
            [cell.layer addAnimation:anim forKey:@"shake"];
        }
    }
}
- (void)zoe_stopShakeAllCell{
    NSArray *cells = [self visibleCells];
    for (UICollectionViewCell *cell in cells) {
        [cell.layer removeAllAnimations];
    }
    [_tempMoveCell.layer removeAllAnimations];
}
#pragma mark -  长按手势

-(void)zoe_longPressed:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state == UIGestureRecognizerStateBegan) {
        [self zoe_gestureBegan:longPress];
    }
    if (longPress.state == UIGestureRecognizerStateChanged) {
        [self zoe_gestureChange:longPress];
    }
    if (longPress.state == UIGestureRecognizerStateEnded){
        [self zoe_gestureEndOrCancle:longPress];
    }
}

- (void)zoe_gestureBegan:(UILongPressGestureRecognizer *)longPressGesture{
    
    NSMutableArray *temp = @[].mutableCopy;
    
    //获取数据源
    NSAssert(_viewDelegate != NULL, @"viewDelegate not setup !!!!!!!!!!");//断言，与条件相反就中断
    
    if ([(id)_viewDelegate respondsToSelector:@selector(dataSourceArrayOfCollectionView:)]) {
        [temp addObjectsFromArray:[self.viewDelegate dataSourceArrayOfCollectionView:self]];
    }
    _data = temp;

    //获取手指所在的cell
    _originalIndexPath = [self indexPathForItemAtPoint:[longPressGesture locationOfTouch:0 inView:longPressGesture.view]];
    
    if (_originalIndexPath.row == _data.count - 1 && self.lastMove == NO) {
        _dontGoLongPress = YES;
        return;
    }else{
        _dontGoLongPress = NO;
    }
    
    [self zoe_shakeAllCell];
    //设置将要移动的cell位置
    _notMoveIndexPath = _originalIndexPath;
    
    UICollectionViewCell *cell = [self cellForItemAtIndexPath:_originalIndexPath];
    //截图大法，得到cell的截图视图
    UIView *tempMoveCell = [cell snapshotViewAfterScreenUpdates:NO];
    _tempMoveCell = tempMoveCell;
    _tempMoveCell.frame = cell.frame;
    [self addSubview:_tempMoveCell];
    //隐藏cell
    cell.hidden = YES;
    //记录当前手指位置
    _lastPoint = [longPressGesture locationOfTouch:0 inView:longPressGesture.view];
}

/**
 *  手势拖动
 */
- (void)zoe_gestureChange:(UILongPressGestureRecognizer *)longPressGesture{
    if (_dontGoLongPress) {
        return;
    }
    CGFloat tranX = [longPressGesture locationOfTouch:0 inView:longPressGesture.view].x - _lastPoint.x;
    CGFloat tranY = [longPressGesture locationOfTouch:0 inView:longPressGesture.view].y - _lastPoint.y;
    _tempMoveCell.center = CGPointApplyAffineTransform(_tempMoveCell.center, CGAffineTransformMakeTranslation(tranX, tranY));
    _lastPoint = [longPressGesture locationOfTouch:0 inView:longPressGesture.view];
    [self zoe_moveCell];
}
/**
 *  手势取消或者结束
 */
- (void)zoe_gestureEndOrCancle:(UILongPressGestureRecognizer *)longPressGesture{
    if (_dontGoLongPress) {
        return;
    }
    UICollectionViewCell *cell = [self cellForItemAtIndexPath:_originalIndexPath];
    self.userInteractionEnabled = NO;

    [UIView animateWithDuration:0.25 animations:^{
        _tempMoveCell.center = cell.center;
    } completion:^(BOOL finished) {
        [self zoe_stopShakeAllCell];
        [_tempMoveCell removeFromSuperview];
        cell.hidden = NO;
        self.userInteractionEnabled = YES;
        
        
        if (![_notMoveIndexPath isEqual: _originalIndexPath]) {
            _notMoveIndexPath = nil;
        }
        
        
        
        if (_completeDragCallBack) {
            _completeDragCallBack(_data,_notMoveIndexPath);
        }

    }];
}

#pragma mark - private methods

- (void)zoe_moveCell{
    for (UICollectionViewCell *cell in [self visibleCells]) {
        if ([self indexPathForCell:cell] == _originalIndexPath) {
            continue;
        }
        //计算中心距
        CGFloat spacingX = fabs(_tempMoveCell.center.x - cell.center.x);
        CGFloat spacingY = fabs(_tempMoveCell.center.y - cell.center.y);
        if (spacingX <= _tempMoveCell.bounds.size.width / 2.0f && spacingY <= _tempMoveCell.bounds.size.height / 2.0f) {
            
            _moveIndexPath = [self indexPathForCell:cell];
            
            
            
            //最后一个是否可以移动的判断
            if (self.lastMove == NO && _moveIndexPath.row == _data.count - 1) {
                _moveIndexPath = [NSIndexPath indexPathForRow:_moveIndexPath.row - 1 inSection:_moveIndexPath.section];
            }
            //更新数据源
            [self zoe_updateDataSource];
            //移动
            [self moveItemAtIndexPath:_originalIndexPath toIndexPath:_moveIndexPath];
            //设置移动后的起始indexPath
            _originalIndexPath = _moveIndexPath;
            break;
        }
    }
}

- (void)zoe_updateDataSource{
 
    NSMutableArray *temp = _data.mutableCopy;

    
    //判断数据源是单个数组还是数组套数组的多section形式，YES表示数组套数组
    BOOL dataTypeCheck = ([self numberOfSections] != 1 || ([self numberOfSections] == 1 && [temp[0] isKindOfClass:[NSArray class]]));
    if (dataTypeCheck) {
        for (int i = 0; i < temp.count; i ++) {
            [temp replaceObjectAtIndex:i withObject:[temp[i] mutableCopy]];
        }
    }
    if (_moveIndexPath.section == _originalIndexPath.section) {
        NSMutableArray *orignalSection = dataTypeCheck ? temp[_originalIndexPath.section] : temp;
        if (_moveIndexPath.item > _originalIndexPath.item) {
            for (NSUInteger i = _originalIndexPath.item; i < _moveIndexPath.item ; i ++) {
                [orignalSection exchangeObjectAtIndex:i withObjectAtIndex:i + 1];
            }
        }else{
            for (NSUInteger i = _originalIndexPath.item; i > _moveIndexPath.item ; i --) {
                [orignalSection exchangeObjectAtIndex:i withObjectAtIndex:i - 1];
            }
        }
    }else{
        NSMutableArray *orignalSection = temp[_originalIndexPath.section];
        NSMutableArray *currentSection = temp[_moveIndexPath.section];
        [currentSection insertObject:orignalSection[_originalIndexPath.item] atIndex:_moveIndexPath.item];
        [orignalSection removeObject:orignalSection[_originalIndexPath.item]];
    }
    _data = temp;
}

@end
