import SwiftUI
import UIKit

struct SettingsSheetView: View {
    @ObservedObject var viewModel: SessionViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        SettingsViewControllerRepresentable(
            initialSettings: viewModel.settings,
            onSave: { updatedSettings in
                viewModel.updateSettings(updatedSettings)
                dismiss()
            },
            onCancel: {
                dismiss()
            }
        )
        .ignoresSafeArea()
    }
}

private struct SettingsViewControllerRepresentable: UIViewControllerRepresentable {
    let initialSettings: AppSettings
    let onSave: (AppSettings) -> Void
    let onCancel: () -> Void

    func makeUIViewController(context: Context) -> UINavigationController {
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        guard let settingsViewController = storyboard.instantiateInitialViewController() as? SettingsViewController else {
            fatalError("Settings storyboard is not configured with SettingsViewController as the initial view controller.")
        }

        settingsViewController.initialSettings = initialSettings
        settingsViewController.onSave = onSave
        settingsViewController.onCancel = onCancel

        let navigationController = UINavigationController(rootViewController: settingsViewController)
        navigationController.modalPresentationStyle = .formSheet
        return navigationController
    }

    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
    }
}
