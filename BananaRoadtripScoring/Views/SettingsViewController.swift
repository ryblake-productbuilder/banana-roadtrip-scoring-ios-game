import UIKit

final class SettingsViewController: UIViewController {
    @IBOutlet private weak var pointsButton: UIButton!
    @IBOutlet private weak var saveButton: UIButton!
    @IBOutlet private weak var cancelButton: UIButton!

    var initialSettings: AppSettings = .default()
    var onSave: ((AppSettings) -> Void)?
    var onCancel: (() -> Void)?

    private var draftSettings: AppSettings = .default()

    override func viewDidLoad() {
        super.viewDidLoad()

        draftSettings = initialSettings
        configureView()
    }

    private func configureView() {
        title = "Settings"

        view.backgroundColor = UIColor(red: 1.0, green: 0.98, blue: 0.86, alpha: 1.0)

        if var configuration = pointsButton.configuration {
            configuration.title = "\(draftSettings.pinkALiciousPoints)"
            configuration.cornerStyle = .capsule
            configuration.baseBackgroundColor = .systemOrange
            configuration.baseForegroundColor = .white
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10)
            pointsButton.configuration = configuration
        }
        pointsButton.showsMenuAsPrimaryAction = false
        pointsButton.addAction(UIAction { [weak self] _ in
            self?.presentPointsPicker()
        }, for: .touchUpInside)

        saveButton.layer.cornerRadius = 14
        cancelButton.layer.cornerRadius = 14

        updatePrimaryButtonTitle()
    }

    private func presentPointsPicker() {
        let pickerViewController = PointsPickerViewController(
            values: Array(0...20),
            selectedValue: draftSettings.pinkALiciousPoints
        )

        let alertController = UIAlertController(title: "Pink-a-licious Points", message: nil, preferredStyle: .alert)
        alertController.setValue(pickerViewController, forKey: "contentViewController")
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.addAction(UIAlertAction(title: "Done", style: .default) { [weak self, weak pickerViewController] _ in
            guard let self, let selectedValue = pickerViewController?.selectedValue else { return }
            draftSettings.pinkALiciousPoints = selectedValue
            pointsButton.configuration?.title = "\(selectedValue)"
            updatePrimaryButtonTitle()
        })

        present(alertController, animated: true)
    }

    private func updatePrimaryButtonTitle() {
        let title = draftSettings == initialSettings ? "Done" : "Save"
        saveButton.configuration?.title = title
        saveButton.setTitle(title, for: .normal)
    }

    @IBAction private func saveTapped(_ sender: UIButton) {
        onSave?(draftSettings)
    }

    @IBAction private func cancelTapped(_ sender: UIButton) {
        onCancel?()
    }
}

private final class PointsPickerViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    let values: [Int]
    var selectedValue: Int

    private let pickerView = UIPickerView()

    init(values: [Int], selectedValue: Int) {
        self.values = values
        self.selectedValue = selectedValue
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        preferredContentSize = CGSize(width: 220, height: 140)
        view.backgroundColor = .clear

        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.dataSource = self
        pickerView.delegate = self
        view.addSubview(pickerView)

        NSLayoutConstraint.activate([
            pickerView.topAnchor.constraint(equalTo: view.topAnchor),
            pickerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pickerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pickerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        if let selectedIndex = values.firstIndex(of: selectedValue) {
            pickerView.selectRow(selectedIndex, inComponent: 0, animated: false)
        }
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        values.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        "\(values[row])"
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedValue = values[row]
    }
}
