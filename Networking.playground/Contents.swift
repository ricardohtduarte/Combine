import UIKit
import Combine

let url: URL = URL(string: "https://api.nasa.gov/planetary/apod?api_key=SlLKwcIfgJ2PyHg4fZAFyL830FcCcjjNY8F8mPH4")!

var subscriptions = Set<AnyCancellable>()

struct PictureOfTheDay: Codable {
    let date: String
    let explanation: String
}

URLSession.shared
    .dataTaskPublisher(for: url)
    .map(\.data)
    .decode(type: PictureOfTheDay.self, decoder: JSONDecoder())
    .sink(receiveCompletion: {
        print($0)
    }, receiveValue: {
        print($0)
    })
    .store(in: &subscriptions)


// Emit value to several subscriptions

let publisher = URLSession.shared
    .dataTaskPublisher(for: url)
    .map(\.data)
    .multicast { PassthroughSubject<Data, URLError>() }

let subscription1 = publisher
    .sink(receiveCompletion: { completion in
        if case .failure(let err) = completion {
            print("Sink1 Retrieving data failed with error \(err)")
        }
    }, receiveValue: { object in
        print("Sink1 Retrieved object \(object)")
    })

let subscription2 = publisher
    .sink(receiveCompletion: { completion in
        if case .failure(let err) = completion {
            print("Sink2 Retrieving data failed with error \(err)")
        }
    }, receiveValue: { object in
        print("Sink2 Retrieved object \(object)")
    })

let subscription = publisher.connect()
