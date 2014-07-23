//
//  Image.h
//  mozaiku
//
//  Created by mk on 2014/07/21.
//  Copyright (c) 2014年 mk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Image : UIImage

+ (UIImage *)mask:(UIImage *)image withMask:(UIImage *)maskImage;
+ (UIImage *)resize:(UIImage *)image rect:(CGRect)rect;
+ (UIImage *)getUIImageFromResources:(NSString*)fileName ext:(NSString*)ext;

@end
