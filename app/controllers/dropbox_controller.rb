class DropboxController < ApplicationController
  def incoming
    if params[:challenge]
      render text: params[:challenge]
      return
    end

    params[:delta][:users].each do |uid|
      @existing_job = Sidekiq::ScheduledSet.new.find do |x|
        next if x.args.empty?
        x.args.first == [DropboxHookWorker, :perform_async, [uid]].to_yaml
      end
      @existing_job.delete if @existing_job

      DropboxHookWorker.perform_in(30.seconds, uid)
    end

    head :ok
  end
end