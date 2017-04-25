class JobsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :update, :edit, :destroy, :join, :quit]
  def index


    if params[:category].blank?
      @jobs = case params[:order]
      when 'by_lower_bound'
        Job.published.order('wage_lower_bound DESC')
      when 'by_upper_bound'
        Job.published.order('wage_upper_bound DESC')
      else
        Job.published.recent
      end
    else
        @category_id = Category.find_by(name: params[:category]).id
        @jobs = Job.where(:category_id => @category_id).recent
    end
  end

  def new
    @job = Job.new
  end

  def show
    @job = Job.find(params[:id])
    if @job.is_hidden
      flash[:warning] = "This Job already archieved"
      redirect_to root_path
    end
  end

  def edit
    @job = Job.find(params[:id])
  end

  def create
    @job = Job.new(job_params)

    if @job.save
      redirect_to jobs_path
    else
      render :new
    end
  end

  def update
    @job = Job.find(params[:id])
    if @job.update(job_params)
      redirect_to jobs_path, notice: 'Update Success'
    else
      render :edit
    end
  end

  def destroy
    @job = Job.find(params[:id])
    @job.destroy
      redirect_to jobs_path, alert: 'Job delete'
  end

  def join
    @job = Job.find(params[:id])
    if !current_user.is_member_of?(@job)
      current_user.join!(@job)
    end
    redirect_to job_path(@job)
  end

  def quit
    @job = Job.find(params[:id])
    if current_user.is_member_of?(@job)
      current_user.quit!(@job)
    end
    redirect_to job_path(@job)
  end

  private

  def job_params
    params.require(:job).permit(:title, :description, :wage_lower_bound,
     :wage_upper_bound, :contact_email, :is_hidden, :category_id)
  end

end
