//
//  AAKAAEditAnimatedTransitioning.m
//  AAKeyboardApp
//
//  Created by sonson on 2014/10/29.
//  Copyright (c) 2014年 sonson. All rights reserved.
//

#import "AAKAAEditAnimatedTransitioning.h"

@interface AAKAAEditAnimatedTransitioning() {
	BOOL _isPresent;	/** 表示中であるかのフラグ．このフラグがYESのときは，すでに表示中を意味する． */
}
@end

@implementation AAKAAEditAnimatedTransitioning

/**
 * AAKAAEditAnimatedTransitioningオブジェクトを初期化する．
 * 表示中であるかのフラグ．このフラグがYESのときは，すでに表示中を意味する．
 * 表示する時も，破棄する時もこのクラスを使う．
 * @param presentFlag 表示中であるかのフラグ
 * @return 初期化されたAAKAAEditAnimatedTransitioningオブジェクト．
 **/
- (instancetype)initWithPresentFlag:(BOOL)presentFlag {
	self = [super init];
	if (self) {
		_isPresent = presentFlag;
	}
	return self;
}

/**
 * プレビューコントローラ上のtextviewでレンダリングされるAAの実サイズを取得する．
 * このサイズは，セルとプレビュー間の拡大縮小アニメーションに使う．
 * @param transitionContext トランジションのコンテキストオブジェクト．
 * @param previewController プレビューコントローラ．このビューコントローラがもつAAKASCIIArtオブジェクトからアスキーアートのアスペクト比を取得する．
 * @return プレビューコントローラ上のtextviewでレンダリングされるAAのサイズ．
 **/
- (CGSize)AASizeForPreviewControllerWithTransition:(id<UIViewControllerContextTransitioning>)transitionContext
								 previewController:(AAKDestinationPreviewController*)previewController {
	// 画面全体のフレームを取得する．
	CGRect containerViewFrame = [transitionContext containerView].frame;
	
	containerViewFrame = CGRectInset(containerViewFrame, [[previewController class] marginConstant], [[previewController class] marginConstant]);

	// aspect ratio
	// コンテナビューとプレビューコントローラのサイズが同じなのでこれでよい
	CGFloat containerViewRatio = containerViewFrame.size.width / containerViewFrame.size.height;
	CGFloat asciiartRatio = previewController.content.ratio;
	
	if (containerViewRatio >= asciiartRatio) {
		float w = containerViewFrame.size.height * asciiartRatio;
		float h = containerViewFrame.size.height;
		return CGSizeMake(w, h);
	}
	else {
		float w = containerViewFrame.size.width;
		float h = containerViewFrame.size.width / asciiartRatio;
		return CGSizeMake(w, h);
	}
}

/**
 * コレクションコントローラ上のセルのtextviewでレンダリングされるAAの実サイズを取得する．
 * セルは，指定したプレビューコントローラと同じアスキーアートをもつものが選ばれる．
 * このサイズは，セルとプレビュー間の拡大縮小アニメーションに使う．
 * @param transitionContext トランジションのコンテキストオブジェクト．
 * @param previewController プレビューコントローラ．このビューコントローラがもつAAKASCIIArtオブジェクトからアスキーアートのアスペクト比を取得する．
 * @param collectionViewController コレクションビューコントローラ．このビューコントローラがもつcollectionビューコントローラから，プレビューコントローラのアスキーアートと同じアスキーアートをもつセルを取得する．
 * @return コレクションコントローラ上のセルのtextviewでレンダリングされるAAのサイズ．
 **/
- (CGSize)AASizeForAACollectionViewControllerWithTransition:(id<UIViewControllerContextTransitioning>)transitionContext
										  previewController:(AAKDestinationPreviewController*)previewController
								   collectionViewController:(AAKSourceCollectionViewController*)collectionViewController {
	
	AAKSourceCollectionViewCell *cell = (AAKSourceCollectionViewCell*)[collectionViewController cellForContent:previewController.content];
	
	// aspect ratio
	// コンテナビューとプレビューコントローラのサイズが同じなのでこれでよい
	CGFloat textViewOnCellRatio = cell.textView.frame.size.width / cell.textView.frame.size.height;
	CGFloat asciiartRatio = previewController.content.ratio;
	
	if (textViewOnCellRatio >= asciiartRatio) {
		float w = cell.textView.frame.size.height * asciiartRatio;
		float h = cell.textView.frame.size.height;
		return CGSizeMake(w, h);
	}
	else {
		float w = cell.textView.frame.size.width;
		float h = cell.textView.frame.size.width / asciiartRatio;
		return CGSizeMake(w, h);
	}
}

