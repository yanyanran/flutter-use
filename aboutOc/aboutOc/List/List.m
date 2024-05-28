//
//  List.m
//  aboutOc
//
//  Created by yanran on 2024/5/28.
//

#import <Foundation/Foundation.h>
#import "List.h"

- (void)viewDidLoad {
   [super viewDidLoad];
   [self copyNode];
   
}

- (void)copyNode {

   Node * root = [Node nodeWithArray:@[@(1),@(2),@(3),@(4),@(5),]];

   NSMutableArray<Node *> * array = [NSMutableArray array];
   Node * temp = root;
   while (temp) {
       [array addObject:temp];
       temp = temp.next;
   }
   root.sibling = array[2];
   array[1].sibling = array.lastObject;
   array[3].sibling = array[1];
   
   // 复制这个root链表, 生成一个全新的,但是一样的链表,类似于数组的深拷贝
   // 1.在原始节点后面生成一个一模一样的节点, A->a->B->b->....->F->f
   // 2.把a.sibling = A.sibling.next;
   // 3.把下标为奇数的拆出成一个新链表
   NSLog(@"原始链表root  %@",root);
   
   temp = root;
   // 1.处理原始链表,生成一个这样的结构,A->a->B->b->....->F->f
   while (temp) {
       
       Node * newNode = [[Node alloc] init];
       newNode.data = temp.data;
       newNode.next = temp.next;
       temp.next = newNode;
       
       temp = newNode.next;
   }
   NSLog(@"第一步root  %@",root);
   
   
   // 2.next指针处理好了, 处理sibling指针了
   temp = root;
   // 处理对应的a.sibling = A.sibling.next
   while (temp) {
       
       Node * copyNode = temp.next;
       copyNode.sibling = temp.sibling.next;
       temp = copyNode.next;
   }
   NSLog(@"第二步root  %@",root);
   
   // 3.把下标为奇数的拆出成新链表,原始链表复原
   Node * result = root.next;
   Node * resultTemp = nil;

   temp = root;
   while (temp) {
       
       Node * copyNode = temp.next;
       resultTemp.next = copyNode;

       resultTemp = copyNode;
       
       // 原始链表复原,A->B->C->D->...
       temp.next = copyNode.next;
       temp = copyNode.next;
       
   }
   NSLog(@"第三步root  %@",root);
   NSLog(@"第三步result  %@",result);

}
 
@implementation Node
 
+ (Node *)nodeWithArray:(NSArray *)array {
    
    if (array.count==0) {
        return nil;
    }
    
    Node * first = [[Node alloc] init];
    first.data = [array.firstObject intValue];
    Node * preNode = first;
    for (int i = 1; i<array.count; i++) {
        Node * next = [[Node alloc] init];
        next.data = [array[i] intValue];
        preNode.next = next;
        preNode = next;
    }
    return first;
}
 
- (NSString *)description {
    return [NSString stringWithFormat:@"原始值:%d 下标值:%d  %@",self.data,self.sibling.data,self.next];
}
 
@end
