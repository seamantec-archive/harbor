class ProductsController < ApplicationController
  before_action :before_download, only: [:download, :download_mac, :download_win]
  before_action :init_for_public_trial_license, only: [:download, :download_mac, :download_win]

  layout "static", only: [:download, :download_mac, :download_win, :thank_you]

  def download
    user_agent = request.env['HTTP_USER_AGENT']
    if is_mac?(user_agent)
      redirect_to download_mac_path
    elsif is_win?(user_agent)
      redirect_to download_win_path
    end
    @release_win = Release.find_by(current_win: true)
    @release_mac = Release.find_by(current_mac: true)
  end

  def download_win
    @os = "win"
    @release = Release.find_by(current_win: true)
  end

  def download_mac
    @os = "mac"
    @release = Release.find_by(current_mac: true)
  end

  def thank_you
    @release = Release.find(params[:release_id])
    @os = params[:os]
    unless @release.nil?
      @download_url = params[:os] == "mac" ? @release.mac_url : @release.win_url
    else
      @download_url = ""
    end
  end

  def get_current_version
    if (params[:os] === "mac")
      render text: Release.find_by(current_mac: true).try(:version_number)
    elsif (params[:os] === "win")
      render text: Release.find_by(current_win: true).try(:version_number)
    end
  end

  private
  def init_for_public_trial_license
    @errors = []
    @user = User.new
    @license = @user.licenses.build
    @license.expire_at = Time.now + 30.days
  end



  def before_download
    @errors = []
    @user = User.new
    @license = @user.licenses.build
    @license.expire_at = Time.now + 30.days
  end
end
