class LeaveActionRequest {
  final String? remarks;

  const LeaveActionRequest({
    this.remarks,
  });

  Map<String, dynamic> toJson() {
    return {
      'remarks': remarks,
      'comment': remarks,
    };
  }
}