/**
 * ナビゲーションコントローラのトップビューからAAKAACollectionViewControllerを抽出する．
 * 引数のviewControllerがナビゲーションコントローラではない場合，AAKAACollectionViewControllerが見つからない場合はnilを返す．
 * @param viewController ビューコントローラ．
 * @return 抽出したAAKAACollectionViewControllerビューコントローラ．
 **/
- (AAKSourceCollectionViewController*)collectionViewControllerFromViewController:(UIViewController*)viewController {
	AAKSourceCollectionViewController *collectionViewController = nil;
	if ([viewController isKindOfClass:[UINavigationController class]]) {
		UINavigationController *nav = (UINavigationController*)viewController;
		if ([nav.topViewController conformsToProtocol:@protocol(AAKSourceCollectionViewControllerProtocol)]) {
			collectionViewController = (AAKSourceCollectionViewController*)nav.topViewController;
		}
	}
	if ([viewController isKindOfClass:[UITabBarController class]]) {
		UITabBarController *tab = (UITabBarController*)viewController;
		if ([tab.selectedViewController isKindOfClass:[UINavigationController class]]) {
			UINavigationController *nav = (UINavigationController*)tab.selectedViewController;
			if ([nav.topViewController conformsToProtocol:@protocol(AAKSourceCollectionViewControllerProtocol)]) {
				collectionViewController = (AAKSourceCollectionViewController*)nav.topViewController;
			}
		}
	}
	return collectionViewController;
}

/**
 * ビューコントローラをAAKPreviewControllerとして返す．
 * ビューコントローラがAAKPreviewControllerクラスでない場合，nilを返す．
 * @param viewController ビューコントローラ．
 * @return 抽出したAAKPreviewControllerビューコントローラ．
 **/
- (AAKDestinationPreviewController*)previewViewControllerFromViewController:(UIViewController*)viewController {
	AAKDestinationPreviewController *outputViewController = nil;
	if ([viewController isKindOfClass:[UINavigationController class]]) {
		UINavigationController *nav = (UINavigationController*)viewController;
		if ([nav.topViewController conformsToProtocol:@protocol(AAKDestinationPreviewControllerProtocol)]) {
			outputViewController = (AAKDestinationPreviewController*)nav.topViewController;
		}
	}
	return outputViewController;
}

/**
 * 表示トランジションを実行する．
 * @param transitionContext トランジションのコンテキストオブジェクト．
 **/
- (void)animationPresentTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
	UIViewController *fromController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
	UIViewController *toController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

	AAKSourceCollectionViewController *collectionViewController = [self collectionViewControllerFromViewController:fromController];
	AAKDestinationPreviewController *previewController = [self previewViewControllerFromViewController:toController];
	
	// for error case
	if (previewController == nil || collectionViewController == nil) {
		[[transitionContext containerView] addSubview:toController.view];
		[transitionContext completeTransition:YES];
		return;
	}

	AAKSourceCollectionViewCell *cell = (AAKSourceCollectionViewCell*)[collectionViewController cellForContent:previewController.content];
	
	CGSize fromContentSize = [self AASizeForAACollectionViewControllerWithTransition:transitionContext
																   previewController:previewController
															collectionViewController:collectionViewController];
	CGSize toContentSize = [self AASizeForPreviewControllerWithTransition:transitionContext
														previewController:previewController];
	float scale = toContentSize.width / fromContentSize.width;
	
	
	AAKTextView *textView = [cell textViewForAnimation];
	textView.backgroundColor = [UIColor clearColor];
	
	// Magnify text view on cell keeping its aspect ratio.
	CGRect frameOfStartTextView = [[transitionContext containerView] convertRect:cell.textView.bounds fromView:cell.textView];
	textView.frame = frameOfStartTextView;
	[textView updateLayout];
	[textView setNeedsDisplay];
	CGRect frameOfDestinationTextView = CGRectMake(0, 0, cell.textView.frame.size.width * scale, cell.textView.frame.size.height * scale);
	
	// Setup destination view controller's view
	[[transitionContext containerView] addSubview:toController.view];
	[[transitionContext containerView] addSubview:textView];
	previewController.view.alpha = 0;
	previewController.textView.hidden = YES;
	
	cell.textView.hidden = YES;
	
	void (^animations)(void) = ^void (void) {
		textView.frame = frameOfDestinationTextView;
		textView.center = CGPointMake(ceil([transitionContext containerView].center.x), ceil([transitionContext containerView].center.y));
		textView.alpha = 1;
		previewController.view.alpha = 1.0;
	};
	
	void (^completion)(BOOL) = ^void (BOOL finished) {
		previewController.view.alpha = 1.0;
		[textView removeFromSuperview];
		[transitionContext completeTransition:YES];
		previewController.textView.hidden = NO;
		cell.textView.hidden = NO;
	};
	
	if ([self springsWithDamping]) {
		[UIView animateWithDuration:[self transitionDuration:transitionContext]
							  delay:0
			 usingSpringWithDamping:0.5
			  initialSpringVelocity:0
							options:UIViewAnimationOptionCurveEaseOut
						 animations:animations
						 completion:completion];
	}
	else {
		[UIView animateWithDuration:[self transitionDuration:transitionContext]
						 animations:animations
						 completion:completion];
	}
}

