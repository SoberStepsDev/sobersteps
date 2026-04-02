import 'package:flutter_test/flutter_test.dart';
import 'package:sobersteps/models/community_post.dart';

void main() {
  test('CommunityPost fromJson parses defaults', () {
    final post = CommunityPost.fromJson({
      'id': 'p1',
      'user_id': 'u1',
      'category': 'wins',
      'content': 'content',
      'created_at': '2026-03-23T10:00:00.000Z',
    });

    expect(post.id, 'p1');
    expect(post.userId, 'u1');
    expect(post.category, 'wins');
    expect(post.likesCount, 0);
    expect(post.isFlagged, false);
    expect(post.flagCount, 0);
  });

  test('CommunityPost toJson keeps writeable keys only', () {
    final post = CommunityPost(
      id: 'p1',
      userId: 'u1',
      category: 'hard',
      content: 'txt',
      createdAt: DateTime.parse('2026-03-23T10:00:00.000Z'),
    );

    expect(post.toJson(), {
      'user_id': 'u1',
      'category': 'hard',
      'content': 'txt',
    });
  });
}
