require 'ezcrypto'
class FoldersController < ApplicationController
  include ImapUtils

  before_filter :login_required
  before_filter :load_imap_session
  after_filter  :close_imap_session

  layout 'public'

  def index
    @folders = @mailbox.folders
  end

  def create
    @mailbox.create_folder(CDF::CONFIG[:mail_inbox] + '.' + params[:folder])
    redirect_to folders_path
  end

  def destroy
    @mailbox.delete_folder params[:id]
    redirect_to folders_path
  end
end
