//
//  ViewController.swift
//  OMDB iOS Client App
//
//  Created by Radhakrishnan A on 11/1/20.
//  Copyright © 2020 Radhakrishnan. All rights reserved.
//

import UIKit
class OMDBViewController: UIViewController {
    //Constants
    static let cellIdentifier = "ImageViewCollectionViewCell"
    
    @IBOutlet var imageCollectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    lazy var viewModel: OMDBViewModel = {
        return OMDBViewModel()
    }()
    
    
    // MARK: - Life Cycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        initView()
        initViewModel()
    }
    
    //Intialise Navigation Bar and UI
    func initView() {
        title = ConstantStrings.kOMDBTitle
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        // Setup the Search Controller
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = ConstantStrings.kSearchImage
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        searchController.searchBar.delegate = self
        
        
        imageCollectionView.allowsMultipleSelection = false
    }
    
    func initViewModel() {
        
        // Naive binding between Contorller and View Model
        viewModel.showAlertClosure = { [weak self] () in
            DispatchQueue.main.async {
                if let message = self?.viewModel.alertMessage {
                    self?.showAlert( message )
                }
            }
        }
        viewModel.reloadTableViewClosure = { [weak self] () in
            DispatchQueue.main.async {
                self?.imageCollectionView.reloadData()
                self?.resumeAllOperations()
            }
        }
        viewModel.reloadTableViewIndexClosure = { [weak self] (index) in
            DispatchQueue.main.async {
                if self!.imageCollectionView.numberOfItems(inSection: 0) > index.row{
                    self?.imageCollectionView.reloadItems(at: [index])
                }
            }
        }
        
        viewModel.updateLoadingStatus = { [weak self] () in
            DispatchQueue.main.async {
                let isLoading = self?.viewModel.isLoading ?? false
                if isLoading {
                    self?.activityIndicator.startAnimating()
                    UIView.animate(withDuration: 0.2, animations: {
                        self?.imageCollectionView.alpha = 0.0
                    })
                }else {
                    self?.activityIndicator.stopAnimating()
                    UIView.animate(withDuration: 0.2, animations: {
                        self?.imageCollectionView.alpha = 1.0
                    })
                }
            }
        }
    }
    
    //Method to show alert
    func showAlert( _ message: String ) {
        let alert = UIAlertController(title: ConstantStrings.kAlert, message: message, preferredStyle: .alert)
        alert.addAction( UIAlertAction(title: ConstantStrings.kOk, style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Deselect the selection on returning back
        if let selectionIndexPath = imageCollectionView.indexPathsForSelectedItems,let index = selectionIndexPath.first {
            imageCollectionView.deselectItem(at: index, animated: animated)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? DetailViewController{
            //Pass selected Image URL
            vc.model = viewModel.imageURL
        }
    }
    
    // MARK: - Operation Management Methods
    //Used for managing the Operation Queue
    
    func suspendAllOperations() {
        viewModel.operationQueue.downloadQueue.isSuspended = true
    }
    
    func cancelAllOperations() {
        viewModel.cancelAllOperation()
    }
    func resumeAllOperations() {
        viewModel.operationQueue.downloadQueue.isSuspended = false
    }
    
    func loadImagesForOnscreenCells() {
        viewModel.loadImagesForOnscreenCells(pathsArray: imageCollectionView.indexPathsForVisibleItems)
    }
}

// MARK: UICollectionViewDelegateFlowLayout Methods
extension OMDBViewController: UICollectionViewDelegateFlowLayout {
    // responsible for telling the layout the size of a given cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        //To setup the no of cells per row
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let cellsCount = UIDevice.current.orientation.isLandscape ? viewModel.noOfCellsInRow + 1 : viewModel.noOfCellsInRow
        let totalSpace = flowLayout.sectionInset.left
            + flowLayout.sectionInset.right
            + (flowLayout.minimumInteritemSpacing * CGFloat(cellsCount - 1))
        let size = Int((collectionView.bounds.width - totalSpace) / CGFloat(cellsCount))
        return CGSize(width: size, height: size)
    }
}

//MARK: UICollectionViewDelegate and UICollectionViewDataSource Methods
extension OMDBViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfCells
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //Reuse the cell
        let cell :ImageViewCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier:OMDBViewController.cellIdentifier, for: indexPath) as! ImageViewCollectionViewCell
        // set the image from the data model
        let object = viewModel.getCellViewModel( at: indexPath )
        cell.configCell(data: object, indexpath: indexPath)
    
        //Download the image if not downloaded
        if(object.state == .new) {
            if !collectionView.isDragging && !collectionView.isDecelerating {
                viewModel.startOperations(for: object, at: indexPath)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        //When reached to last cell,This will be invoked
        let lastRowIndex = collectionView.numberOfItems(inSection: 0) - 1
        if indexPath.row == lastRowIndex {
            viewModel.loadMorePhotos()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        //Selects Image while tapping on the cell
        viewModel.setImageURL(indexPath: indexPath)
        return true
    }
}

//MARK: UIScrollViewDelegate Methods
extension OMDBViewController: UIScrollViewDelegate{
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        suspendAllOperations()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            loadImagesForOnscreenCells()
            resumeAllOperations()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        loadImagesForOnscreenCells()
        resumeAllOperations()
    }
}

//MARK: UISearchBarDelegate Methods
extension OMDBViewController: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //Cancels the image operations as new input was given by the user
        cancelAllOperations()
        navigationItem.searchController?.dismiss(animated: true, completion: { [weak self] in
            self?.viewModel.searchPhotos(text: searchBar.text!)
        })
    }
}
