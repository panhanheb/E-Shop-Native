import SwiftUI

/// Modal editor for the user's profile.
struct EditProfileView: View {
    /// Shared with `ProfileView`.
    @Bindable var viewModel: ProfileViewModel

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    AvatarView(name: viewModel.draftName, size: 88)
                        .frame(maxWidth: .infinity)
                        .animation(.default, value: viewModel.draftName)
                }
                .listRowBackground(Color.clear)

                Section("Name") {
                    TextField("Full Name", text: $viewModel.draftName)
                        .textContentType(.name)
                        .submitLabel(.done)
                }

                if let errorMessage = viewModel.errorMessage {
                    Section {
                        ErrorBanner(message: errorMessage)
                    }
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppColors.background)
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { viewModel.cancelEditing() }
                        .disabled(viewModel.isSaving)
                }
                ToolbarItem(placement: .confirmationAction) {
                    if viewModel.isSaving {
                        ProgressView()
                    } else {
                        Button("Save") {
                            Task { await viewModel.saveProfile() }
                        }
                        .disabled(!viewModel.canSaveProfile)
                    }
                }
            }
            .interactiveDismissDisabled(viewModel.isSaving)
        }
    }
}

#Preview {
    let viewModel = ProfileViewModel(
        user: .mock,
        profileService: MockProfileService(database: MockUserDatabase(signedInUser: .mock), latency: .zero),
        onProfileUpdated: { _ in },
        onSignOut: {}
    )
    EditProfileView(viewModel: viewModel)
        .onAppear { viewModel.beginEditing() }
}
