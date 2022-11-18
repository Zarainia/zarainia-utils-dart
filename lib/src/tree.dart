import 'map.dart';

class TreeNode<T> {
  T entry;
  List<TreeNode<T>> children;
  bool hidden;
  int? parent_id;

  TreeNode(this.entry, {this.hidden = false, List<TreeNode<T>>? children, this.parent_id}) : children = children ?? [];

  @override
  String toString() {
    return "Node(${entry}, ${children})";
  }

  void iterate_tree_breadth_first(Function(TreeNode<T> node) func) {
    func(this);
    for (TreeNode<T> child in children) {
      child.iterate_tree_breadth_first(func);
    }
  }

  void iterate_tree_depth_first(Function(TreeNode<T> node) func) {
    for (TreeNode<T> child in children) {
      child.iterate_tree_depth_first(func);
    }
    func(this);
  }
}

extension TreeNodeListExtension<T> on List<TreeNode<T>> {
  void iterate_tree_breadth_first(Function(TreeNode<T> node) func) {
    for (TreeNode<T> root in this) {
      root.iterate_tree_breadth_first(func);
    }
  }

  void iterate_tree_depth_first(Function(TreeNode<T> node) func) {
    for (TreeNode<T> root in this) {
      root.iterate_tree_depth_first(func);
    }
  }
}

List<TreeNode<T>> trim_tree<T>(List<TreeNode<T>> roots, {bool trim_top = true}) {
  if (trim_top && roots.every((root) => root.hidden)) return roots.map((root) => trim_tree(root.children, trim_top: trim_top)).expand((children) => children).toList();

  List<TreeNode<T>> new_roots = [];
  for (TreeNode<T> root in roots) {
    if (!root.hidden || root.children.isNotEmpty) {
      new_roots.add(root);
      root.children = trim_tree(root.children, trim_top: false);
    }
  }
  return new_roots;
}

List<TreeNode<T>> trim_unambiguous<T>(List<TreeNode<T>> roots) {
  roots = roots.where((root) => !root.hidden).toList();

  for (TreeNode<T> node in roots) node.children = trim_unambiguous(node.children);

  if (roots.length == 1 && roots[0].children.where((child) => !child.hidden).isNotEmpty)
    return roots[0].children;
  else {
    return roots.map((root) {
      if (root.children.length == 1 && root.children[0].children.isEmpty) return root.children[0];
      return root;
    }).toList();
  }
}

List<TreeNode<T>> build_tree<T>({
  required Iterable<T> list,
  required int Function(T) get_id,
  required Set<int> Function(T entry) get_parent_ids,
  int? Function(T entry, int parent_id)? get_selected_ancestor,
}) {
  DefaultMap<int, List<TreeNode<T>>> processed = DefaultMap<int, List<TreeNode<T>>>(() => []);
  List<TreeNode<T>> roots = [];
  DefaultMap<int, List<TreeNode<T>>> awaiting_links = DefaultMap<int, List<TreeNode<T>>>(() => []);

  for (T entry in list) {
    Set<int> parent_ids = get_parent_ids(entry);
    int identifier = get_id(entry);
    if (parent_ids.isEmpty) {
      TreeNode<T> node = TreeNode(entry, children: awaiting_links[identifier]);
      roots.add(node);
      processed[identifier].add(node);
    } else {
      for (int parent_id in parent_ids) {
        List<TreeNode<T>> parent_children = awaiting_links[identifier];
        if (parent_ids.length > 1)
          parent_children = parent_children.where((child) {
            int? selected_ancestor = get_selected_ancestor?.call(child.entry, identifier);
            return selected_ancestor == null || selected_ancestor == parent_id;
          }).toList();
        TreeNode<T> node = TreeNode(entry, children: parent_children, parent_id: parent_id);
        if (processed[parent_id].isNotEmpty) {
          Iterable<TreeNode<T>> parents_to_add_to = processed[parent_id];
          int? selected_ancestor = get_selected_ancestor?.call(entry, parent_id);
          if (processed[parent_id].length > 1 && selected_ancestor != null) {
            parents_to_add_to = parents_to_add_to.where((parent_node) => parent_node.parent_id == selected_ancestor);
          }
          for (TreeNode<T> parent in parents_to_add_to) parent.children.add(node);
        } else
          awaiting_links[parent_id].add(node);

        processed[identifier].add(node);
      }
    }
    awaiting_links.remove(identifier);
  }

  for (List<TreeNode<T>> nodes in awaiting_links.values) roots.addAll(nodes);
  roots = trim_tree(roots);

  return roots;
}
