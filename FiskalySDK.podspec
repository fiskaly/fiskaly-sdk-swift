Pod::Spec.new do |spec|

  spec.name         = "FiskalySDK"
  spec.version      = "1.2.100"
  spec.summary      = "FiskalySDK creates a bridge between native Swift and the fiskaly Client."
  spec.description  = <<-DESC
                    The FiskalySDK helps integrators work with the fiskaly Client using native Swift functions. This SDK provides a 
                    framework to be imported into iOS Projects. 
                   DESC

  spec.homepage     = "https://developer.fiskaly.com/"
  spec.license      = { :type => "MIT", :file => "license.txt" }
  spec.author       = { "fiskaly GmbH" => "office@fiskaly.com" }

  spec.platform     = :ios, "9.0"
  spec.source       = { :http => "https://github.com/fiskaly/fiskaly-sdk-swift/releases/download/v#{spec.version}/FiskalySDK.zip" }
  spec.ios.vendored_frameworks = "FiskalySDK.framework"

end
