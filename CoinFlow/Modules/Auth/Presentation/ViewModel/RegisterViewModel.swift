//
//  RegisterViewModel.swift
//  CoinFlow
//
//  Created by Ece Akcay on 13.08.2026.
//

import Foundation

final class RegisterViewModel {

    // MARK: - State

    enum State {
        case idle
        case loading
        case success
        case failure(String)
    }
    
    // MARK: - Properties

    private let firebaseRegisterUseCase: FirebaseRegisterUseCase

    var onStateChange: ((State) -> Void)?

    private var registerTask: Task<Void, Never>?

    // MARK: - Init

    init(firebaseRegisterUseCase: FirebaseRegisterUseCase) {
        self.firebaseRegisterUseCase = firebaseRegisterUseCase
    }

    deinit {
        registerTask?.cancel()
    }

    
    // MARK: - Register

    func register(
        firstName: String?,
        lastName: String?,
        email: String?,
        password: String?
    ) {
        let firstName = firstName?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        let lastName = lastName?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        let email = email?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        let password = password?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !firstName.isEmpty else {
            onStateChange?(.failure(L10n.text(.firstNameRequired)))
            return
        }

        guard !lastName.isEmpty else {
            onStateChange?(.failure(L10n.text(.lastNameRequired)))
            return
        }

        guard !email.isEmpty else {
            onStateChange?(.failure(L10n.text(.usernameRequired)))
            return
        }

        guard isValidEmail(email) else {
            onStateChange?(.failure(L10n.text(.validEmail)))
            return
        }

        guard !password.isEmpty else {
            onStateChange?(.failure(L10n.text(.passwordRequired)))
            return
        }

        guard password.count >= 6 else {
            onStateChange?(.failure(L10n.text(.weakPassword)))
            return
        }
        
        registerTask?.cancel()
        onStateChange?(.loading)

        registerTask = Task { [weak self] in
            guard let self else { return }

            do {
                _ = try await self.firebaseRegisterUseCase.execute(
                    firstName: firstName,
                    lastName: lastName,
                    email: email,
                    password: password
                )

                guard !Task.isCancelled else { return }

                await MainActor.run {
                    self.onStateChange?(.success)
                }

            } catch {
                guard !Task.isCancelled else { return }

                let message = self.registrationErrorMessage(for: error)

                await MainActor.run {
                    self.onStateChange?(
                        .failure(message)
                    )
                }
            }
        }
    }
    
    //MARK: - Helper
    
    private func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#

        return email.range(of: pattern, options: .regularExpression) != nil
    }
    
    private func registrationErrorMessage(for error: Error) -> String {

        guard let registrationError = error as? RegistrationError else {
            return L10n.text(.firebaseRegisterFailed)
        }

        switch registrationError {

        case .emailAlreadyInUse:
            return L10n.text(.emailAlreadyInUse)

        case .invalidEmail:
            return L10n.text(.validEmail)

        case .weakPassword:
            return L10n.text(.weakPassword)

        case .networkError:
            return L10n.text(.networkError)

        case .tooManyRequests:
            return L10n.text(.tooManyRequests)

        case .operationNotAllowed:
            return L10n.text(.registrationNotAllowed)

        case .unknown:
            return L10n.text(.firebaseRegisterFailed)
        }
    }
}
