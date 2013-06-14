//
//  FFGame.h
//  Flip4Friends
//
//  Created by Matthias Schicker on 6/14/13.
//  Copyright (c) 2013 FlippyFriends. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FFBoard;

@interface FFGame : NSObject

@property (nonatomic, strong, readonly) FFBoard *Board;
@property(nonatomic, copy, readonly) NSString *Id;

@end
