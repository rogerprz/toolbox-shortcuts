cask "snagit22" do
  version "2022.2.9"
  sha256 "5a25f72c5f4eeb597b49bb805df55deef961c75aa43300457e06cef15d460e7b"

  # Installer linked from https://www.techsmith.com/download/licenses/snagit/22
  url "https://download.techsmith.com/snagitmac/releases/#{version}/Snagit.dmg"
  name "Snagit 2022"
  desc "Screen capture and recording software (2022 version)"
  homepage "https://www.techsmith.com/download/licenses/snagit/22"

  app "Snagit 2022.app"
end
