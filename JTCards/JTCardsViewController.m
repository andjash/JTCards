//
//  CardsViewController.m
//  Cards
//
//  Created by Armin Kroll on 8/07/13.
//  Copyright (c) 2013 jTribe. All rights reserved.
//

#import "JTCardsViewController.h"
#import "JTCardsLayout.h"

@interface JTCardsViewController ()
@property BOOL showingAll;
@end

@implementation JTCardsViewController

- (id) initWithCards:(NSArray*)cardControllers layout:(JTCardsLayout*)layout
{
  self = [super init];
  if (self) {
    self.cardControllers =  [NSMutableArray arrayWithArray:cardControllers];
    self.layout = layout;
  }
  return self;
}

- (id) initWithCards:(NSArray*)cardControllers
{
  return [self initWithCards:cardControllers layout:nil];
}

// here for debugging purpouses
- (void)updateViewConstraints {
  [super updateViewConstraints];
}

// here for debugging purpouses
- (void)viewWillLayoutSubviews {
  [super viewWillLayoutSubviews];
}

// here for debugging purpouses
- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];
}

- (void) loadView
{
  self.view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
  // make sure we are using our own layout mechanism and now autolayout of subviews.
  // This is important. Strange layout effects will happen if we use autolayout for the card views.
  // If a card controller was created in IB then the size set in there should be the size we use here as the cards shows.
  self.view.autoresizesSubviews = NO;
}


- (void)viewDidLoad
{
  [super viewDidLoad];
  [self placeCardsControllersToContainerAnimated:NO];
}

- (void) viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  NSMutableArray *views = [NSMutableArray array];
  for (UIViewController *controller in self.childViewControllers) {
    [views addObject:controller.view];
  }
  // create the default layout only if no layout was set during intialisation.
  if (!self.layout) {
    self.layout = [[JTCardsLayout alloc] initWithControllers:self.cardControllers containerView:self.view];
  }
  else {
    // the layout was already set so just add the views and container view to it.
    if (!self.layout.delegates || !self.layout.views)
      [self.layout setupWithControllers:self.cardControllers containerView:self.view];
  }
  
  [self.layout layoutAllAnimated:NO];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)setCardControllers:(NSMutableArray *)cardControllers {
  [self setCardControllers:cardControllers animated:NO];
}

- (void)setCardControllers:(NSMutableArray *)cardControllers animated:(BOOL)animated {
  NSTimeInterval animationDuration = animated ? 0.3 : 0;
  for (UIViewController *oldController in _cardControllers) {
    [oldController willMoveToParentViewController:nil];
    [UIView animateWithDuration:animationDuration animations:^{
      oldController.view.alpha = 0;
    } completion:^(BOOL finished) {
      [oldController removeFromParentViewController];
      [oldController.view removeFromSuperview];
      [oldController didMoveToParentViewController:nil];
      oldController.view.alpha = 1;
    }];
  }
  _cardControllers = cardControllers;
  [self.layout setupWithControllers:cardControllers containerView:self.view];
  [self placeCardsControllersToContainerAnimated:animated];
}

- (void)placeCardsControllersToContainerAnimated:(BOOL)animated {
  NSTimeInterval animationDuration = animated ? 0.3 : 0;
  for (UIViewController *controller in self.cardControllers) {
    [controller willMoveToParentViewController:self];
    controller.view.alpha = 0;
    [self addChildViewController:controller];
    [self.view addSubview:controller.view];
    [controller didMoveToParentViewController:self];
    [UIView animateWithDuration:animationDuration animations:^{
      controller.view.alpha = 1;
    }];
  }
  [self.layout layoutAllAnimated:animated];
}

@end