/**
 * 破棄トランジションを実行する．
 * @param transitionContext トランジションのコンテキストオブジェクト．
 **/
- (void)animationDismissTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
	UIViewController *fromController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
	UIViewController *toController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

	AAKSourceCollectionViewController *collectionViewController = [self collectionViewControllerFromViewController:toController];
	AAKDestinationPreviewController *previewController = [self previewViewControllerFromViewController:fromController];
	
	// for error case
	if (previewController == nil || collectionViewController == nil) {
		[transitionContext completeTransition:YES];
		return;
	}
	
	AAKSourceCollectionViewCell *cell = (AAKSourceCollectionViewCell*)[collectionViewController cellForContent:previewController.content];
	cell.textView.hidden = YES;
	
	CGSize toContentSize = [self AASizeForAACollectionViewControllerWithTransition:transitionContext
																   previewController:previewController
															collectionViewController:collectionViewController];
	CGSize fromContentSize = [self AASizeForPreviewControllerWithTransition:transitionContext
														previewController:previewController];
	float scale = fromContentSize.width / toContentSize.width;
	
	AAKTextView *textView = [cell textViewForAnimation];
	textView.backgroundColor = [UIColor clearColor];
	[[transitionContext containerView] addSubview:textView];
	
	previewController.textView.hidden = YES;
	
	CGRect frameOfDestinationTextView = [[transitionContext containerView] convertRect:cell.textView.bounds fromView:cell.textView];
	
	CGRect frameOfFromTextView = CGRectMake(0, 0, cell.textView.frame.size.width * scale, cell.textView.frame.size.height * scale);
	textView.frame = frameOfFromTextView;
	textView.center = [[transitionContext containerView] convertPoint:previewController.textView.center fromView:previewController.textView.superview];
	
	void (^animations)(void) = ^void (void) {
		textView.alpha = 1;
		textView.frame = frameOfDestinationTextView;
		fromController.view.alpha = 0;
	};
	
	void (^completion)(BOOL) = ^void (BOOL finished) {
		[textView removeFromSuperview];
		cell.textView.hidden = NO;
		[transitionContext completeTransition:YES];
	};
	
	if ([self springsWithDamping]) {
		[UIView animateWithDuration:[self transitionDuration:transitionContext]
							  delay:0
			 usingSpringWithDamping:0.5
			  initialSpringVelocity:0
							options:UIViewAnimationOptionCurveEaseOut
						 animations:animations
						 completion:completion];
	}
	else {
		[UIView animateWithDuration:[self transitionDuration:transitionContext]
						 animations:animations
						 completion:completion];
	}
}

- (BOOL)springsWithDamping {
	return NO;
}

#pragma mark - Override

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
	// 表示か，破棄は，フラグで判定する．
	if (_isPresent) {
		[self animationDismissTransition:transitionContext];
	}
	else {
		[self animationPresentTransition:transitionContext];
	}
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
	if ([self springsWithDamping])
		return 0.4;
	else
		return 0.2;
}

@end
