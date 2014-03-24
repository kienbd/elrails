class HomeController < ApplicationController

  before_filter :signed_in_user?

  def welcome

  end

  def index

  end

  def elfinder
    h, r = ElFinder::Connector.new(
      :root => File.join(Rails.root, 'vendor', 'mounts',current_user.phash),
      :url => '/vendor/mounts/' + current_user.phash + "/",
      :home => current_user.email,
      :perms => {
        /pjkh\.png$/ => {:write => false, :rm => false},
        /\.txt$/ => {:write => true,:rm => true},
        '.' => {:read =>true,:write =>false,:rm => false},
	'/' => {:rm => false}
      },
      :extractors => {
        'application/zip' => ['unzip', '-qq', '-o'],
        'application/x-gzip' => ['tar', '-xzf'],
      },
      :archivers => {
        'application/zip' => ['.zip', 'zip', '-qr9'],
        'application/x-gzip' => ['.tgz', 'tar', '-czf'],
      },
      :disabled_commands => [:rm],
      :thumbs => true
    ).run(params)

    headers.merge!(h)
    render (r.empty? ? {:nothing => true} : {:text => r.to_json}), :layout => false
  end

  def thumbs
    thumb  = params[:id] + '.' + params[:format]
    send_file File.join(Rails.root,'vendor','mounts',current_user.phash,'.thumbs',thumb)
  end

  def previews
    send_file File.join(Rails.root,'vendor','mounts',params[:user_hash],params[:preview]) , disposition: 'inline'
  end

  def download
    send_file File.join(Rails.root,params[:target])
  end


  def createContainer
    path = File.join(Rails.root,'vendor','mounts',current_user.phash,params[:mount])
    if !File.directory? path
	    # FileUtils.mkdir(path) if !File.directory? path
	    container_name = current_user.phash + params[:mount]
	    `source "#{Rails.root.join('lib','bash','test.sh').to_s}" "#{current_user.email}" "#{container_name}" "#{path}"`
    else

    end
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
