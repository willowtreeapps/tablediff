Pod::Spec.new do |s|
    s.name         = "TableDiff"
    s.version      = "0.1.0"
    s.summary      = "TableDiff: Handle updates to a TableView's/CollectionView's datasource changes"
    s.description  = <<-DESC
                    TableDiff calculates the diff between two datsources to then update the
                    view with the appropriate animations provided by UIKit.
                    DESC

    s.homepage     = "http://github.com/willowtreeapps/tableDiff"
    s.license      = "All rights reserved."
    s.authors      = {
                        "Ian Terrell" => "ian.terrell@willowtreeapps.com",
                        "Kent White"  => "kent.white@willowtreeapps.com",
                      }

    s.source       = { :git => "https://github.com/willowtreeapps/tableDiff.git", :tag => "v0.1.0" }

    s.platform = :ios
    s.ios.deployment_target = "9.0"

    s.source_files = "Sources/*.swift"
end
