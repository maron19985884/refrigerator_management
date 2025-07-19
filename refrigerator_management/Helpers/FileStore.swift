import Foundation

/// 非同期で Codable データの読み書きを行う汎用ファイルストア
struct FileStore<T: Codable> {
    let url: URL
    private let queue = DispatchQueue(label: "FileStore", qos: .background)

    init(fileName: String) {
        self.url = FileManager.documentsDirectory.appendingPathComponent(fileName)
    }

    func load(completion: @escaping (Result<T, Error>) -> Void) {
        queue.async {
            do {
                let data = try Data(contentsOf: url)
                let decoded = try JSONDecoder().decode(T.self, from: data)
                DispatchQueue.main.async { completion(.success(decoded)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }
    }

    func save(_ value: T) {
        queue.async {
            if let data = try? JSONEncoder().encode(value) {
                try? data.write(to: url)
            }
        }
    }
}

extension FileManager {
    /// アプリのドキュメントディレクトリを返す
    static var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
