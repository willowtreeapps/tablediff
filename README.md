# TableDiff
* Update a `UITableView` or `UICollectionView` with a new datasource efficiently and visually appealing.
* Replaces a common practice of using `UITableView.reloadData()` with a solution that looks nice and shows the user what is happening. Calculate's the diff between the new and original datasource to find the appropriate updates that need to be made.
* WillowTree, collaboration of [Ian Terrell](https://github.com/ianterrell) and [Kent White](https://github.com/Kent-White)

### Table of Contents
* [Getting Started] (#getting-started)
* [Bugs and Feature Requests] (#bugs)
* [Contributing](#contributing)
* [Goals and Non-Goals](#goals)
* [Copyright and License](#license)

<img src="Docs/Demo.gif" width="300">

## Getting Started<a name="getting-started"></a>

Intially you will want to make the elements in your datasource to conforn to the protocol `SequenceDiffable`
This means you need to 
* Conform to `Equatable`
* Have a `identifier` variable that is `Hashable`

When you want to update the datasource you will need to calculate the diff `let (diff, updates) = originalData.deepDiff(newData)`, then you can choose to either perform all the updates yourself or you can use the convience extension `UITableView.applyDiff(diff) or UICollectionView.applyDiff(diff)` to handle the moves/inserts/deletes and handle the actual update steps yourself.

You can adjust the animations used in a `UITableView` you can use `UITableView.applyDiff(diff, animationType: UITableViewRowAnimation)` or add a completion block to `UICollectionView.applyDiff(diff, completion: ((Bool) -> Void)?)`

Feel free to look at the [demo](https://github.com/willowtreeapps/DeepDiff/tree/develop/Demo) if you are having trouble with the implementation.

### Extra

We originally approached this problem with a [Longest Common Subsequence](https://en.wikipedia.org/wiki/Longest_common_subsequence_problem) algorithm but went towards a different solution as we ran into problems achieving everything we wanted with it.

If you would like to use the LCS approach use `originalData.deepDiff(newData, implementation: .lcs)`. `lcs` may be more efficient but there will be a small amount of extra steps in the returned diff.

The last implementation is `lcsWithoutMoves`. This would be useful if you only wanted inserts and deletes in the diff. This approach will also improve efficiency as far as the diffing algorithm goes, not neccesarily the actual view updates.

The default update step index is `UpdateIndicesStyle.pre` so you will recieve the original indices in `originalData` to update. If you would like the indices on update steps to be post applied diff then use `originalData.deepDiff(newData, updateStyle: UpdateIndicesStyle.post)`

## Bugs and Feature Requests<a name="bugs"></a>
Have a bug or a feature request? Please first read the [issue guidelines](https://github.com/willowtreeapps/DeepDiff/blob/develop/CONTRIBUTING.md) and search for existing and closed issues. If your problem or idea is not addressed yet, please open a [new issue](https://github.com/willowtreeapps/DeepDiff/issues/new).

## Contributing<a name="contributing"></a>
Please read through our [contributing guidelines](https://github.com/willowtreeapps/DeepDiff/blob/develop/CONTRIBUTING.md). Included are directions for opening issues, coding standards, and notes on development.

## Goals and Non-Goals<a name="goals"></a>
* Calculate diff between 2 `CollectionTypes` :+1:
* Translate diff into moves/inserts/deletes/updates :+1:
* Adapt Algorithm to be used with sections

## Copyright and License<a name="license"></a>
Code and documentation copyright 2016 WillowTree, Inc. Code released under the [MIT license](https://github.com/willowtreeapps/DeepDiff/blob/develop/LICENSE.md).