//
//  ImageDownloaderQueue.swift
//  OMDB iOS Client App
//
//  Created by radhakrishnan on 11/1/20.
//  Copyright © 2020 Radhakrishnan. All rights reserved.
//

import UIKit

final class ImageDownloadOperations :NSObject{
    lazy var downloadsInProgress: [IndexPath: Operation] = [:]
    lazy var downloadQueue: OperationQueue = {
        var queue = OperationQueue()
        queue.name = "OMDB Image Queue"
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
}
