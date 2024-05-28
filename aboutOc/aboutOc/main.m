//
//  main.m
//  aboutOc
//
//  Created by yanran on 2024/5/24.
//


#import "main.h"

@implementation Fraction

-(void) print {
    NSLog(@"print");
}

-(id) init {
    self = [super init];
    if(self != nil) {
        self->denomaintor = 1;
        self->num = 1;
    }
    return self;
}

-(void) set:(int)n over:(int)d {
    self->denomaintor = d;
    self->num = n;
}

@end

int main (int argc, const char * argv[]) {
    //SampleClass *smapleClass = [[SampleClass alloc]init];
    //[SampleClass sampleMethod];
    @autoreleasepool {
        int num = 1;
        NSLog(@"%d", num);
        printf("hahah");
        
        void(^blockWithoutInputAndOutPut) (void) = ^(void) {
            NSLog(@"bruyan this is block");
        };
        
        void(^noReturn) (int) = ^(int intputNum) {
            NSLog(@"noReturn被调用！inputNum为%d", intputNum);
        };
        
        noReturn(66);
        blockWithoutInputAndOutPut();
    }
    return 0;
}
