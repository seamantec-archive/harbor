class ReleasesController < ApplicationController
  before_filter :authenticate_user!

  def index
    authorize! :show, Release
    @releases = Release.all.page(params[:page])
  end

  def new
    @release = Release.new
    authorize! :create, @release
  end

  def upload_file
    @release = Release.find(params[:id])
    uploaded_io = params[:release][:file]
    File.open("#{CONFIGS[:releases_path]}/#{uploaded_io.original_filename}", 'wb') do |file|
      file.write(uploaded_io.read)
    end
    if (params[:type] == "mac")
      @release.update_attributes(mac_url: "#{HOST}/uploaded_releases/#{uploaded_io.original_filename}")
    elsif params[:type] == "win"
      @release.update_attributes(win_url: "#{HOST}/uploaded_releases/#{uploaded_io.original_filename}")
    end
    redirect_to releases_path
  end

  def create
    @release = Release.new(release_params)
    authorize! :create, @release
    if (@release.save)
      redirect_to releases_path
    else
      render action: "new"
    end
  end

  def upload_callback
    @release = Release.find(params[:id])
    authorize! :create, @release
    if (params[:release_mac].present?)
      @release.update_attributes(mac_url: URI.unescape(params[:release_mac][:release_url]))
    elsif params[:release_win].present?
      @release.update_attributes(win_url: URI.unescape(params[:release_win][:release_url]))
    end
    render text: params[:url]
  end

  def set_def_mac
    @release = Release.find(params[:id])
    authorize! :create, @release
    if @release.mac_url.present?
      prev_release = Release.find_by(current_mac: true)
      prev_release.update_attributes(current_mac: false) if prev_release.present?
      @release.update_attributes(current_mac: true)
    else
      flash[:alert] = "No uploaded MAC file!"
    end
    redirect_to releases_path

  end

  def set_def_win
    @release = Release.find(params[:id])
    authorize! :create, @release
    if  @release.win_url.present?
      prev_release = Release.find_by(current_win: true)
      prev_release.update_attributes(current_win: false) if prev_release.present?
      @release.update_attributes(current_win: true)
    else
      flash[:alert] = "No uploaded WIN file!"

    end
    redirect_to releases_path
  end

  private
  def release_params
    params.require(:release).permit(:version_number)
  end


end
