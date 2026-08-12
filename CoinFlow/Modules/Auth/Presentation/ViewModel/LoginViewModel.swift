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
    private var loginTask: Task<Void, Never>?

    var onStateChange: ((State) -> Void)?

    // MARK: - Init

    init(loginUseCase: LoginUseCase) {
        self.loginUseCase = loginUseCase
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
