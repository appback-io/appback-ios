//
//var acceptedOrders: OrderRegistry? {
//    get {
//        if let data = UserDefaults.standard.object(forKey: UserDefaultsKey.acceptedOrders.rawValue) as? Data {
//            do {
//                return try JSONDecoder().decode(OrderRegistry.self, from: data)
//            } catch {
//                print("Error while decoding user data")
//            }
//        }
//        return OrderRegistry(orders: [])
//    }
//    set {
//        if let newValue = newValue {
//            do {
//                let data = try JSONEncoder().encode(newValue)
//                UserDefaults.standard.set(data, forKey: UserDefaultsKey.acceptedOrders.rawValue)
//            } catch {
//                print("Error while encoding user data")
//            }
//        } else {
//            UserDefaults.standard.removeObject(forKey: UserDefaultsKey.acceptedOrders.rawValue)
//        }
//    }
//}
