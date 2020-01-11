//
//  OMDBViewModel.swift
//  OMDB iOS Client App
//
//  Created by radhakrishnan on 30/09/19.
//  Copyright © 2020 Radhakrishnan. All rights reserved.
//

import UIKit

class OMDBViewModel {
    private var searchTerm = ""
    private var pageModel: PageModel?

    let noOfCellsInRow = 2 //No of cells per row
    var imageURL: OMDBModel?
    
    var operationQueue = ImageDownloadOperations() //Operation Queue initialization

    
    //Closures for binding
    var showAlertClosure: (()->())?
    var reloadTableViewClosure: (()->())?
    var reloadTableViewIndexClosure: ((IndexPath)->())?
    var updateLoadingStatus: (()->())?
    
    private var cellViewModels: [OMDBModel] = [OMDBModel]() {
        didSet {
            self.reloadTableViewClosure?()
        }
    }
    var numberOfCells: Int {
        return cellViewModels.count
    }
    
    func getCellViewModel( at indexPath: IndexPath ) -> OMDBModel {
        return cellViewModels[indexPath.row]
    }
    
    func setImageURL(indexPath: IndexPath) {
        imageURL = cellViewModels[indexPath.row]
    }
    var isLoading: Bool = false {
        didSet {
            self.updateLoadingStatus?()
        }
    }
    var alertMessage: String? {
        didSet {
            self.showAlertClosure?()
        }
    }
    
    //Load more photo when it reaches the end
    func loadMorePhotos() {
        if pageModel?.currentPage == pageModel?.totalPages {
            return
        }
        ServiceManager.fetchPhotosForSearchText(searchText: searchTerm, pageNo: pageModel!.currentPage! + 1) { [weak self] (error, model, page) in
            if(error == nil){
                self?.cellViewModels.append(contentsOf: model!)
                self?.pageModel = page
            }else{
                self?.alertMessage = error?.localizedDescription
            }
        }
    }
    
    //Search photos with the user's input
    func searchPhotos(text: String){
        self.isLoading = true
        searchTerm = text
        ServiceManager.fetchPhotosForSearchText(searchText: text, pageNo:1) { [weak self] (error, model, page) in
            self!.isLoading = false
            if(error != nil){
                self?.alertMessage = error?.localizedDescription
                self?.cellViewModels.removeAll()
            }else if model!.isEmpty{
                self?.alertMessage = ConstantStrings.kNoResult
                self?.cellViewModels.removeAll()
            }else{
                self?.cellViewModels = model!
            }
            self?.pageModel = page
        }
    }
    
    //This method will initiate the image downlaod request over queue
    func startOperations(for OMDBRecord: OMDBModel, at indexPath: IndexPath) {
        guard operationQueue.downloadsInProgress[indexPath] == nil else {
            return
        }
        let downloader = ImageDownloader(OMDBRecord)
        //This block will be executed when the image download was completed
        downloader.completionBlock = { [weak self] () in
            if downloader.isCancelled {
                return
            }
            
            self?.operationQueue.downloadsInProgress.removeValue(forKey: indexPath)
            if OMDBRecord.state != .new {
                self?.reloadTableViewIndexClosure!(indexPath)
            }
        }
        operationQueue.downloadsInProgress[indexPath] = downloader
        operationQueue.downloadQueue.addOperation(downloader)
    }
    
    //Cancels all the current operations
    func cancelAllOperation(){
        operationQueue.downloadsInProgress.removeAll()
        operationQueue.downloadQueue.cancelAllOperations()
    }
    
    //Adds operaration of visible cells and removes the operations of the invisible cells
    func loadImagesForOnscreenCells(pathsArray: [IndexPath]) {
        let allPendingOperations = Set(operationQueue.downloadsInProgress.keys)
        //3
        var toBeCancelled = allPendingOperations
        let visiblePaths = Set(pathsArray)
        toBeCancelled.subtract(visiblePaths)
        
        //4
        var toBeStarted = visiblePaths
        toBeStarted.subtract(allPendingOperations)
        
        // 5
        for indexPath in toBeCancelled {
            if let pendingDownload = operationQueue.downloadsInProgress[indexPath] {
                pendingDownload.cancel()
            }
            operationQueue.downloadsInProgress.removeValue(forKey: indexPath)
        }
        // 6
        for indexPath in toBeStarted {
            let object = getCellViewModel( at: indexPath )
            let recordToProcess = object
            if recordToProcess.state == .new{
                startOperations(for: recordToProcess, at: indexPath)
            }
        }
    }
}
