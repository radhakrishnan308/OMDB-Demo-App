//
//  PageModel.swift
//  OMDB iOS Client App
//
//  Created by radhakrishnan on 02/10/19.
//  Copyright © 2020 Radhakrishnan. All rights reserved.
//

import UIKit

struct PageModel {
    // MARK: Properties
       public var totalPages: Int?
       public var numberOfElements: Int?
       public var currentPage: Int?

       init(totalPages: Int, elements: Int, currentPage: Int) {
           self.totalPages = totalPages
           self.numberOfElements = elements
           self.currentPage = currentPage
       }

}
