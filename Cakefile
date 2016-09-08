project do |p|
    p.name = "Scorerrest"
    p.class_prefix = "SCR"
    p.organization = "colinta"

    p.debug_configuration.settings["ENABLE_TESTABILITY"] = "YES"
end

application_for :ios, 8.0, :swift do |target|
    target.name = "Scorerrest"

    target.all_configurations.each do |config|
        config.supported_devices = :universal
        config.product_bundle_identifier = "com.colinta.Scorerrest"
        config.settings["INFOPLIST_FILE"] = "Support/Info.plist"
        config.settings["SWIFT_OBJC_BRIDGING_HEADER"] = "Support/BridgingHeader.h"
    end

    target.include_files = ["Source/**/*", "Resources/**/*"]

    target.release_configuration.settings["ASSETCATALOG_COMPILER_APPICON_NAME"] = "AppIcon"

    after_save do
     `pod install`
    end

end
