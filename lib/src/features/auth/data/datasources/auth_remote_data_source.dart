import 'package:dio/dio.dart';

import '../../../../core/api/api_client.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  Future<(UserModel, String)> login({
    required String email,
    required String password,
  }) async {
    // TODO: Replace with real API endpoint.
    final response = await Future<Response<Map<String, dynamic>>>(() async {
      await Future.delayed(const Duration(milliseconds: 400));
      return Response(
        requestOptions: RequestOptions(path: '/auth/login'),
        data: {
          'token': 'mock-token-${DateTime.now().millisecondsSinceEpoch}',
          'user': {
            'id': 'user-1',
            'name': 'Musayyer Operator',
            'email': email,
          },
        },
        statusCode: 200,
      );
    });

    final data = response.data ?? {};
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    final token = data['token'] as String;
    return (user, token);
  }
}
