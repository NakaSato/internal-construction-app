import 'package:equatable/equatable.dart';

/// Represents pagination information for notification lists
class NotificationPagination extends Equatable {
  /// Current page number (1-based)
  final int page;

  /// Number of items per page
  final int pageSize;

  /// Total number of items across all pages
  final int totalCount;

  /// Total number of pages
  final int totalPages;

  const NotificationPagination({
    required this.page,
    required this.pageSize,
    required this.totalCount,
    required this.totalPages,
  });

  /// Whether there's a next page
  bool get hasNextPage => page < totalPages;

  /// Whether there's a previous page
  bool get hasPreviousPage => page > 1;

  /// Next page number (if available)
  int? get nextPage => hasNextPage ? page + 1 : null;

  /// Previous page number (if available)
  int? get previousPage => hasPreviousPage ? page - 1 : null;

  /// Starting item number for current page
  int get startItem => totalCount > 0 ? (page - 1) * pageSize + 1 : 0;

  /// Ending item number for current page
  int get endItem {
    final calculatedEnd = page * pageSize;
    return calculatedEnd > totalCount ? totalCount : calculatedEnd;
  }

  /// Whether this is the first page
  bool get isFirstPage => page == 1;

  /// Whether this is the last page
  bool get isLastPage => page == totalPages;

  @override
  List<Object?> get props => [page, pageSize, totalCount, totalPages];
}
