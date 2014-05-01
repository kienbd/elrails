class HomeController < ApplicationController

  before_filter :signed_in_user?,:except => [:auth]
  #before_filter CASClient::Frameworks::Rails::Filter,:except => [:auth,:dbticket,:welcome]
  #before_filter CASClient::Frameworks::Rails::GatewayFilter,:only => [:welcome]
  #before_filter :setup_cas_user,:except => [:auth,:dbticket]

  def setup_cas_user
      # save the login_url into an @var so that we can later use it in views (eg a login form)
      #@login_url = CASClient::Frameworks::Rails::Filter.login_url(self)
      return unless session[:cas_user].present?

      # so now we go find the user in our db
      @current_user = User.find_by_email(session[:cas_user])
      sign_in(@current_user) if @current_user.present?
  end

  def logout
    # optionally do some local cleanup here
    CASClient::Frameworks::Rails::Filter.logout(self,"http://localhost:3000")
  end

  def welcome
    redirect_to index_path if user_signed_in?
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

    email = request.headers["X-Auth-User"]
    password = request.headers["X-Auth-Pass"]

    # email = "user1@gmail.com"
    # password = "123456789"
    credentials = { :username => email, :password => password}

    # this will let you reuse existing config
    client = CASClient::Frameworks::Rails::Filter

    # pass in a URL to return-to on success
    @resp = client.login_to_service(self, credentials, "http://localhost:3000")

    respond_to do |format|
      format.json {
        if @resp.ticket.nil?
            render :text =>"Wrong email/password",:status => :unauthorized
        else
            user = User.find_by_email(email)
            path = File.join(Rails.root,'vendor','mounts',user.phash)
            render :text => path,:status => :ok
        end
      }
    end

    # email = request.headers["X-Auth-User"]
    # password = request.headers["X-Auth-Pass"]
    # user = User.find_by_email(email)
    # respond_to do |format|
      # format.json {
          # if user.nil?
              # render :text =>"Wrong email/password",:status => :unauthorized
        # return
          # end
          # if user.valid_password?(password)
        # path = File.join(Rails.root,'vendor','mounts',user.phash)
        # render :text => path,:status => :ok
        # return
          # else
        # render :text =>"Wrong email/password",:status => :unauthorized
        # return
          # end
      # }
    # end
  end


  def dbticket
    email = request.headers["X-User-Email"]
    #email = params[:email]
    user = User.new(:email => email,
                :password => Devise.friendly_token[10,20])
    respond_to do |format|
      format.json {
        if user.save
          render :text => "Success",:status => :ok
        else
          render :text => "Failed",:status => :error
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
