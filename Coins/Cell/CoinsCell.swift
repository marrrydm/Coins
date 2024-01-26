import UIKit

class CoinsCell: UICollectionViewCell {

    private let button: UIView = {
        let view = UIView()
        view.backgroundColor = .clear

        return view
    }()

    private let img: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFit

        return view
    }()

    private let nameTitle: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 16, weight: .regular)
        view.textColor = .white

        return view
    }()

    private let symbolTitle: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 14, weight: .regular)
        view.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)

        return view
    }()

    private let priceUsdTitle: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 16, weight: .regular)
        view.textColor = .white

        return view
    }()

    private let changePercent24HrTitle: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 14, weight: .regular)
        view.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)

        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }

    func configure(with viewModel: CoinCellViewModel) {
        contentView.backgroundColor = .clear
        nameTitle.text = viewModel.name
        symbolTitle.text = viewModel.symbol

        guard let priceUsdValue = Double(viewModel.priceUsd),
              let changePercentValue = Double(viewModel.changePercent24Hr) else {
            return
        }

        priceUsdTitle.text = String(format: "$ %.2f", priceUsdValue)
        let roundedChangePercent = String(format: "%.2f%%", changePercentValue)
        changePercent24HrTitle.text = roundedChangePercent
        changePercent24HrTitle.textColor = changePercentValue < 0 ? UIColor(red: 0.851, green: 0.016, blue: 0.161, alpha: 1) : UIColor(red: 0.129, green: 0.749, blue: 0.451, alpha: 1)

        img.image = viewModel.image
    }
}

private extension CoinsCell {
    func setupViews() {
        button.translatesAutoresizingMaskIntoConstraints = false
        img.translatesAutoresizingMaskIntoConstraints = false
        nameTitle.translatesAutoresizingMaskIntoConstraints = false
        symbolTitle.translatesAutoresizingMaskIntoConstraints = false
        priceUsdTitle.translatesAutoresizingMaskIntoConstraints = false
        changePercent24HrTitle.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(button)
        button.addSubviews(img, nameTitle, symbolTitle, priceUsdTitle, changePercent24HrTitle)

        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: contentView.topAnchor),
            button.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            img.topAnchor.constraint(equalTo: button.topAnchor, constant: 12),
            img.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 10),
            img.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: -12),
            img.widthAnchor.constraint(equalToConstant: 48),
            img.heightAnchor.constraint(equalToConstant: 48),

            nameTitle.leadingAnchor.constraint(equalTo: img.trailingAnchor, constant: 10),
            nameTitle.bottomAnchor.constraint(equalTo: img.centerYAnchor, constant: -1),

            symbolTitle.leadingAnchor.constraint(equalTo: img.trailingAnchor, constant: 10),
            symbolTitle.topAnchor.constraint(equalTo: img.centerYAnchor, constant: 1),
            
            priceUsdTitle.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -10),
            priceUsdTitle.bottomAnchor.constraint(equalTo: img.centerYAnchor, constant: -1),

            changePercent24HrTitle.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -10),
            changePercent24HrTitle.topAnchor.constraint(equalTo: img.centerYAnchor, constant: 1)
        ])
    }
}
