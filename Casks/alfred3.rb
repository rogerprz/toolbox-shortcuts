cask "alfred3" do
  version "3.8.6,972"
  sha256 "20b111cbd22fb57f8a1d11348e12b55f9725c8eca6517790b1df8e2cd9c9a9b8"

  url "https://cachefly.alfredapp.com/Alfred_#{version.csv.first}_#{version.csv.second}.dmg"
  name "Alfred 3"
  desc "Application launcher and productivity software (legacy version)"
  homepage "https://www.alfredapp.com/help/v3/"

  app "Alfred 3.app"

  caveats do
    requires_rosetta
    "Alfred 3 is no longer maintained and was designed for macOS through Big Sur."
  end
end
