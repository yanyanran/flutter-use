class Node {
  int value;
  List<Node> children;

  Node(this.value) : children = [];
}

Object buildTree(List<int> levels) {
  Map<int, Node> nodeMap = {};
  List<Node> rootNodes = [];

  // 创建所有节点并存储在映射中
  levels.forEach((value) {
    nodeMap[value] = Node(value);
  });

  // 构建节点之间的父子关系
  levels.forEach((value) {
    Node? currentNode = nodeMap[value];
    int parentValue = value ~/ 10; // 假设父节点的值是当前节点值除以10的整数部分

    if (parentValue != 0 && nodeMap.containsKey(parentValue)) {
      nodeMap[parentValue]?.children.add(currentNode!);
    } else {
      rootNodes.add(currentNode!); // 如果没有父节点，或者是根节点
    }
  });

  // 返回根节点列表（可能有多个根节点）
  return rootNodes.length == 1 ? rootNodes.first : rootNodes;
}

void main() {
  List<int> levels = [
    90, 16, 16, 16, 42, 16, 16, 56, 76, 77, 85, 90, 92, 93, 96, 76, 16, 99, 100, 16
  ];

  Object tree = buildTree(levels);

  // 打印树结构（简单示例）
  void printTree(Node node, {int indent = 0}) {
    print(' ' * indent + node.value);
    node.children.forEach((child) => printTree(child, indent: indent + 2));
  }

  printTree(tree);
}