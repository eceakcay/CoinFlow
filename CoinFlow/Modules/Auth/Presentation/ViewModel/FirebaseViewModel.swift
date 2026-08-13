//
//  FireBaseViewModel.swift
//  CoinFlow
//
//  Created by Ece Akcay on 13.08.2026.
//

import Foundation

final class FirebaseLoginViewModel {

    enum State {
        case idle
        case loading
        case success
        case failure(String)
    }

    private let firebaseLoginUseCase: FirebaseLoginUseCase

    private var loginTask: Task<Void, Never>?

    var onStateChange: ((State) -> Void)?

    init(firebaseLoginUseCase: FirebaseLoginUseCase) {
        self.firebaseLoginUseCase = firebaseLoginUseCase
    }

    deinit {
        loginTask?.cancel()
    }

    func login(email: String?, password: String?) {
        let email = email?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        let password = password?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !email.isEmpty else {
            onStateChange?(.failure(L10n.text(.usernameRequired)))
            return
        }

        guard email.contains("@") else {
            onStateChange?(.failure(L10n.text(.validEmail)))
            return
        }

        guard !password.isEmpty else {
            onStateChange?(.failure(L10n.text(.passwordRequired)))
            return
        }

        loginTask?.cancel()
        onStateChange?(.loading)

        loginTask = Task { [weak self] in
            guard let self else { return }

            do {
                _ = try await self.firebaseLoginUseCase.execute(
                    email: email,
                    password: password
                )

                guard !Task.isCancelled else { return }

                await MainActor.run {
                    self.onStateChange?(.success)
                }

            } catch {
                guard !Task.isCancelled else { return }

                await MainActor.run {
                    self.onStateChange?(
                        .failure("Firebase hesabı bulunamadı veya şifre hatalı.")
                    )
                }
            }
        }
    }
}
