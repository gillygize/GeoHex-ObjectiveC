# coding: utf-8
Pod::Spec.new do |s|
  s.name         = "GeoHex-ObjectiveC"
  s.version      = "0.0.1"
  s.summary      = "A short description of GeoHex-ObjectiveC."
  s.description  = <<-DESC
                   This is an Objective C port of the GeoHex Library.

                   GeoHex is way of encoding geographic areas using hexagon-shaped
                   regions.  It can support many different sizes and scales.

                   The original version of this project was created by sa2da and
                   can be found at http://geohex.net/.

                   This version is able under the same terms and conditions as the
                   original version: http://creativecommons.org/licenses/by-sa/2.1/jp/
                   DESC

  s.homepage     = "https://github.com/gillygize/GeoHex-ObjectiveC"

  s.platform     = :ios
  s.requires_arc = false

  # NOTE: GeoHex Spec is MIT License. What is this code's license?
  s.license      = { :type => "MIT" }

  s.author       = { "Matthew Gillingham" => "me@mattgillingham.com" }

  s.source       = { :git => "git@github.com:gillygize/GeoHex-ObjectiveC.git", :tag => "0.0.1" }

  s.source_files        = "Classes", "Classes/**/*.{h,m}"
  s.exclude_files       = "Classes/Tests"
  s.public_header_files = "Classes/**/*.h"
end
