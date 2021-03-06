//
//  DexListModel.swift
//  WavesWallet-iOS
//
//  Created by Pavel Gubin on 7/25/18.
//  Copyright © 2018 Waves Platform. All rights reserved.
//

import Foundation

enum DexList {
    enum DTO {}
    enum ViewModel {}

    enum Event {
        case readyView
        case setModels([DTO.Pair])
        case tapSortButton
        case tapAddButton
        case refresh
    }
    
    struct State: Mutating {
        
        enum Action {
            case none
            case update
        }
        
        var isNeedRefreshing: Bool
        var action: Action
        var sections: [DexList.ViewModel.Section]
        var isFirstLoadingData: Bool
        var lastUpdate: Date
        
        var isVisibleItems: Bool {
            return sections.count > 1
        }
    }
}

extension DexList.ViewModel {
    struct Section: Mutating {
        var items: [Row]
    }
    
    enum Row: Hashable {
        case header(Date)
        case skeleton
        case model(DexList.DTO.Pair)
        
        var model: DexList.DTO.Pair? {
            switch self {
            case .model(let model):
                return model
            default:
                return nil
            }
        }
    }
}

extension DexList.DTO {
    
    struct Pair: Hashable, Mutating {
        
        var firstPrice: Money
        var lastPrice: Money
        let amountAsset: String
        let amountAssetName: String
        let amountTicker: String
        let amountDecimals: Int
        let priceAsset: String
        let priceAssetName: String
        let priceTicker: String
        let priceDecimals: Int
    }
}
