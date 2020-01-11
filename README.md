
  
# OMDB iOS Client App
A Sample app which will demostrate the Lazy Loading, Operation Queue and MVVM pattern

* Xcode: 11.0
* Deployment Target : iOS 11+

## Notes [Important]
* Provide the OMDB API key under **"Constants.swift/Keys/APIKey"** before building the project

## Architecture

* App build using MVVM Architecture

* Closure and Property Observer are used to bind the View model and Viewcontroller

* Images are downloaded Asynchronously using Operation(NSOperation)

* These Operations are delegated using OperationQueue for better control over the threads

  

## Overview

### MVVM

* View Model serves as a abstraction layer between the controller and the data

* Controller doesn't aware of the data, It will work based on the suggestions of the View Model
* Unit test case would be easy as no need to mock the UI

  

### Closure and Property Observer

  

* We had used Closure and Property Observer to minimse the amount code required (Less code, Less bug)

* Initially all the closure definitions are defined in the contoller

* Later these closure are invoked by the property observer

		var isLoading: Bool = false {
			didSet {
				self.updateLoadingStatus()
			}
		}

  

### OperationQueue and Operation

* OperationQueue manages the operation without blocking the system resources

* And it will provide more control over the operation, At anytime we can cancel or suspend or resume the operations

* For our lazy loading,Each Image dowload tasks for visible cells are added in a separate operation and these operations are added to the operation queue

* Operation will return the output once the task was done

* If the user scrolls aways from the cell before downloading,we'll cancel the operation as priority has been changed to the visible cells

* Based on the visible cells we'll load and unload the operation queue to minimize the memory and processing usage

* Downloaded images are saved in the cache as we don't need to download

  
  

## Why and What ?

These are the question you might have after going through the app

  

##### Why we need to cache as GET operation are cached by OS in default ?

* Yes,It would be cached by OS,but OS will purge the data based on the availabilty of the resource, So we are caching to retain the data

  

##### Did we followed the best practice for caching ?

* No, beacuse storing image data in main memory is a bad practice, We should move it to secondary memory
* And we shouldn't store a array with more than 50 items, It will slow down the collection view, We should introduce a data manager backed by Core Data

##### Why we had used the NSObject model classes instead of Struct ?

* We had used NSObject becasue they are reference type so that we can modify the value from any place if we have the copy of reference
* For Queing purpose made it as NSObject
* We can archieve the same using Struct but it will required more code and increases the complexity



#### Things I had didn't done
* More unit test case coverage
* CollectionView Cell UI should have been decoupled from the ViewController UI



#### Please raise an issue if something could have been done better, So that next time I'll try to improve it
