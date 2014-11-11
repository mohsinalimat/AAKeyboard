//
//  AAKContentCell.m
//  AAKeyboardApp
//
//  Created by sonson on 2014/10/09.
//  Copyright (c) 2014年 sonson. All rights reserved.
//

#import "AAKContentCell.h"

#import "AAKShared.h"

@interface AAKContentCell() {
	UILabel		*_label;
	AAKTextView	*_textView;
	NSLayoutConstraint *_widthConstraint;
	NSLayoutConstraint *_heightConstraint;
	UIImageView *_seperator;
}
@end

@implementation AAKContentCell

- (UIColor*)cellHighlightedBackgroundColor {
	if (_keyboardAppearance == UIKeyboardAppearanceDark) {
		return [UIColor lightColorForDark];
	}
	else {
		return [UIColor darkColorForDefault];
	}
}

- (UIColor*)colorForAA {
	if (_keyboardAppearance == UIKeyboardAppearanceDark) {
		return [UIColor whiteColor];
	}
	else {
		return [UIColor blackColor];
	}
}

#pragma mark - Instance method

/**
 * AAを画像としてクリップボードにコピーする．
 **/
- (void)copyAAImageToPasteBoard {
	UIImage *image = [self.textView imageForPasteBoard];
	[[UIPasteboard generalPasteboard] setValue:UIImagePNGRepresentation(image) forPasteboardType:@"public.png"];
	[[NSNotificationCenter defaultCenter] postNotificationName:AAKTextViewDidCopyAAImageToPasteboard object:nil userInfo:nil];
}

/**
 * セルを初期化する．
 * テキストビューの生成，レイアウト，背景色の設定，ジェスチャのアタッチを行う．
 **/
- (void)privateInit {
	// テキストビューをセットアップ
	_textView = [[AAKTextView alloc] initWithFrame:CGRectZero];
	[self.contentView addSubview:_textView];
	_textView.translatesAutoresizingMaskIntoConstraints = NO;
	_textView.backgroundColor = [UIColor clearColor];
	_textView.userInteractionEnabled = NO;
	
	self.backgroundColor = [UIColor clearColor];
	self.contentView.backgroundColor = [UIColor clearColor];
	
	// autolayout
	NSDictionary *views = NSDictionaryOfVariableBindings(_textView);
	[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[_textView]-10-|"
																			 options:0 metrics:0 views:views]];
	[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-10-[_textView]-10-|"
																			 options:0 metrics:0 views:views]];
	
	// 背景をセット
	self.selectedBackgroundView = [[UIView alloc] initWithFrame:self.frame];
	
	_seperator = [[UIImageView alloc] initWithFrame:CGRectZero];
	[self.contentView addSubview:_seperator];
	
	// ジェスチャを設定
	UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
	longPress.minimumPressDuration = 1;
	[self addGestureRecognizer:longPress];
}

- (void)setIsTail:(BOOL)isTail {
	_isTail = isTail;
	_seperator.hidden = _isTail;
}

- (void)setKeyboardAppearance:(UIKeyboardAppearance)keyboardAppearance {
	_keyboardAppearance = keyboardAppearance;
	self.selectedBackgroundView.backgroundColor = [self cellHighlightedBackgroundColor];
	_seperator.image = [UIImage rightEdgeWithKeyboardAppearance:_keyboardAppearance];
}

#pragma mark - Override

- (void)setBounds:(CGRect)bounds {
	[super setBounds:bounds];
	self.contentView.frame = bounds;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	_seperator.frame = CGRectMake(self.frame.size.width - 2, 0, 2, self.frame.size.height);
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	[self privateInit];
	return self;
}

- (void)awakeFromNib {
	[super awakeFromNib];
	[self privateInit];
}

#pragma mark - UIGestureRecognizer

/**
 * 長押しジェスチャの状態変化を受け取るメソッド
 **/
- (void)longPress:(UIGestureRecognizer*)gestureRecognizer {
	DNSLogMethod
	if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
		DNSLog(@"UIGestureRecognizerStateBegan");
	}
	else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
		DNSLog(@"UIGestureRecognizerStateChanged");
	}
	else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
		DNSLog(@"UIGestureRecognizerStateEnded");
		[self copyAAImageToPasteBoard];
	}
}

@end
