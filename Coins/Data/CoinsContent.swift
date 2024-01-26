import UIKit

protocol CryptoDataRepository {
    func getCryptoData(offset: Int, limit: Int, completion: @escaping (Result<[CryptoData.Coin], Error>) -> Void)
}

protocol CoinIconRepository {
    func getCoinIcon(symbol: String, completion: @escaping (Result<UIImage, Error>) -> Void)
}

final class CoinsContent {
    static let shared = CoinsContent()

    private var cryptoDataRepository: CryptoDataRepository
    private var coinIconRepository: CoinIconRepository

    private(set) var coins: [CryptoData.Coin] = []
    private(set) var coinIcons: [String: UIImage] = [:]
    private var currentPage = 1
    private let itemsPerPage = 10

    private init(cryptoDataRepository: CryptoDataRepository = CryptoDataAPI(),
                 coinIconRepository: CoinIconRepository = CoinIconAPI()) {
        self.cryptoDataRepository = cryptoDataRepository
        self.coinIconRepository = coinIconRepository
        fetchContent()
    }
}

private extension CoinsContent {
    func resetPagination() {
        currentPage = 1
        coins.removeAll()
    }

    func fetchContent() {
        getCurrenciesForPage(completion: nil)
    }

    func loadIcon(for symbol: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard coinIcons[symbol] == nil else {
            completion(.success(()))
            return
        }

        let group = DispatchGroup()
        group.enter()

        defer {
            group.leave()
        }

        coinIconRepository.getCoinIcon(symbol: symbol) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let iconData):
                self.coinIcons[symbol] = iconData
            case .failure(let error):
                print("Error loading icon for \(symbol): \(error.localizedDescription)")
            }
        }

        group.notify(queue: .main) {
            completion(.success(()))
        }
    }

    func getCurrenciesForPage(completion: ((Result<[CryptoData.Coin], Error>) -> Void)?) {
        let offset = (currentPage - 1) * itemsPerPage
        let limit = itemsPerPage

        cryptoDataRepository.getCryptoData(offset: offset, limit: limit) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let cryptoData):
                let group = DispatchGroup()

                DispatchQueue.global().async {
                    cryptoData.forEach { coinData in
                        group.enter()

                        self.loadIcon(for: coinData.symbol.lowercased()) { _ in
                            group.leave()
                        }
                    }
                }

                group.notify(queue: .global()) {
                    let newCoins: [CryptoData.Coin] = cryptoData

                    if self.currentPage == 1 {
                        self.coins = newCoins
                    } else {
                        self.coins.append(contentsOf: newCoins)
                    }

                    self.currentPage += 1

                    DispatchQueue.main.async {
                        completion?(.success(newCoins))
                    }
                }

            case .failure(let error):
                DispatchQueue.main.async {
                    completion?(.failure(error))
                }
            }
        }
    }

    func loadNextPage(completion: @escaping (Result<[CryptoData.Coin], Error>) -> Void) {
        currentPage += 1
        getCurrenciesForPage(completion: completion)
    }
}

extension CoinsContent {
    func refreshData(completion: @escaping (Result<[CryptoData.Coin], Error>) -> Void) {
        resetPagination()
        getCurrenciesForPage(completion: completion)
    }

    func getCurrencies(completion: @escaping (Result<[CryptoData.Coin], Error>) -> Void) {
        getCurrenciesForPage(completion: completion)
    }
}

struct CryptoDataAPI: CryptoDataRepository {
    func getCryptoData(offset: Int, limit: Int, completion: @escaping (Result<[CryptoData.Coin], Error>) -> Void) {
        let urlString = "https://api.coincap.io/v2/assets?offset=\(offset)&limit=\(limit)"

        guard let url = URL(string: urlString) else {
            let urlError = NSError(domain: "InvalidURL", code: 0, userInfo: nil)
            completion(.failure(urlError))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                let dataError = NSError(domain: "NoData", code: 0, userInfo: nil)
                completion(.failure(dataError))
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let cryptoData = try decoder.decode(CryptoData.self, from: data)
                let coins = cryptoData.data.map { coinData in
                    return CryptoData.Coin(id: coinData.id,
                                           rank: coinData.rank,
                                           symbol: coinData.symbol,
                                           name: coinData.name,
                                           supply: coinData.supply,
                                           maxSupply: coinData.maxSupply ?? "",
                                           marketCapUsd: coinData.marketCapUsd,
                                           volumeUsd24Hr: coinData.volumeUsd24Hr,
                                           priceUsd: coinData.priceUsd,
                                           changePercent24Hr: coinData.changePercent24Hr,
                                           vwap24Hr: coinData.vwap24Hr, explorer: coinData.explorer)
                }

                completion(.success(coins))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

struct CoinIconAPI: CoinIconRepository {
    func getCoinIcon(symbol: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        let iconURLString = "https://coinicons-api.vercel.app/api/icon/\(symbol)"

        guard let url = URL(string: iconURLString) else {
            let urlError = NSError(domain: "InvalidURL", code: 0, userInfo: nil)
            completion(.failure(urlError))
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                let dataError = NSError(domain: "NoData", code: 0, userInfo: nil)
                completion(.failure(dataError))
                return
            }

            if let icon = UIImage(data: data) {
                completion(.success(icon))
            } else {
                let decodingError = NSError(domain: "IconDecodingError", code: 0, userInfo: nil)
                completion(.failure(decodingError))
            }
        }.resume()
    }
}
