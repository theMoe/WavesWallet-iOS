//
//  Order.swift
//  WavesWallet-iOS
//
//  Created by Alexey Koloskov on 21/06/2017.
//  Copyright © 2017 Waves Platform. All rights reserved.
//

import Foundation
import Gloss

class AssetPair: Decodable {
    
    var amountAsset: String?
    var priceAsset: String?
    
    public required init?(json: JSON) {
        
        self.amountAsset = "amountAsset" <~~ json
        self.priceAsset = "priceAsset" <~~ json
    }
    
    func assetIdBytes(_ id: String?) -> [UInt8] {
        return id == nil ? [UInt8(0)] :  ([UInt8(1)] + Base58.decode(id!))
    }
    
    var bytes: [UInt8] {
        return assetIdBytes(amountAsset) + assetIdBytes(priceAsset)
    }
}

enum OrderType: String {
    case sell = "sell"
    case buy = "buy"
    
    var bytes: [UInt8] {
        switch self {
        case .sell: return [UInt8(1)]
        case .buy: return [UInt8(0)]
        }
    }
    
}

class Order {
    let senderPublicKey: PublicKeyAccount
    let matcherPublicKey: PublicKeyAccount
    let assetPair: AssetPair
    let orderType: OrderType
    let price: Int64
    let amount: Int64
    let matcherFee: Int64 = 300000
    let timestamp: Int64
    let expiration: Int64
    
    var senderPrivateKey: PrivateKeyAccount?
    
    init(senderPublicKey: PublicKeyAccount, matcherPublicKey: PublicKeyAccount, assetPair: AssetPair, orderType: OrderType,
         price: Int64, amount: Int64) {
        self.senderPublicKey = senderPublicKey
        self.matcherPublicKey = matcherPublicKey
        self.assetPair = assetPair
        self.orderType = orderType
        self.price = price
        self.amount = amount
        self.timestamp = Int64(Date().millisecondsSince1970)
        self.expiration = timestamp + 29 * 24 * 60 * 60 * 1000
    }
    
    func arrayWithSize(_ s: String) -> [UInt8] {
        let b: [UInt8] = Array(s.utf8)
        return toByteArray(Int16(b.count)) + b
    }
    
    var toSign: [UInt8] {
        let s1 = senderPublicKey.publicKey + matcherPublicKey.publicKey
        let s2 = assetPair.bytes + orderType.bytes
        let s3 = toByteArray(price) + toByteArray(amount)
        let s4 = toByteArray(timestamp) + toByteArray(expiration) + toByteArray(matcherFee)
        return s1 + s2 + s3 + s4
    }
    
    var id: [UInt8] {
        return Hash.fastHash(toSign)
    }
    
    func getSignature() -> [UInt8] {
        guard let pk = senderPrivateKey else { return [] }
        let b = toSign
        return Hash.sign(b, pk.privateKey)
    }
    
    func toJSON() -> JSON? {
        return jsonify([
            "id" ~~> Base58.encode(id),
            "senderPublicKey" ~~> Base58.encode(senderPublicKey.publicKey),
            "matcherPublicKey" ~~> Base58.encode(matcherPublicKey.publicKey),
            "assetPair" ~~> assetPair,
            "orderType" ~~> orderType.rawValue,
            "price" ~~> price,
            "amount" ~~> amount,
            "timestamp" ~~> timestamp,
            "expiration" ~~> expiration,
            "matcherFee" ~~> matcherFee,
            "signature" ~~> Base58.encode(getSignature()),
            ])
    }
    
}

