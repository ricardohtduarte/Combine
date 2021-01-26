import Combine
import Foundation

public func example(of description: String,
                    action: () -> Void) {
  print("\n——— Example of:", description, "———")
  action()
}

// Publisher: transmits values over time

// Subscriber: defines requirements for a type to be able to receive input from a publisher

// Sink subscriber: provides two closures:
//     Completion event: when the publisher stops emitting events
//     Receive value: handles value receiving by publisher


example(of: "Sink", action: {
    // Just: creates a publisher from a primitive type
    let just = Just("Hello world")

    _ = just
        .sink(
            receiveCompletion: { result in
                switch result {
                case .finished:
                    print("Publisher finished")
                case .failure(let error):
                    print("Publisher finished with error: \(error)")
                }
            },
            receiveValue: {
                print("Publisher gave us \($0)")
            })
})

// Assign subscriber: assigns the value of a publisher to a KVO compliant property

example(of: "Assign to:on:", action: {
    class SomeObject {
        var value: String = "" {
            didSet {
                print(value)
            }
        }
    }

    let object = SomeObject()

    // Emits each member of the array sequencially
    let publisher = ["Hello", "world!"].publisher

    _ = publisher
        .assign(to: \.value, on: object)
})


example(of: "assign(to:)") {
    // 1
    class SomeObject {
        // @Published property wrapper, which creates a publisher for value in addition to being accessible as a regular property
        @Published var value = 0
    }

    let object = SomeObject()

    // 2
    object.$value
        .sink {
            print($0)
        }

    // 3
    (0..<10).publisher
        .assign(to: &object.$value)
}


// Cancellable

// When we no longer receive values from a publisher we should cancel the subscription to free up recources
// Subscriptions return an instance of AnyCancellable as a "cancellation token"
// AnyCancellable conforms to the Cancellable protocol, which requires the cancel() method exactly for that purpos
// If you don’t explicitly call cancel() on a subscription, it will continue until the publisher completes, or until normal memory management causes a stored subscription to deinitialize.


example(of: "Sink", action: {
    // Just: creates a publisher from a primitive type
    let just = "Hello world".publisher

    let subscription: AnyCancellable = just
        .sink(
            receiveCompletion: { result in
                switch result {
                case .finished:
                    print("Publisher finished")
                case .failure(let error):
                    print("Publisher finished with error: \(error)")
                }
            },
            receiveValue: {
                print("Publisher gave us \($0)")
            })
    subscription.cancel()
})



// Publisher                       Subscriber
//    |  <------ Subscribes ---------- |
//    |                                |
//    |  ---  Gives Subscription --->  |
//    |                                |
//    |  <---  Requests Values   ----  |
//    |                                |
//    |  -----  Sends Values  ------>  |
//    |                                |
//    |  ----  Sends Completion  ----> |
//    |                                |


// Future: can be used to asynchronously produce a single result and then complete

example(of: "Future") {
    var subscriptions: Set<AnyCancellable> = []

  func futureIncrement(integer: Int, afterDelay delay: TimeInterval) -> Future<Int, Never> {
    Future<Int, Never> { promise in
        DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
            promise(.success(integer + 1))
        }
    }
  }
    let future = futureIncrement(integer: 5, afterDelay: 5)
    future
        .sink(receiveCompletion: {
            print($0)
        }, receiveValue: {
            print($0)
        })
        .store(in: &subscriptions)
}

// PassthroughSubject
// Convenient way to adapt existing imperative code to the Combine model
// 
