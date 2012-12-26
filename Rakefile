# Rakefile
include Rake::DSL
require 'bundler'
Bundler.require

Wox::Tasks.create :info_plist => 'gpen/gpen-Info.plist', :sdk => 'iphoneos', :configuration => 'Release' do
  build :debug, :configuration => 'Debug'

  build :release, :developer_certificate => 'iPhone Developer: Aleksandr Sergeev' do
    ipa :adhoc, :provisioning_profile => 'C10017DA-59CB-4072-A8CF-04E73C0FD074' do
      testflight :publish, :api_token => 'a3977a2c0068de2da1c13be524ba7c27_MzE5NjI0MjAxMi0wMi0xNiAwMjowOTo1NC4wMzk5ODM',
                           :team_token => '7118ce716cc122c80f895a1178b27de5_MTU4MjIxMjAxMi0xMS0yMiAwMzo1MToyNy42NjExNzE',
                           :notes => proc { File.read("CHANGELOG") },
                           :distribution_lists => %w[Internal],
                           :notify => true

    end
  end
end
