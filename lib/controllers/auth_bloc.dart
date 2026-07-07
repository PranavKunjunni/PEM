import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:pem/controllers/api_service.dart';
import 'package:pem/controllers/storage_service.dart';
import 'package:pem/controllers/auth_event.dart';
import 'package:pem/controllers/auth_state.dart';
import 'package:pem/controllers/database_helper.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiService apiService;
  final StorageService storageService;
  final DatabaseHelper databaseHelper;

  /// TEMP: while the backend (appskilltest.zybotech.in) is returning 502s,
  /// set this to true to skip the network call entirely and hardcode
  /// OTP "123456" as always valid. Set back to false once server is fixed.
  static const bool _bypassNetworkForTesting = true;

  String? _phone;
  String? _otp;
  bool _userExists = false;
  String? _pendingToken;
  String? _pendingNickname;

  bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.toLowerCase();
      return normalized == 'true' || normalized == '1';
    }
    return false;
  }

  AuthBloc({required this.apiService, required this.storageService, required this.databaseHelper}) : super(AuthInitial()) {
    on<LoadAuthRequested>(_onLoadAuthRequested);
    on<SendOtpRequested>(_onSendOtpRequested);
    on<VerifyOtpRequested>(_onVerifyOtpRequested);
    on<CreateAccountRequested>(_onCreateAccountRequested);
    on<UpdateNicknameRequested>(_onUpdateNicknameRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoadAuthRequested(LoadAuthRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final token = await storageService.getToken();
    final nickname = await storageService.getNickname();
    if (token != null && nickname != null) {
      emit(AuthAuthenticated(token: token, nickname: nickname));
    } else {
      emit(AuthInitial());
    }
  }

  Future<void> _onSendOtpRequested(SendOtpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    if (_bypassNetworkForTesting) {
      // Skip the network call entirely. Simulate a brand-new user
      // (userExists: false) so the flow goes: OTP -> nickname -> account created.
      await Future.delayed(const Duration(milliseconds: 400));

      _phone = event.phone;
      _otp = '123456';
      _userExists = false;
      _pendingToken = null;
      _pendingNickname = null;

      emit(AuthOtpSent(
        phone: event.phone,
        otp: '123456',
        userExists: false,
        nickname: null,
        token: null,
      ));
      return;
    }

    try {
      final response = await apiService.sendOtp(event.phone);
      final otp = response['otp']?.toString() ?? '';
      final userExists = _parseBool(response['user_exists']);
      final nickname = response['nickname']?.toString();
      final token = response['token']?.toString();
      _phone = event.phone;
      _otp = otp;
      _userExists = userExists;
      _pendingToken = token;
      _pendingNickname = nickname;

      emit(AuthOtpSent(
        phone: event.phone,
        otp: otp,
        userExists: userExists,
        nickname: nickname,
        token: token,
      ));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onVerifyOtpRequested(VerifyOtpRequested event, Emitter<AuthState> emit) async {
    if (_otp == null || _phone == null) {
      emit(const AuthFailure('Please request OTP again.'));
      return;
    }
    if (event.code.trim() != _otp!.trim()) {
      emit(const AuthFailure('Invalid OTP.'));
      return;
    }

    if (_userExists) {
      final token = _pendingToken;
      final nickname = _pendingNickname ?? 'User';
      if (token == null) {
        emit(const AuthFailure('Missing auth token.'));
        return;
      }
      await _resetSessionForNewUser();
      await storageService.saveToken(token);
      await storageService.saveNickname(nickname);
      emit(AuthAuthenticated(token: token, nickname: nickname));
      return;
    }

    emit(AuthNeedNickname(phone: _phone!, otp: _otp!));
  }

  Future<void> _onCreateAccountRequested(CreateAccountRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());

    if (_bypassNetworkForTesting) {
      await Future.delayed(const Duration(milliseconds: 400));
      const fakeToken = 'mock-token-123';
      await _resetSessionForNewUser();
      await storageService.saveToken(fakeToken);
      await storageService.saveNickname(event.nickname);
      emit(AuthAuthenticated(token: fakeToken, nickname: event.nickname));
      return;
    }

    try {
      if (_phone == null) {
        emit(const AuthFailure('Please request OTP again.'));
        return;
      }
      final response = await apiService.createAccount(_phone!, event.nickname);
      final token = response['token']?.toString();
      if (token == null) {
        emit(const AuthFailure('Failed to create account.'));
        return;
      }
      await _resetSessionForNewUser();
      await storageService.saveToken(token);
      await storageService.saveNickname(event.nickname);
      emit(AuthAuthenticated(token: token, nickname: event.nickname));
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  Future<void> _onUpdateNicknameRequested(UpdateNicknameRequested event, Emitter<AuthState> emit) async {
    final currentState = state;
    if (currentState is AuthAuthenticated) {
      await storageService.saveNickname(event.nickname);
      emit(AuthAuthenticated(token: currentState.token, nickname: event.nickname));
    }
  }

  Future<void> _resetSessionForNewUser() async {
    await databaseHelper.clearAllLocalData();
    await storageService.clearAllUserData();
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    await _resetSessionForNewUser();
    _phone = null;
    _otp = null;
    _userExists = false;
    _pendingToken = null;
    _pendingNickname = null;
    emit(AuthLoggedOut());
  }
}