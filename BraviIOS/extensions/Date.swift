//
//  Date.swift
//  BraviIOS
//
//  Created by Gustavo Belo Brilhante on 19/12/17.
//  Copyright © 2017 Gustavo. All rights reserved.
//

import Foundation

extension Date
{
    func toString( dateFormat format  : String ) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
}
