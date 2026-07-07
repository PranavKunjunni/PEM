import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthOtpSent extends AuthState {
  final String phone;
  final String otp;
  final bool userExists;
  final String? nickname;
  final String? token;

  const AuthOtpSent({
    required this.phone,
    required this.otp,
    required this.userExists,
    this.nickname,
    this.token,
  });

  @override
  List<Object?> get props => [phone, otp, userExists, nickname, token];
}

class AuthNeedNickname extends AuthState {
  final String phone;
  final String otp;

  const AuthNeedNickname({required this.phone, required this.otp});

  @override
  List<Object?> get props => [phone, otp];
}

class AuthAuthenticated extends AuthState {
  final String token;
  final String nickname;

  const AuthAuthenticated({required this.token, required this.nickname});

  @override
  List<Object?> get props => [token, nickname];
}

class AuthFailure extends AuthState {
  final String error;

  const AuthFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class AuthLoggedOut extends AuthState {}
