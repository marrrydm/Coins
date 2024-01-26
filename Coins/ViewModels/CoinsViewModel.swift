import Foundation
import UIKit

class CoinsViewModel {
    private var coins = [CryptoData.Coin]()
    private var filteredCoins = [CryptoData.Coin]()
    private let semaphore = DispatchSemaphore(value: 1)

    var numberOfCoins: Int {
        return isSearching ? filteredCoins.count : coins.count
    }

    var isSearching: Bool {
        return !searchText.isEmpty
    }

    var searchText: String = "" {
        didSet {
            filterCoins()
        }
    }

    func coin(at index: Int) -> CryptoData.Coin? {
        if isSearching {
            guard index < filteredCoins.count else { return nil }
            return filteredCoins[index]
        } else {
            guard index < coins.count else { return nil }
            return coins[index]
        }
    }

    func loadImage(for indexPath: IndexPath, completion: @escaping (Result<UIImage?, Error>) -> Void) {
        guard let coin = coin(at: indexPath.row) else {
            return
        }
        
        let symbol = coin.symbol.lowercased()

        if let img = CoinsContent.shared.coinIcons[symbol] {
            completion(.success(img))
        }
    }

    func fetchData(completion: @escaping (Result<Void, Error>) -> Void) {
        CoinsContent.shared.refreshData { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let newCoins):
                    self.coins = newCoins
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    func loadNextPage(completion: @escaping (Result<Void, Error>) -> Void) {
        guard !isSearching else {
            completion(.success(()))
            return
        }
        
        CoinsContent.shared.getCurrencies { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.global().async {
                self.semaphore.wait()
                switch result {
                case .success(let newCoins):
                    self.coins.append(contentsOf: newCoins)
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
                self.semaphore.signal()
            }
        }
    }

    func filterCoins() {
        guard !searchText.isEmpty else {
            filteredCoins = []
            return
        }

        let lowercaseSearchText = searchText.lowercased()

        filteredCoins = coins.filter { coin in
            let lowercaseName = coin.name.lowercased()
            let lowercaseSymbol = coin.symbol.lowercased()

            return lowercaseName.contains(lowercaseSearchText) || lowercaseSymbol.contains(lowercaseSearchText)
        }
    }
}
