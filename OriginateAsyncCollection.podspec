Pod::Spec.new do |s|
  s.name                = "OriginateAsyncCollection"
  s.version             = "0.0.2"
  s.summary             = "A (high level) class modeling an asynchronously retrieved collection of data."

  s.homepage            = "https://github.com/Originate/OriginateAsyncCollection"
  s.license             = 'MIT'
  s.author              = { "Philip Kluz" => "philip.kluz@originate.com" }
  s.source              = { :git => "https://github.com/Originate/OriginateAsyncCollection.git", :tag => s.version.to_s }

  s.platform            = :ios, '8.0'
  s.requires_arc        = true

  s.source_files        = 'Pod/Sources/**/*'

  s.public_header_files = 'Pod/Sources/**/*.h'
end
