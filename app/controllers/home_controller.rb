class HomeController < ApplicationController

  before_filter :signed_in_user?

  def welcome

  end

  def index

  end

  def elfinder
    h, r = ElFinder::Connector.new(
                         :root => File.join(Rails.root, 'vendor', 'mounts',current_user.phash),
      :url => '/vendor/mounts',
      :home => current_user.email,
      :perms => {
        /pjkh\.png$/ => {:write => false, :rm => false},
        /\.txt$/ => {:write => true,:rm => true},
        '.' => {:read =>true,:write =>false,:rm => false}
      },
      :extractors => {
        'application/zip' => ['unzip', '-qq', '-o'],
        'application/x-gzip' => ['tar', '-xzf'],
      },
      :archivers => {
        'application/zip' => ['.zip', 'zip', '-qr9'],
        'application/x-gzip' => ['.tgz', 'tar', '-czf'],
      },
      :thumbs => true
    ).run(params)

    headers.merge!(h)
    render (r.empty? ? {:nothing => true} : {:text => r.to_json}), :layout => false
  end

  def thumbs
   thumb  = params[:id] + '.' + params[:format]
   send_file File.join(Rails.root,'vendor','mounts','.thumbs',thumb)
  end

  def previews
   send_file File.join(Rails.root,'vendor','mounts',params[:id] + '.' + params[:format]) , disposition: 'inline'
  end

  def download
    send_file File.join(Rails.root,params[:target])
  end


  def createContainer
    params[:mount] = "test"
    params[:file_name] = "test"
    path = File.join(Rails.root,'vendor','mounts',current_user.phash,params[:mount])
    FileUtils.mkdir(path) if !File.directory? path
    `source "#{Rails.root.join('lib','bash','test.sh').to_s}" "#{params[:file_name]}"`
    binding.pry
    respond_to do |format|
      format.html
      format.js
    end

  end


  def signed_in_user?
    unless user_signed_in?
      redirect_to new_user_registration_path
    end
  end

end
