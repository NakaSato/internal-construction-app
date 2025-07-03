/// Generic API response wrapper for all API endpoints
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final List<String>? errors;
  final dynamic error;

  const ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
    this.error,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json)? fromJsonT,
  ) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] as String?,
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      errors: (json['errors'] as List<dynamic>?)?.cast<String>(),
      error: json['error'],
    );
  }

  Map<String, dynamic> toJson(Object? Function(T)? toJsonT) {
    return {
      'success': success,
      'message': message,
      'data': data != null && toJsonT != null ? toJsonT(data as T) : data,
      'errors': errors,
      'error': error,
    };
  }
}

/// Pagination info for paginated responses
class PaginationInfo {
  final int totalItems;
  final int totalPages;
  final int currentPage;
  final int pageSize;
  final bool hasNextPage;
  final bool hasPreviousPage;
  final PaginationLinks? links;

  const PaginationInfo({
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
    required this.pageSize,
    required this.hasNextPage,
    required this.hasPreviousPage,
    this.links,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      totalItems: json['totalItems'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      currentPage: json['currentPage'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
      hasNextPage: json['hasNextPage'] ?? false,
      hasPreviousPage: json['hasPreviousPage'] ?? false,
      links: json['links'] != null
          ? PaginationLinks.fromJson(json['links'])
          : null,
    );
  }
}

/// Pagination links for navigation
class PaginationLinks {
  final String? first;
  final String? previous;
  final String? current;
  final String? next;
  final String? last;

  const PaginationLinks({
    this.first,
    this.previous,
    this.current,
    this.next,
    this.last,
  });

  factory PaginationLinks.fromJson(Map<String, dynamic> json) {
    return PaginationLinks(
      first: json['first'] as String?,
      previous: json['previous'] as String?,
      current: json['current'] as String?,
      next: json['next'] as String?,
      last: json['last'] as String?,
    );
  }
}

/// Enhanced paged result wrapper
class EnhancedPagedResult<T> {
  final List<T>? items;
  final int totalCount;
  final int pageNumber;
  final int pageSize;
  final int totalPages;
  final String? sortBy;
  final String? sortOrder;
  final List<String>? requestedFields;
  final QueryMetadata? metadata;
  final PaginationInfo? pagination;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const EnhancedPagedResult({
    this.items,
    required this.totalCount,
    required this.pageNumber,
    required this.pageSize,
    required this.totalPages,
    this.sortBy,
    this.sortOrder,
    this.requestedFields,
    this.metadata,
    this.pagination,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory EnhancedPagedResult.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return EnhancedPagedResult<T>(
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => fromJsonT(item))
          .toList(),
      totalCount: json['totalCount'] ?? 0,
      pageNumber: json['pageNumber'] ?? 1,
      pageSize: json['pageSize'] ?? 10,
      totalPages: json['totalPages'] ?? 0,
      sortBy: json['sortBy'] as String?,
      sortOrder: json['sortOrder'] as String?,
      requestedFields: (json['requestedFields'] as List<dynamic>?)
          ?.cast<String>(),
      metadata: json['metadata'] != null
          ? QueryMetadata.fromJson(json['metadata'])
          : null,
      pagination: json['pagination'] != null
          ? PaginationInfo.fromJson(json['pagination'])
          : null,
      hasNextPage: json['hasNextPage'] ?? false,
      hasPreviousPage: json['hasPreviousPage'] ?? false,
    );
  }
}

/// Query metadata for performance and debugging
class QueryMetadata {
  final String? executionTime;
  final int? filtersApplied;
  final String? queryComplexity;
  final DateTime? queryExecutedAt;
  final String? cacheStatus;

  const QueryMetadata({
    this.executionTime,
    this.filtersApplied,
    this.queryComplexity,
    this.queryExecutedAt,
    this.cacheStatus,
  });

  factory QueryMetadata.fromJson(Map<String, dynamic> json) {
    return QueryMetadata(
      executionTime: json['executionTime'] as String?,
      filtersApplied: json['filtersApplied'] as int?,
      queryComplexity: json['queryComplexity'] as String?,
      queryExecutedAt: json['queryExecutedAt'] != null
          ? DateTime.parse(json['queryExecutedAt'])
          : null,
      cacheStatus: json['cacheStatus'] as String?,
    );
  }
}

/// Filter parameter for advanced filtering
class FilterParameter {
  final String field;
  final String operator;
  final dynamic value;

  const FilterParameter({
    required this.field,
    required this.operator,
    required this.value,
  });

  factory FilterParameter.fromJson(Map<String, dynamic> json) {
    return FilterParameter(
      field: json['field'] ?? '',
      operator: json['operator'] ?? '',
      value: json['value'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'field': field, 'operator': operator, 'value': value};
  }
}

/// Link information for HATEOAS support
class LinkDto {
  final String? rel;
  final String? href;
  final String? method;

  const LinkDto({this.rel, this.href, this.method});

  factory LinkDto.fromJson(Map<String, dynamic> json) {
    return LinkDto(
      rel: json['rel'] as String?,
      href: json['href'] as String?,
      method: json['method'] as String?,
    );
  }
}
