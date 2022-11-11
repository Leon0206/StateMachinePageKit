//
//  BaseViewState.m
//  MDStatePageKit
//
//  Created by Leon0206 on 2018/5/13.
//

#import "BaseViewState.h"
#import "BaseStateDelegate.h"

@interface BaseViewState ()
@end

@implementation BaseViewState

- (UIView *)contentView
{
    if (!_contentView) {
        _contentView = [[UIView alloc]init];
    }
    return _contentView;
}

- (void)didEnterWithPreviousState:(BaseViewState *)preState
{
    [self.fatherView addSubview:self.contentView];
    [self loadChildStates];
    [self freeChildStates:preState];
}

/*
 前一个状态节点的子状态以及contentView实时释放，从而可以及时
 释放部分内存，尽可能做到内存轻量化
 */
- (void)freeChildStates:(BaseViewState *)preState
{
    preState.childStates = nil;
}

- (void)willExitWithNextState:(BaseViewState *)nextState
{
    [_contentView removeFromSuperview];
    _contentView = nil;
}

- (NSArray *)childViewStates
{
    return @[];
}

- (void)loadChildStates
{
    NSMutableArray *viewStates =  [NSMutableArray array];
    for (NSString *obj in [self childViewStates]) {
        Class class = NSClassFromString(obj);
        if (!class) continue;
        __kindof BaseViewState *state = [[class alloc]init];
        state.fatherView = self.contentView;
        [viewStates addObject:state];
    }
    self.childStates = [GKStateMachine stateMachineWithStates:viewStates];
    //对于每种状态，它的子状态之间，互为兄弟状态
    for (BaseViewState *state in viewStates) {
        state.brotherStates = self.childStates;
    }
}

@end
