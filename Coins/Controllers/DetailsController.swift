import UIKit

class DetailsController: UIViewController {
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "bg"))
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private lazy var backButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(named: "back"), for: .normal)
        view.addTarget(self, action: #selector(backTap), for: .touchUpInside)

        return view
    }()

    private let titleLabel: UILabel = {
        let view = UILabel()
        view.textColor = .white
        view.font = UIFont(name: "SF Pro Text Semibold", size: 24)

        return view
    }()

    private let priceLabel: UILabel = {
        let view = UILabel()
        view.textColor = .white
        view.font = UIFont(name: "SFProText-Regular", size: 24)

        return view
    }()

    private let hourLabel: UILabel = {
        let view = UILabel()
        view.textColor = .white
        view.font = UIFont(name: "SFProText-Regular", size: 14)

        return view
    }()

    private let stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 6
        view.distribution = .fillProportionally
        view.alignment = .center

        return view
    }()

    private let stackViewVer1: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 2
        view.distribution = .fillEqually
        view.alignment = .center

        return view
    }()

    private let stackViewVer2: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 2
        view.distribution = .fillEqually
        view.alignment = .center

        return view
    }()

    private let stackViewVer3: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.spacing = 2
        view.distribution = .fillEqually
        view.alignment = .center

        return view
    }()

    private let titleMarketLabel: UILabel = {
        let view = UILabel()
        view.text = "title1".localize()
        view.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        view.font = UIFont(name: "SFProText-Regular", size: 12)
        view.textAlignment = .left

        return view
    }()

    private let titleSupplyLabel: UILabel = {
        let view = UILabel()
        view.text = "title2".localize()
        view.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        view.font = UIFont(name: "SFProText-Regular", size: 12)
        view.textAlignment = .center

        return view
    }()

    private let titleVolLabel: UILabel = {
        let view = UILabel()
        view.text = "title3".localize()
        view.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        view.font = UIFont(name: "SFProText-Regular", size: 12)
        view.textAlignment = .right

        return view
    }()

    private let valMarketLabel: UILabel = {
        let view = UILabel()
        view.textColor = .white
        view.font = UIFont(name: "SFProText-Regular", size: 16)
        view.textAlignment = .left

        return view
    }()

    private let valSupplyLabel: UILabel = {
        let view = UILabel()
        view.textColor = .white
        view.font = UIFont(name: "SFProText-Regular", size: 16)
        view.textAlignment = .center

        return view
    }()

    private let valVolLabel: UILabel = {
        let view = UILabel()
        view.textColor = .white
        view.font = UIFont(name: "SFProText-Regular", size: 16)
        view.textAlignment = .left

        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    private func setupViews() {
        backButton.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        priceLabel.translatesAutoresizingMaskIntoConstraints = false
        hourLabel.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        valMarketLabel.translatesAutoresizingMaskIntoConstraints = false
        valSupplyLabel.translatesAutoresizingMaskIntoConstraints = false
        valVolLabel.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        stackViewVer1.translatesAutoresizingMaskIntoConstraints = false
        stackViewVer2.translatesAutoresizingMaskIntoConstraints = false
        stackViewVer3.translatesAutoresizingMaskIntoConstraints = false

        view.addSubviews(backgroundImageView, backButton, titleLabel, priceLabel, hourLabel, stackView, valMarketLabel, valSupplyLabel, valVolLabel)
        stackViewVer1.addArrangedSubview(titleMarketLabel)
        stackViewVer1.addArrangedSubview(valMarketLabel)
        stackViewVer2.addArrangedSubview(titleSupplyLabel)
        stackViewVer2.addArrangedSubview(valSupplyLabel)
        stackViewVer3.addArrangedSubview(titleVolLabel)
        stackViewVer3.addArrangedSubview(valVolLabel)
        stackView.addArrangedSubview(stackViewVer1)
        stackView.addArrangedSubview(stackViewVer2)
        stackView.addArrangedSubview(stackViewVer3)

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            backButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40),

            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 16),

            priceLabel.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 32),
            priceLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            hourLabel.centerYAnchor.constraint(equalTo: priceLabel.centerYAnchor),
            hourLabel.leadingAnchor.constraint(equalTo: priceLabel.trailingAnchor, constant: 10),

            stackView.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),

            valMarketLabel.topAnchor.constraint(equalTo: titleMarketLabel.bottomAnchor, constant: 2),
            valMarketLabel.centerXAnchor.constraint(equalTo: titleMarketLabel.centerXAnchor),

            valSupplyLabel.topAnchor.constraint(equalTo: titleSupplyLabel.bottomAnchor, constant: 2),
            valSupplyLabel.centerXAnchor.constraint(equalTo: titleSupplyLabel.centerXAnchor),

            valVolLabel.topAnchor.constraint(equalTo: titleVolLabel.bottomAnchor, constant: 2),
            valVolLabel.centerXAnchor.constraint(equalTo: titleVolLabel.centerXAnchor),
        ])
    }
}

private extension DetailsController {
    @objc func backTap() {
        dismiss(animated: false)
    }
}

extension DetailsController: CoinsControllerDelegate {
    func didSelectCoin(name: String, symbol: String, priceUsd: String, changePercent24Hr: String, market: String, supply: String, vol: String) {
        titleLabel.text = name

        guard let priceUsdValue = Double(priceUsd),
              let changePercentValue = Double(changePercent24Hr), let marketValue = Double(market), let supplyValue = Double(market), let volValue = Double(vol) else {
            return
        }

        priceLabel.text = String(format: "$ %.2f", priceUsdValue)
        let roundedChangePercent = String(format: "%.2f%%", changePercentValue)
        hourLabel.text = roundedChangePercent
        hourLabel.textColor = changePercentValue < 0 ? UIColor(red: 0.851, green: 0.016, blue: 0.161, alpha: 1) : UIColor(red: 0.129, green: 0.749, blue: 0.451, alpha: 1)

        valMarketLabel.text = String(format: "$ %.2fb", marketValue / 1_000_000_000)
        valSupplyLabel.text = String(format: "$ %.2fm", supplyValue / 1_000_000)
        valVolLabel.text = String(format: "$ %.2fb", volValue / 1_000_000_000)
    }
}
