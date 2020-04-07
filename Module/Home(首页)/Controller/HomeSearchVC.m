//
//  HomeSearchVC.m
//  JMBaseProject
//
//  Created by 利是封 on 2020/3/11.
//  Copyright © 2020 liuny. All rights reserved.
//

#import "HomeSearchVC.h"
#import "HomeProductCell.h"
@interface HomeSearchVC ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *serchBgView;

@property (strong, nonatomic) NSMutableArray *dataArray;
@property (strong, nonatomic) JMRefreshTool *refreshTool;
@property (nonatomic, assign) BOOL canScroll;
@end

@implementation HomeSearchVC


- (instancetype)initWithStoryboard {
    return [self initWithStoryboardName:@"Home"];
}

- (void)initControl {
    ViewBorderRadius(self.serchBgView, 5, 1, [UIColor colorWithHexString:@"#CCCCCC"]);
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.alwaysBounceVertical = YES;
    //refreshTool
    self.refreshTool = [[JMRefreshTool alloc] initWithScrollView:self.collectionView dataAnalysisBlock:^NSArray *(NSDictionary *responseData) {
        NSMutableArray *array = [NSMutableArray array];
        NSDictionary *dataDic = responseData[@"data"];
        for (NSDictionary *dic in dataDic[@"list"]) {
            GoodModel *model = [[GoodModel alloc] initWithHomeListDic:dic];
            [array addObject:model];
        }
        if (self.refreshTool.isAddData) {
            //上拉加载
            [self.dataArray addObjectsFromArray:array.copy];
        } else {
            //下拉刷新
            self.dataArray = array;
            [[NSNotificationCenter defaultCenter] postNotificationName:kHome_NotificationEndRefreshing object:nil userInfo:nil];
        }
        [self.collectionView reloadData];
        return array;
    }];
    self.refreshTool.requestParams = [NSMutableDictionary dictionary];
    self.refreshTool.requestParams[@"sessionId"] = [JMProjectManager sharedJMProjectManager].loginUser.sessionId;
//    self.refreshTool.requestParams[@"type"] = @(self.type);
//    self.refreshTool.requestUrl = kHome_UrlGoodList;
}

- (void)initData {
    if (kUseTestData) {
        self.dataArray = @[[[GoodModel alloc] initWithTest], [[GoodModel alloc] initWithTest], [[GoodModel alloc] initWithTest], [[GoodModel alloc] initWithTest], [[GoodModel alloc] initWithTest], [[GoodModel alloc] initWithTest], [[GoodModel alloc] initWithTest], [[GoodModel alloc] initWithTest], [[GoodModel alloc] initWithTest], [[GoodModel alloc] initWithTest], [[GoodModel alloc] initWithTest]].mutableCopy;
    } else {
        [self.collectionView.mj_header beginRefreshing];
    }
}

#pragma mark -navigation
- (BOOL)navUIBaseViewControllerIsNeedNavBar:(JMNavUIBaseViewController *)navUIBaseViewController {
    return NO;
}

#pragma mark -notification
- (void)startRefreshing {
    //开始刷新
    [self.collectionView.mj_header beginRefreshing];
}


#pragma mark -Action
- (IBAction)searchAction:(id)sender {
    
}

- (IBAction)popAction:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark -colletionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    HomeProductCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HomeProductCell" forIndexPath:indexPath];
    GoodModel *model = self.dataArray[indexPath.row];
    cell.cellData = model;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    GoodModel *model = self.dataArray[indexPath.row];
    GoodsDetailsVC *goodsDetailsVC = [[GoodsDetailsVC alloc] initWithStoryboard];
    goodsDetailsVC.goodId = model.goodId;
    [self.navigationController pushViewController:goodsDetailsVC animated:YES];
}

//设置item大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = CGSizeMake((kScreenWidth - 24.5) / 2 - 0.5, (kScreenWidth - 24.5) / 2 + 100);
    return size;
}

// 两行cell之间的间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 5.0;
}

//item每一列（或者每一行，如果是横向的，就是行，纵向的就是列）
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 4.5;
}

#pragma mark -懒加载
- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}


@end
