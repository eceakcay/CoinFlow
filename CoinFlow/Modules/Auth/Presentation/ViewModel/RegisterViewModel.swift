//
//  RegisterViewModel.swift
//  CoinFlow
//
//  Created by Ece Akcay on 13.08.2026.
//

import Foundation

final class RegisterViewModel {

    enum State {
        case idle
        case loading
        case success
        case failure(String)
    }

    private let firebaseRegisterUseCase: FirebaseRegisterUseCase

    var onStateChange: ((State) -> Void)?

    private var registerTask: Task<Void, Never>?

    init(firebaseRegisterUseCase: FirebaseRegisterUseCase) {
        self.firebaseRegisterUseCase = firebaseRegisterUseCase
    }

    deinit {
        registerTask?.cancel()
    }

    func register(email: String?, password: String?) {
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

        registerTask?.cancel()
        onStateChange?(.loading)

        registerTask = Task { [weak self] in
            guard let self else { return }

            do {
                _ = try await self.firebaseRegisterUseCase.execute(
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
                        .failure(L10n.text(.firebaseRegisterFailed))
                    )
                }
            }
        }
    }
}
