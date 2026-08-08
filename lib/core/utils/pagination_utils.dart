class PaginationParams {
  final int page;
  final int pageSize;

  const PaginationParams({this.page = 0, this.pageSize = 20});

  int get from => page * pageSize;
  int get to => from + pageSize - 1;

  PaginationParams nextPage() => PaginationParams(page: page + 1, pageSize: pageSize);
}

class PaginatedResult<T> {
  final List<T> items;
  final int totalCount;
  final bool hasMore;

  const PaginatedResult({required this.items, required this.totalCount, required this.hasMore});
}