//
//  LoginViewModel.swift
//  CoinFlow
//
//  Created by Ece Akcay on 12.08.2026.
//

import Foundation

final class LoginViewModel {

    enum State {
        case idle
        case loading
        case success
        case failure(String)
    }

    // MARK: - Properties

    private let loginUseCase: LoginUseCase
    private let checkAuthStatusUseCase: CheckAuthStatusUseCase
    private let authenticateWithBiometricsUseCase: AuthenticateWithBiometricsUseCase
    private let userDefaultsManager: UserDefaultsManager

    private var loginTask: Task<Void, Never>?

    var onStateChange: ((State) -> Void)?

    var shouldShowFaceIDButton: Bool {
        let isLoggedIn = checkAuthStatusUseCase.execute()
        let isBiometricEnabled = userDefaultsManager.isBiometricEnabled

        print("Token var mı:", isLoggedIn)
        print("Biometric açık mı:", isBiometricEnabled)

        return isLoggedIn && isBiometricEnabled
    }

    // MARK: - Init

    init(
        loginUseCase: LoginUseCase,
        checkAuthStatusUseCase: CheckAuthStatusUseCase,
        authenticateWithBiometricsUseCase: AuthenticateWithBiometricsUseCase,
        userDefaultsManager: UserDefaultsManager
    ) {
        self.loginUseCase = loginUseCase
        self.checkAuthStatusUseCase = checkAuthStatusUseCase
        self.authenticateWithBiometricsUseCase = authenticateWithBiometricsUseCase
        self.userDefaultsManager = userDefaultsManager
    }

    deinit {
        loginTask?.cancel()
    }

    // MARK: - Login

    func login(username: String?, password: String?) {
        let trimmedUsername = username?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        let trimmedPassword = password?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !trimmedUsername.isEmpty else {
            onStateChange?(.failure(L10n.text(.usernameRequired)))
            return
        }

        guard !trimmedPassword.isEmpty else {
            onStateChange?(.failure(L10n.text(.passwordRequired)))
            return
        }

        loginTask?.cancel()
        onStateChange?(.loading)

        loginTask = Task { [weak self] in
            guard let self else { return }

            do {
                _ = try await self.loginUseCase.execute(
                    username: trimmedUsername,
                    password: trimmedPassword
                )

                guard !Task.isCancelled else { return }

                await MainActor.run {
                    self.onStateChange?(.success)
                }

            } catch let authError as AuthError {
                guard !Task.isCancelled else { return }

                await MainActor.run {
                    self.onStateChange?(
                        .failure(self.makeErrorMessage(from: authError))
                    )
                }

            } catch {
                guard !Task.isCancelled else { return }

                await MainActor.run {
                    self.onStateChange?(
                        .failure(L10n.text(.loginFailedMessage))
                    )
                }
            }
        }
    }

    // MARK: - Face ID

    func loginWithFaceID() {
        guard checkAuthStatusUseCase.execute() else {
            onStateChange?(.failure(L10n.text(.signInBeforeFaceID)))
            return
        }

        guard userDefaultsManager.isBiometricEnabled else {
            onStateChange?(.failure(L10n.text(.biometricNotEnabled)))
            return
        }

        loginTask?.cancel()
        onStateChange?(.loading)

        loginTask = Task { [weak self] in
            guard let self else { return }

            do {
                let isAuthenticated = try await self.authenticateWithBiometricsUseCase.execute(
                    reason: L10n.text(.faceIDReason)
                )

                guard !Task.isCancelled else { return }

                await MainActor.run {
                    if isAuthenticated {
                        self.onStateChange?(.success)
                    } else {
                        self.onStateChange?(.failure(L10n.text(.faceIDFailed)))
                    }
                }

            } catch let biometricError as BiometricAuthError {
                guard !Task.isCancelled else { return }

                await MainActor.run {
                    switch biometricError {
                    case .cancelled:
                        self.onStateChange?(.idle)

                    case .notAvailable:
                        self.onStateChange?(.failure(L10n.text(.faceIDNotAvailable)))

                    case .notEnrolled:
                        self.onStateChange?(.failure(L10n.text(.faceIDNotEnrolled)))

                    case .failed:
                        self.onStateChange?(.failure(L10n.text(.faceIDFailed)))
                    }
                }

            } catch {
                guard !Task.isCancelled else { return }

                await MainActor.run {
                    self.onStateChange?(.failure(L10n.text(.faceIDFailed)))
                }
            }
        }
    }

    // MARK: - Error Mapping

    private func makeErrorMessage(from error: AuthError) -> String {
        switch error {
        case .invalidCredentials:
            return L10n.text(.invalidCredentials)

        case .keychainSaveFailed:
            return L10n.text(.loginFailedMessage)

        case .logoutFailed:
            return L10n.text(.loginFailedMessage)

        case .loginFailed:
            return L10n.text(.loginFailedMessage)

        case .unknown:
            return L10n.text(.loginFailedMessage)
        }
    }
}
