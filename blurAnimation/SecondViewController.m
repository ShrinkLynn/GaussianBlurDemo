//
//  SecondViewController.m
//  blurAnimation
//
//  Created by lynn on 15/12/3.
//  Copyright © 2015年 lynn. All rights reserved.
//

#import "SecondViewController.h"

static NSString *const tableCellStr = @"tableCellStr";

@implementation SecondViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITableView *tableView =  [[UITableView alloc]initWithFrame:self.view.bounds];
    tableView.delegate = (id<UITableViewDelegate>)self;
    tableView.dataSource = (id<UITableViewDataSource>)self;
    [self.view addSubview:tableView];
    
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:tableCellStr];
}
#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 15;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 80;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:tableCellStr forIndexPath:indexPath];
    cell.textLabel.backgroundColor = [UIColor colorWithRed:arc4random() % 256 / 256.0 green: arc4random() % 256 / 256.0 blue:arc4random() % 256 / 256.0 alpha:1.0];
    cell.textLabel.text = [NSString stringWithFormat:@" this is row %ld",(long)indexPath.row];
    return cell;

    
}
#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



@end
