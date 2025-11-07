//
//  CouponModel.swift
//  Prodify
//
//  Created by abdulrhman urabi on 05/11/2025.
//

// CouponModel.swift
import Foundation

struct Coupon {
    let code: String
    let discountPercentage: Double
}

extension Coupon {
    static let availableCoupons: [Coupon] = [
        Coupon(code: "SAVE10", discountPercentage: 10),
        Coupon(code: "FREESHIP", discountPercentage: 0) // handled later if needed
    ]
}
