# DeepDiff

##Notes
The indices of the updates you will get from calling `deepDiff(b: CollectionType)` refer to the end indices after moves/inserts/deletes. This means that you won't want to use `reloadItemsAtIndexPaths` within a batch update of the `CollectionView`