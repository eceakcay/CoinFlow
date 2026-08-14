//
//  FirebaseLoginViewModel.swift
//  CoinFlow
//
//  Created by Ece Akcay on 13.08.2026.
//

import Foundation

final class FirebaseLoginViewModel {

    // MARK: - State

    enum State {
        case idle
        case loading
        case success
        case failure(String)
    }

    // MARK: - Properties

    private let firebaseLoginUseCase: FirebaseLoginUseCase

    private var loginTask: Task<Void, Never>?

    var onStateChange: ((State) -> Void)?

    // MARK: - Init

    init(firebaseLoginUseCase: FirebaseLoginUseCase) {
        self.firebaseLoginUseCase = firebaseLoginUseCase
    }

    deinit {
        loginTask?.cancel()
    }

    // MARK: - Login

    func login(
        email: String?,
        password: String?
    ) {

        let email = email?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        let password = password?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !email.isEmpty else {
            onStateChange?(
                .failure(L10n.text(.usernameRequired))
            )
            return
        }

        guard isValidEmail(email) else {
            onStateChange?(
                .failure(L10n.text(.validEmail))
            )
            return
        }

        guard !password.isEmpty else {
            onStateChange?(
                .failure(L10n.text(.passwordRequired))
            )
            return
        }

        loginTask?.cancel()

        onStateChange?(.loading)

        loginTask = Task { [weak self] in
            guard let self else { return }

            do {

                _ = try await firebaseLoginUseCase.execute(
                    email: email,
                    password: password
                )

                guard !Task.isCancelled else {
                    return
                }

                await MainActor.run {
                    self.onStateChange?(.success)
                }

            } catch {

                guard !Task.isCancelled else {
                    return
                }

                let message = loginErrorMessage(
                    for: error
                )

                await MainActor.run {
                    self.onStateChange?(
                        .failure(message)
                    )
                }
            }
        }
    }

    // MARK: - Helpers

    private func isValidEmail(_ email: String) -> Bool {

        let pattern =
        #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#

        return email.range(
            of: pattern,
            options: .regularExpression
        ) != nil
    }

    private func loginErrorMessage(
        for error: Error
    ) -> String {

        guard let loginError = error as? FirebaseLoginError else {
            return L10n.text(.firebaseLoginFailed)
        }

        switch loginError {

        case .invalidEmail:
            return L10n.text(.validEmail)

        case .wrongPassword,
             .userNotFound,
             .invalidCredential:
            return L10n.text(.invalidCredentials)

        case .userDisabled:
            return L10n.text(.userDisabled)

        case .networkError:
            return L10n.text(.networkError)

        case .tooManyRequests:
            return L10n.text(.tooManyRequests)

        case .unknown:
            return L10n.text(.firebaseLoginFailed)
        }
    }
}
