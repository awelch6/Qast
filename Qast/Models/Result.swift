import Foundation

enum Result<T> {
    case value(T)
    case error(Error)
}
