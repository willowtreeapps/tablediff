# TableDiff

TableDiff is a small library that takes two collections and generates
a diff that is suitable for feeding into `UITableView` or
`UICollectionView` to animate the changes. It additionally tracks
which items have been updated so that UI code can adjust individual
rows or cells.

We created it to animate between distinct collection states in a Redux-like
architecture like [ReSwift](https://github.com/ReSwift/ReSwift).

### Table of Contents

* [Getting Started](#getting-started)
* [Implementations](#implementations)
* [Updates](#updates)
* [Goals and Non-Goals](#goals)
* [Bugs and Feature Requests](#bugs)
* [Contributing](#contributing)

## Getting Started<a name="getting-started"></a>

Please see the [demo](https://github.com/willowtreeapps/TableDiff/tree/develop/Demo)
app for a working example.

Initially you will want to make the elements in your datasource to conform to
the protocol `SequenceDiffable`. This means you need to
* Conform to `Equatable`
* Have a `identifier` variable that is `Hashable`

The `identifier` is used to determine if two items are the same, while equality
checks to see if the same item has been updated.

When you want to update the datasource you will need to calculate the diff:

```swift
let (diff, updates) = originalData.tableDiff(newData)
```

Then you can choose to either perform all the updates yourself or you can use the
convenience extensions to handle the moves/inserts/deletes:

```swift
tableView.applyDiff(diff)
collectionView.applyDiff(diff)
```

Updates still need to be managed manually, as this is app specific code. You
can change the animation styles with additional parameters on the helpers.

### Implementations<a name="implementations"></a>

We originally approached this problem with a
[Longest Common Subsequence](https://en.wikipedia.org/wiki/Longest_common_subsequence_problem)
algorithm, based on the work of [Dwifft](https://github.com/jflinter/Dwifft).
However, that algorithm only speaks in inserts and deletes, while for some use
cases we would prefer to use `UITableView`'s move capabilities.

We provide three different implementation options:

* `.lcs`: This is the original LCS based algorithm, which only returns inserts
  and deletes.
* `.lcsWithMoves`: This is the same algorithm with a post-processing step included
  to turn some delete/insert pairs into moves. This does not always line up with
  what you may perceive as the "intuitive moves".
* `.allMoves`: This algorithm looks for all possible moves first, and then layers
  in inserts and deletes. It creates the nicest effect for moves, but has more
  extraneous instructions in the diff.

You can choose which implementation to use via a parameter. The default value is
`.allMoves`.

```swift
tableView.applyDiff(diff, implementation: .lcs)
```

### Updates<a name="updates"></a>

Updates to an individual item are tracked while the diff is created. But since
an update implies the same item is in both collections, you have the choice of
which collection's indices you'd like to use. You can choose to have the first
collection's indices with `.pre`, or the second collection's with `.post`. The
default is `.pre`.

```swift
tableView.applyDiff(diff, updateStyle: .post)
```

## Goals<a name="goals"></a>

* Calculate diff between 2 `CollectionTypes` :+1:
* Translate diff into moves/inserts/deletes/updates :+1:
* Adapt algorithm to be used with sections

## Bugs and Feature Requests<a name="bugs"></a>

Have a bug or a feature request? Please first read the
[issue guidelines](https://github.com/willowtreeapps/tablediff/blob/develop/CONTRIBUTING.md)
and search for existing and closed issues. If your problem or idea is not
addressed yet, please open a
 [new issue](https://github.com/willowtreeapps/TableDiff/issues/new).

## Contributing<a name="contributing"></a>

Please read through our
[contributing guidelines](https://github.com/willowtreeapps/tablediff/blob/develop/CONTRIBUTING.md).
Included are directions for opening issues, coding standards, and notes on development.
