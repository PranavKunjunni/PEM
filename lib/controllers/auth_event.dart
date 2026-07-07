import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoadAuthRequested extends AuthEvent {}

class SendOtpRequested extends AuthEvent {
  final String phone;

  const SendOtpRequested(this.phone);

  @override
  List<Object?> get props => [phone];
}

class VerifyOtpRequested extends AuthEvent {
  final String code;

  const VerifyOtpRequested(this.code);

  @override
  List<Object?> get props => [code];
}

class CreateAccountRequested extends AuthEvent {
  final String nickname;

  const CreateAccountRequested({required this.nickname});

  @override
  List<Object?> get props => [nickname];
}

class UpdateNicknameRequested extends AuthEvent {
  final String nickname;

  const UpdateNicknameRequested(this.nickname);

  @override
  List<Object?> get props => [nickname];
}

class LogoutRequested extends AuthEvent {}