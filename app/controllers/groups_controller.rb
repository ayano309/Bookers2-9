class GroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :correct_user, only:[:edit, :update]
  
  def index
    @book = Book.new
    @groups = Group.all
  end
  
  def show
    @book = Book.new
    @group = Group.find(params[:id])
  end

  
  def new
    @group = Group.new
  end
  
  
  def create
    @group = Group.new(group_params)
    #groupの作成者のIDを代入する
    @group.owner_id = current_user.id
    #この記述をしないとグループ作成者がgroupに含まれない
    #groupのユーザにグループ作成者をpush(追加)している
    @group.users << current_user
    
    if @group.save
      redirect_to groups_path
    else
      render :new
    end
  end
  
  
  def edit
    @group = Group.find(params[:id])
  end
  
  
  def update
    @group = Group.find(params[:id])
    if @group.update(group_params)
      redirect_to groups_path
    else
      render :edit
    end
    
  end
  
  #グループ参加
  def join
    #ネストしたからparams[:group]
    @group = Group.find(params[:group_id])
    @group.users << current_user
    redirect_to groups_path
  end
  
  #leave
  def destroy
    @group = Group.find(params[:id])
    #current_userは、@group.users=参加グループから退会する
    @group.users.delete(current_user)
    redirect_to groups_path
  end
  
  #mail/new
  def new_mail
    @group = Group.find(params[:group_id])
  end
  
  #mail/create
  def send_mail
    @group = Group.find(params[:group_id])
    group_users = @group.users
    #formで送られてくる
    @mail_title = params[:mail_title]
    @mail_content = params[:mail_content]
    ContactMailer.send_mail(@mail_title,@mail_content,group_users).deliver
  end
  
  
  private
  
  def group_params
    params.require(:group).permit(:name, :introduction, :image)
  end
  
  def correct_user
    @group = Group.find(params[:id])
    unless @group.owner_id == current_user.id
      redirect_to groups_path
    end
  end
  
end
