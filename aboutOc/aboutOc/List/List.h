//
//  List.h
//  aboutOc
//
//  Created by yanran on 2024/5/28.
//

#ifndef List_h
#define List_h


@interface Node : NSObject

// 根据数组生成一个链表
+ (Node *)nodeWithArray:(NSArray *)array;
 
@property (nonatomic, assign) int data;
@property (nonatomic, strong) Node *next;
@property (nonatomic, strong) Node *sibling;/// 随机的一个节点
 
@end

#endif /* List_h */
