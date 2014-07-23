//
//  ViewController.h
//  mozaiku
//
//  Created by mk on 2014/07/21.
//  Copyright (c) 2014年 mk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Image.h"

@interface ViewController : UIViewController{
    IBOutlet UIImageView *imgView;
}
-(IBAction)resize:(id)sender;
-(IBAction)check:(id)sender;
@end
