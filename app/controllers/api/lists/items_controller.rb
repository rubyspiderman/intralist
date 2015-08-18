#TODO: adding/removing a picture
# class Api::Lists::ItemsController < Api::BaseController
  # before_filter :authenticate_user!
  # #TODO: test

  # def create
    # #Does angular wrap these things? Parse args individually?
    # params[:item][:user_id] = current_user.id
    # item = Item.new(params[:item])
    # status = item.save ? 201 : 400
    # head status
  # end

  # def update
    # params = params[:item]

    # list = List.where(:list_id => params.delete("list_id"),
                      # :user_id => current_user.id).first
    # head 404 unless list

    # item = list.items.find(params.delete('id'))
    # item.content = params[:content]
    # status = item.save ? 201 : 400
    # head status
  # end

  # def destroy
    # list = List.where(:list_id => params[:list_id],
                      # :user_id => current_user.id).first
    # head 404 unless list

    # item = list.items.find(params[:id])
    # status = item.destroy ? 200 : 400
    # head status
  # end
# end
