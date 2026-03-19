/// Offline-first pending sync queue — local only
/// CRDT-like: local_timestamp > server_timestamp → push local, else prompt user
class PendingSync {
  final String id;
  final String action;
  final String tableName;
  final String dataEncrypted;
  final DateTime timestamp;
  final bool conflictResolved;

  PendingSync({
    required this.id,
    required this.action,
    required this.tableName,
    required this.dataEncrypted,
    required this.timestamp,
    this.conflictResolved = false,
  });

  factory PendingSync.fromJson(Map<String, dynamic> j) => PendingSync(
        id: j['id'],
        action: j['action'],
        tableName: j['table_name'],
        dataEncrypted: j['data_encrypted'],
        timestamp: DateTime.parse(j['timestamp']),
        conflictResolved: j['conflict_resolved'] ?? false,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'action': action,
        'table_name': tableName,
        'data_encrypted': dataEncrypted,
        'timestamp': timestamp.toIso8601String(),
        'conflict_resolved': conflictResolved,
      };
}
