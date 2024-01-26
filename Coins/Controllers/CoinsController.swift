import UIKit

protocol CoinsControllerDelegate: AnyObject {
    func didSelectCoin(name: String, symbol: String, priceUsd: String, changePercent24Hr: String, market: String, supply: String, vol: String)
}

final class CoinsController: UIViewController {
    private let viewModel = CoinsViewModel()

    weak var delegate: CoinsControllerDelegate?

    private let titleLabel: UILabel = {
        let view = UILabel()
        view.text = "coins.title".localize()
        view.textColor = .white
        view.font = UIFont(name: "SF Pro Text Semibold", size: 24)
        return view
    }()

    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "bg"))
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        return control
    }()

    private lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.backgroundColor = UIColor.clear
        searchController.searchBar.isTranslucent = true
        searchController.searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        searchController.searchBar.searchBarStyle = .minimal
        searchController.searchBar.barTintColor = UIColor.clear
        searchController.searchBar.tintColor = UIColor.white
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.searchBar.keyboardAppearance = .light

        if #available(iOS 13.0, *) {
            let searchTextField = searchController.searchBar.searchTextField
            searchTextField.textColor = .white
        } else {
            if let textField = searchController.searchBar.value(forKey: "searchField") as? UITextField {
                textField.textColor = .white
            }
        }

        return searchController
    }()

    private lazy var searchButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "search"), for: .normal)
        button.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        return button
    }()

    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 9
        layout.minimumInteritemSpacing = 9
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.register(CoinsCell.self, forCellWithReuseIdentifier: "CoinsCell")
        view.delegate = self
        view.dataSource = self
        view.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        return view
    }()

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        collectionView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.searchText = ""
        viewModel.filterCoins()
        searchController.searchBar.text = ""
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.refreshControl = refreshControl
        setupViews()
        setupBindings()
        fetchContent()
    }

    private func setupBindings() {
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        viewModel.filterCoins()
        collectionView.reloadData()
    }
}

private extension CoinsController {
    func setupViews() {
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        searchButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubviews(backgroundImageView, titleLabel, collectionView, searchButton)

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            searchButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            searchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            searchButton.widthAnchor.constraint(equalToConstant: 40),
            searchButton.heightAnchor.constraint(equalToConstant: 40),

            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

private extension CoinsController {
    @objc func refreshData() {
        viewModel.fetchData { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
                switch result {
                case .failure(let error):
                    print(error)
                default:
                    break
                }
            }
        }
    }

    @objc func searchButtonTapped() {
        present(searchController, animated: true, completion: nil)
    }

    private func fetchContent() {
        viewModel.fetchData { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.viewModel.filterCoins()
                    self.collectionView.reloadData()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.setupBindings()
                        self.setupViews()
                    }
                case .failure(let error):
                    print(error)
                }
            }
        }
    }

    func loadNextPage() {
        viewModel.loadNextPage { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.collectionView.reloadData()
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}

extension CoinsController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfCoins
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CoinsCell", for: indexPath) as! CoinsCell

        viewModel.loadImage(for: indexPath) { result in
            switch result {
            case .success(let image):
                if let coin = self.viewModel.coin(at: indexPath.row) {
                    cell.configure(with: CoinCellViewModel(name: coin.name, symbol: coin.symbol, priceUsd: coin.priceUsd, changePercent24Hr: coin.changePercent24Hr ?? "1.0", image: image))
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let lastElement = viewModel.numberOfCoins - 4
        if indexPath.row == lastElement {
            loadNextPage()
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: (collectionView.frame.width - 10.0), height: 72)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let coin = viewModel.coin(at: indexPath.row) else { return }

        let vc = DetailsController()
        vc.modalPresentationStyle = .fullScreen

        self.delegate = vc
        delegate?.didSelectCoin(
            name: coin.name,
            symbol: coin.symbol,
            priceUsd: coin.priceUsd,
            changePercent24Hr: coin.changePercent24Hr ?? "1.0",
            market: coin.marketCapUsd ?? "1.0",
            supply: coin.maxSupply ?? "1.0",
            vol: coin.volumeUsd24Hr
        )

        let animated = !searchController.isActive

        searchController.dismiss(animated: false) { [self] in
            DispatchQueue.main.async { [self] in
                self.present(vc, animated: animated)
            }
            searchButton.alpha = 1
            titleLabel.alpha = 1
        }
    }
}

extension CoinsController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.filterCoins()
        collectionView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchText = searchText
        viewModel.filterCoins()
        collectionView.reloadData()
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchButton.alpha = 0
        titleLabel.alpha = 0
    }

    func didDismissSearchController(_ searchController: UISearchController) {
        searchButton.alpha = 1
        titleLabel.alpha = 1
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.searchText = ""
        viewModel.filterCoins()
        collectionView.reloadData()

        searchButton.alpha = 1
        titleLabel.alpha = 1
    }
}
