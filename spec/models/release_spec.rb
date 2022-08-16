require 'spec_helper'

describe Release do
  it "should give back urls" do
    Release.create({current_win: true, win_url:"http:win.url.hu",current_mac: true, mac_url:"http:mac.url.hu"})

    expect(Release.default_win_url).to eq "http:win.url.hu"
    expect(Release.default_mac_url).to eq "http:mac.url.hu"

  end
end
