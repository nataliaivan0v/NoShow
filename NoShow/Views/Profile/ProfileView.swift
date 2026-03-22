import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel

    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var gender: String = "Prefer not to say"
    @State private var preferredClassTypes: Set<ClassType> = []
    @State private var isEditing = false
    @State private var showLogoutConfirmation = false

    let genderOptions = ["Female", "Male", "Non-binary", "Prefer not to say"]

    var body: some View {
        ZStack {
            Theme.orange.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("My Profile")
                        .font(Theme.screenTitle())
                        .foregroundColor(Theme.textPrimary)
                    Spacer()
                    Button {
                        if isEditing {
                            saveChanges()
                        }
                        isEditing.toggle()
                    } label: {
                        Text(isEditing ? "Save" : "Edit")
                            .font(Theme.buttonLabel())
                            .foregroundColor(Theme.orange)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)
                .background(Theme.white)

                ScrollView {
                    VStack(spacing: 16) {
                        // Personal info
                        profileSection("Personal Info") {
                            if isEditing {
                                profileField("First name", text: $firstName)
                                profileField("Last name", text: $lastName)
                                profileField("Email", text: $email, keyboard: .emailAddress)
                            } else {
                                profileRow("Name", value: "\(firstName) \(lastName)")
                                profileRow("Email", value: email)
                                profileRow("Phone", value: authVM.currentUser?.phoneNumber ?? "—")
                                if let dob = authVM.currentUser?.birthDate {
                                    profileRow("Birthday", value: dob.formatted(date: .abbreviated, time: .omitted))
                                }
                            }
                        }

                        // Gender
                        profileSection("Gender") {
                            if isEditing {
                                FlowLayout(spacing: 8) {
                                    ForEach(genderOptions, id: \.self) { option in
                                        Button {
                                            gender = option
                                        } label: {
                                            Text(option)
                                                .font(Theme.caption())
                                                .padding(.horizontal, 14)
                                                .padding(.vertical, 10)
                                                .background(gender == option ? Theme.orange : Color.gray.opacity(0.15))
                                                .foregroundColor(gender == option ? Theme.white : Theme.textPrimary)
                                                .cornerRadius(20)
                                        }
                                    }
                                }
                            } else {
                                Text(gender)
                                    .font(Theme.body())
                                    .foregroundColor(Theme.textPrimary)
                            }
                        }

                        // Preferred class types
                        profileSection("Favorite Class Types") {
                            if isEditing {
                                Text("Pick up to 3")
                                    .font(Theme.caption())
                                    .foregroundColor(Theme.textSecondary)

                                FlowLayout(spacing: 8) {
                                    ForEach(ClassType.allCases) { type in
                                        Button {
                                            if preferredClassTypes.contains(type) {
                                                preferredClassTypes.remove(type)
                                            } else if preferredClassTypes.count < 3 {
                                                preferredClassTypes.insert(type)
                                            }
                                        } label: {
                                            Text(type.rawValue)
                                                .font(Theme.caption())
                                                .padding(.horizontal, 14)
                                                .padding(.vertical, 10)
                                                .background(preferredClassTypes.contains(type) ? Theme.orange : Color.gray.opacity(0.15))
                                                .foregroundColor(preferredClassTypes.contains(type) ? Theme.white : Theme.textPrimary)
                                                .cornerRadius(20)
                                        }
                                    }
                                }
                            } else {
                                if preferredClassTypes.isEmpty {
                                    Text("None selected")
                                        .font(Theme.body())
                                        .foregroundColor(Theme.textSecondary)
                                } else {
                                    FlowLayout(spacing: 8) {
                                        ForEach(Array(preferredClassTypes), id: \.self) { type in
                                            Text(type.rawValue)
                                                .font(Theme.caption())
                                                .padding(.horizontal, 14)
                                                .padding(.vertical, 10)
                                                .background(Theme.orange.opacity(0.15))
                                                .foregroundColor(Theme.orange)
                                                .cornerRadius(20)
                                        }
                                    }
                                }
                            }
                        }

                        // Log out
                        Button {
                            showLogoutConfirmation = true
                        } label: {
                            Text("Log Out")
                                .font(Theme.buttonLabel())
                                .foregroundColor(.red)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Theme.cardBackground)
                                .cornerRadius(16)
                        }
                        .padding(.top, 8)
                    }
                    .padding(16)
                }
                .background(Theme.orange)
            }
        }
        .onAppear { loadUserData() }
        .alert("Log out?", isPresented: $showLogoutConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Log Out", role: .destructive) {
                Task { await authVM.signOut() }
            }
        } message: {
            Text("Are you sure you want to log out?")
        }
    }

    // MARK: - Helpers

    func loadUserData() {
        guard let user = authVM.currentUser else { return }
        firstName = user.firstName
        lastName = user.lastName
        email = user.email
        gender = user.gender
        if let prefs = user.notificationPreferences {
            preferredClassTypes = Set(prefs.classTypes.compactMap { ClassType(rawValue: $0) })
        }
    }

    func saveChanges() {
        authVM.currentUser?.firstName = firstName
        authVM.currentUser?.lastName = lastName
        authVM.currentUser?.email = email
        authVM.currentUser?.gender = gender
        authVM.currentUser?.notificationPreferences?.classTypes = preferredClassTypes.map { $0.rawValue }
    }

    func profileSection(_ title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(Theme.sectionTitle())
                .foregroundColor(Theme.textPrimary)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Theme.cardBackground)
        .cornerRadius(16)
    }

    func profileRow(_ label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(Theme.body())
                .foregroundColor(Theme.textSecondary)
            Spacer()
            Text(value)
                .font(Theme.body())
                .foregroundColor(Theme.textPrimary)
        }
    }

    func profileField(_ placeholder: String, text: Binding<String>, keyboard: UIKeyboardType = .default) -> some View {
        TextField(placeholder, text: text)
            .keyboardType(keyboard)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(10)
    }
}
