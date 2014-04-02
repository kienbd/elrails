class FileMapsController < ApplicationController

  def create
    file = FileMap.new
    file.user_id = current_user.id
    file.phash = params[:hash]
    file.remote_url = params[:url]
    file.file_name = params[:file_name]

    if file.save
      respond_to do |format|
        format.js
      end
    end

  end


  def update


  end


  def show
    @file = FileMap.find_by_phash(params[:id])
  end



end
