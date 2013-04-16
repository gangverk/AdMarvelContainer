//
//  AdMarvelContainer.m
//
//  Created by Kevin Renskers on 10-07-12.
//  Copyright (c) 2012 Gangverk. All rights reserved.
//

#import "AdMarvelContainer.h"

#define PADDING_TOP 10

@interface AdMarvelContainer ()
@property (strong, nonatomic) AdController *adController;
@property (weak, nonatomic) AdMarvelView *adMarvelView;
@end

@implementation AdMarvelContainer

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self sharedInit];
    }
    return self;
}

- (void)sharedInit {
    self.hidden = YES;
    self.adController = [[AdController alloc] init];
}

- (void)setDelegate:(id<AdMarvelContainerDelegate>)delegate {
    _delegate = delegate;

    if ([_delegate respondsToSelector:@selector(adMarvelSiteId)]) {
        self.adController.siteId = [_delegate adMarvelSiteId];
    }

    if ([_delegate respondsToSelector:@selector(adMarvelPartnerId)]) {
        self.adController.partnerId = [_delegate adMarvelPartnerId];
    }

    if ([_delegate respondsToSelector:@selector(adMarvelViewFrame)]) {
        self.adController.frame = [_delegate adMarvelViewFrame];
    }

    if ([_delegate respondsToSelector:@selector(adMarvelTargetingParameters)]) {
        self.adController.adMarvelTargetingParameters = [_delegate adMarvelTargetingParameters];
    }

    BOOL hasCloseAdButton = YES;
    if ([_delegate respondsToSelector:@selector(hasCloseAdButton)]) {
        hasCloseAdButton = [_delegate hasCloseAdButton];
    }

    __weak AdMarvelContainer *weakSelf = self;

    [self.adController getAdWithSuccessBlock:^(AdMarvelView *adMarvelView) {
        weakSelf.adMarvelView = adMarvelView;

        if (hasCloseAdButton) {
            CGRect newContainerFrame = weakSelf.frame;
            newContainerFrame.size.height = adMarvelView.frame.size.height + PADDING_TOP;
            weakSelf.frame = newContainerFrame;

            CGRect newAdMarvelViewFrame = adMarvelView.frame;
            newAdMarvelViewFrame.origin.y = PADDING_TOP;
            adMarvelView.frame = newAdMarvelViewFrame;
        }

        [weakSelf addSubview:adMarvelView];

        if (hasCloseAdButton) {
            __weak UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
            closeButton.frame = CGRectMake(weakSelf.frame.size.width-40, 0, 40, 40);
            [closeButton setImage:[UIImage imageNamed:@"b_ad_close"] forState:UIControlStateNormal];
            [closeButton setContentEdgeInsets:UIEdgeInsetsMake(0, 12, 12, 0)];
            [closeButton addTarget:weakSelf action:@selector(closeAd) forControlEvents:UIControlEventTouchUpInside];
            [weakSelf addSubview:closeButton];
        }

        [weakSelf openAd];
    }];
}

- (BOOL)enabled {
    BOOL enabled = YES;
    if ([self.delegate respondsToSelector:@selector(adMarvelEnabled)]) {
        enabled = [self.delegate adMarvelEnabled];
    }
    return enabled;
}

- (void)refreshAd {
    if (![self enabled]) {
        return;
    }
    [self.adController refreshAdWithSuccessBlock:nil];
}

- (void)refreshAdWithSuccessBlock:(GetAdSuccessBlock)successBlock {
    if (![self enabled]) {
        return;
    }

    // Only refresh if there's already an ad
    if (!self.adMarvelView) {
        return;
    }

    if ([_delegate respondsToSelector:@selector(adMarvelSiteId)]) {
        self.adController.siteId = [_delegate adMarvelSiteId];
    }

    if ([_delegate respondsToSelector:@selector(adMarvelPartnerId)]) {
        self.adController.partnerId = [_delegate adMarvelPartnerId];
    }

    if ([_delegate respondsToSelector:@selector(adMarvelViewFrame)]) {
        self.adController.frame = [_delegate adMarvelViewFrame];
    }

    [self.adController refreshAdWithSuccessBlock:successBlock];
}

- (void)openAd {
    if (!self.adMarvelView) {
        return;
    }

    if (![self enabled]) {
        [self closeAd];
        return;
    }

    if (self.hidden) {
        self.hidden = NO;
        if ([self.delegate respondsToSelector:@selector(adMarvelContainerOpened:adMarvelView:)]) {
            [self.delegate adMarvelContainerOpened:self adMarvelView:self.adMarvelView];
        }
    }
}

- (void)closeAd {
    if (!self.hidden) {
        self.hidden = YES;
        if ([self.delegate respondsToSelector:@selector(adMarvelContainerClosed:adMarvelView:)]) {
            [self.delegate adMarvelContainerClosed:self adMarvelView:self.adMarvelView];
        }
    }
}

- (BOOL)isLoaded {
    return self.adMarvelView != nil;
}

@end
