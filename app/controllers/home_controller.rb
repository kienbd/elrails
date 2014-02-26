class HomeController < ApplicationController

  def index
  end

  def elfinder
    h, r = ElFinder::Connector.new(
      :root => File.join(Rails.root, 'vendor', 'mounts'),
      :url => '/vendor/mounts',
      :perms => {
        /pjkh\.png$/ => {:write => false, :rm => false},
        /\.txt$/ => {:write => true,:rm => true}
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
    binding.pry

  end

end
