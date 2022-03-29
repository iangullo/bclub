class TrainingSlotsController < ApplicationController
  skip_before_action :verify_authenticity_token, :only => [:create, :new, :update, :check_reload]
  before_action :set_training_slot, only: [:show, :edit, :update, :destroy]


  # GET /training_slots or /training_slots.json
  def index
    if current_user.present?
      @training_slots = TrainingSlot.search(params[:location_id], params[:team_id])
    else
      redirect_to "/"
    end
  end

  # GET /training_slots/1 or /training_slots/1.json
  def show
    unless current_user.present?
      redirect_to "/"
    end
  end

  # GET /training_slots/new
  def new
    if current_user.present? and current_user.admin?
      @training_slot = TrainingSlot.new(season_id: 1, location_id: 1, wday: 1, start: Time.new(2000,1,1,16,00), duration: 90, team_id: 0)
  		@weekdays = weekdays
    else
      redirect_to(current_user.present? ? training_slots_url : "/")
    end
  end

  # GET /training_slots/1/edit
  def edit
		@weekdays = weekdays
  end

  # POST /training_slots or /training_slots.json
  def create
    if current_user.present? and current_user.admin?
      @training_slot = TrainingSlot.new(season_id: 1, location_id: 1, wday: 1, start: Time.new(2000,1,1,16,00), duration: 90, team_id: 0)

      respond_to do |format|
  			rebuild_training_slot(params)	# rebuild training_slot
        if @training_slot.save
          format.html { redirect_to training_slots_url, notice: "Horario creado." }
          format.json { render :index, status: :created, location: @training_slot }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @training_slot.errors, status: :unprocessable_entity }
        end
      end
    else
      redirect_to(current_user.present? ? training_slots_url : "/")
    end
  end

  # PATCH/PUT /training_slots/1 or /training_slots/1.json
  def update
    if current_user.present? and current_user.admin?
      respond_to do |format|
  			rebuild_training_slot(params)
        if @training_slot.update(training_slot_params)
        format.html { redirect_to training_slots_url, notice: "Horario actualizado." }
          format.json { render :index, status: :ok, location: @training_slot }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @training_slot.errors, status: :unprocessable_entity }
        end
      end
    else
      redirect_to(current_user.present? ? training_slots_url : "/")
    end
  end

  # DELETE /training_slots/1 or /training_slots/1.json
  def destroy
    if current_user.present? and current_user.admin?
      set_training_slot(params)
      @training_slot.destroy
      respond_to do |format|
        format.html { redirect_to training_slots_url, notice: "Training slot was successfully destroyed." }
        format.json { head :no_content }
      end
    else
      redirect_to(current_user.present? ? training_slots_url : "/")
    end
  end

	# returns an array with weekday names and their id
	def weekdays
		[["Lunes", 1], ["Martes", 2], ["Miércoles", 3], ["Jueves", 4], ["Viernes", 5]]
	end

  private
		# build new @training_slot from raw input given by submittal from "new"
		# return nil if unsuccessful
		def rebuild_training_slot(params)
			p_data = params.fetch(:training_slot)
			@training_slot.season_id   = p_data[:season_id]
			@training_slot.location_id = p_data[:location_id]
			@training_slot.wday        = p_data[:wday]
			@training_slot.team_id     = p_data[:team_id]
			@training_slot.hour        = p_data[:hour]
			@training_slot.min         = p_data[:min]
			@training_slot.duration    = p_data[:duration]
			@training_slot
		end

    # Use callbacks to share common setup or constraints between actions.
    def set_training_slot(params)
      @training_slot = TrainingSlot.find(params[:id]) unless @training_slot.try(:id)==params[:id]
    end

    # Only allow a list of trusted parameters through.
    def training_slot_params
      params.require(:training_slot).permit(:season_id, :location_id, :team_id, :wday, :start, :duration, :hour, :min)
    end
end
