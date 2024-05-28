//
//  main.h
//  aboutOc
//
//  Created by yanran on 2024/5/27.
//

#ifndef main_h
#define main_h

#import <Foundation/Foundation.h>
@interface Fraction : NSObject

#endif /* main_h */

// 成员变量
{
    @protected
    int num;
    int denomaintor;
}

- (void) setColorToRed: (float)red Green: (float)green Blue:(float)blue;

// 类方法
-(void) print;
// 多参数函数
-(id) initSetNum:(int) n over:(int) d;
-(id) init;

@end
