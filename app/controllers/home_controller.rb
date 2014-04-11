class HomeController < ApplicationController

  before_filter :signed_in_user?,:except => [:auth]
  #before_filter CASClient::Frameworks::Rails::Filter,:except => [:auth,:welcome]
  #before_filter CASClient::Frameworks::Rails::GatewayFilter,:only => [:welcome]
  #before_filter :setup_cas_user,:except => [:auth]

  def setup_cas_user
      # save the login_url into an @var so that we can later use it in views (eg a login form)
      #@login_url = CASClient::Frameworks::Rails::Filter.login_url(self)
      return unless session[:cas_user].present?

      # so now we go find the user in our db
      @current_user = User.find_by_email(session[:cas_user])
      sign_in(@current_user) if @current_user.present?
  end

   def cas_login
    credentials = { :username => params[:login], :password => params[:password]}

    # this will let you reuse existing config
    client = CASClient::Frameworks::Rails::Filter

    # pass in a URL to return-to on success
    @resp = client.login_to_service(self, credentials, dashboard_url)
    if @resp.is_failure?
      # if login failed, redisplay the page that has your login-form on it
      flash.now[:error] = "That username or password was not recognised. Please try again."
      @user = User.new
      render :action => 'new'
    else
      # login_to_service has appended the new ticket onto the given URL
      # so we redirect the user there to complete the login procedure
      return redirect_to(@resp.service_redirect_url)
    end
  end

  def welcome

  end

  def index

  end


  def install

  end

  def elfinder
    path = File.join(Rails.root,'vendor','mounts',current_user.phash)
    while !File.directory? path do
      sleep(0.5)
    end
    if File.directory? path
    h, r = ElFinder::Connector.new(
      :root => File.join(Rails.root, 'vendor', 'mounts',current_user.phash),
      :url => '/vendor/mounts/' + current_user.phash + "/",
      :home => current_user.email,
      :perms => {
        /pjkh\.png$/ => {:write => false, :rm => false},
        /\.txt$/ => {:write => true,:rm => true},
        '.' => {:read =>true,:write =>false,:rm => false,:delete => false},
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
      :thumbs => true
    ).run(params)

    headers.merge!(h)
    render (r.empty? ? {:nothing => true} : {:text => r.to_json}), :layout => false
    else
     redirect_to root_path
    end
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


  def auth
    binding.pry
    email = request.headers["X-Auth-User"]
    password = request.headers["X-Auth-Pass"]
    user = User.find_by_email(email)
    respond_to do |format|
      format.json {
          if user.nil?
              render :text =>"Wrong email/password",:status => :unauthorized
        return
          end
          if user.valid_password?(password)
        path = File.join(Rails.root,'vendor','mounts',user.phash)
        render :text => path,:status => :ok
        return
          else
        render :text =>"Wrong email/password",:status => :unauthorized
        return
          end
      }
    end
  end


  def signed_in_user?
    unless user_signed_in?
      redirect_to new_user_registration_path
    end
  end

end
