//
//  ViewController.m
//  ZOEDragCellCollectionView
//
//  Created by zhangwei on 16/7/6.
//  Copyright © 2016年 Mr.Z. All rights reserved.
//

#import "ViewController.h"
#import "ZOEDragCellCollectionView/ZOEDragCellCollectionView.h"
@interface ViewController ()
<
UICollectionViewDelegate,
UICollectionViewDataSource,
ZOEDragCellCollectionViewDataSource
>
@end

static NSString * CellIdentifier = @"UICollectionViewCell";
@implementation ViewController{
    ZOEDragCellCollectionView *_mainView;
    
    NSArray *_dataAry;
    
    NSIndexPath * _notMovePath;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    _dataAry = @[@"0",@"1",@"2",@"3",@"4"];
    
    CGFloat itemW = ([UIScreen mainScreen].bounds.size.width)/ 4;
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [flowLayout setItemSize:CGSizeMake(itemW, itemW)];
    [flowLayout setMinimumInteritemSpacing:0];
    [flowLayout setMinimumLineSpacing:0];
    
    
    _mainView = [[ZOEDragCellCollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout: flowLayout whitData:_dataAry completeBlock:^(NSArray * _Nonnull newData, NSIndexPath * _Nullable notMovePath) {
        
        _notMovePath = notMovePath;
        
        _dataAry = newData;
        
        [_mainView reloadData];
        
    }];
    [_mainView setDelegate:self];
    [_mainView setDataSource:self];
    [_mainView setViewDelegate:self];
    [_mainView setShakeMaxLevel:2];
    
    
    //注册cell
    [_mainView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier: CellIdentifier];
    [_mainView setBackgroundColor:[UIColor lightGrayColor]];
    [self.view addSubview:_mainView];
    
    
    
    
    
    
    
    
    UISwitch *switchBtn = [[UISwitch alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height - 40, 100, 30)];
    
    [self.view addSubview: switchBtn];
    
    [switchBtn addTarget:self action:@selector(setlastMoveIs:) forControlEvents:UIControlEventAllEvents];

    
    
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, switchBtn.frame.origin.y - 30, 100, 20)];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setText: @"LastMove"];
    [self.view addSubview: label];
    [label setTextColor:[UIColor whiteColor]];

    
}
-(void)setlastMoveIs:(UISwitch *)switchBtn
{
    [_mainView setLastMove:switchBtn.isOn];
}


- (NSArray * _Nonnull)dataSourceArrayOfCollectionView:(ZOEDragCellCollectionView * _Nonnull)collectionView
{
    return _dataAry;
}
#pragma mark -  UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    return _dataAry.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    UILabel *label = [[UILabel alloc]initWithFrame:cell.contentView.bounds];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setText: _dataAry[indexPath.item]];
    [cell.contentView addSubview: label];
    [label setBackgroundColor:[UIColor blackColor]];
    [label setTextColor:[UIColor whiteColor]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%@",_dataAry[indexPath.row]);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
