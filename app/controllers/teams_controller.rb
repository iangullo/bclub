class TeamsController < ApplicationController
	skip_before_action :verify_authenticity_token, :only => [:create, :edit, :new, :update, :check_reload]
	before_action :set_team, only: [:index, :show, :show, :edit, :edit_roster, :edit_coaches, :new, :update, :destroy]

  # GET /teams
  # GET /teams.json
  def index
		if current_user.present? and (current_user.admin? or current_user.is_coach? or current_user.is_player?)
		else
			redirect_to "/"
		end
  end

  # GET /teams/1
  # GET /teams/1.json
  def show
		unless current_user.present? and (current_user.admin? or current_user.is_coach? or @team.has_coach(current_user.person.coach_id) or @team.has_player(current_user.person.player_id))
			redirect_to "/"
		end
  end

  # GET /teams/new
  def new
		if current_user.present? and current_user.admin?
    	@team = Team.new
		else
			redirect_to(current_user.is_coach? ? teams_path : "/")
		end
  end

  # GET /teams/1/edit
  def edit
		if current_user.present?
			if current_user.admin? or @team.has_coach(current_user.person.coach_id)
			else
				redirect_to @team
			end
		else
			redirect_to "/"
		end
  end

	# GET /teams/1/edit_roster
  def edit_roster
		if current_user.present?
			if current_user.admin? or @team.has_coach(current_user.person.coach_id)
    		@eligible_players = @team.eligible_players
			else
				redirect_to @team
			end
		else
			redirect_to "/"
		end
  end

	# GET /teams/1/edit_coaches
  def edit_coaches
		if current_user.present?
			if current_user.admin? or @team.has_coach(current_user.person.coach_id)
    		@eligible_coaches = Coach.active
			else
				redirect_to @team
			end
		else
			redirect_to "/"
		end
  end

  # POST /teams
  # POST /teams.json
  def create
		if current_user.present? and current_user.admin?
		  @team = Team.new(team_params)

	    respond_to do |format|
	      if @team.save
	        format.html { redirect_to teams_path, notice: 'Equipo creado.', action: :index }
	        format.json { render :index, status: :created, location: teams_path }
	      else
	        format.html { render :new }
	        format.json { render json: @team.errors, status: :unprocessable_entity }
	      end
	    end
		else
			redirect_to(current_user.is_coach? ? teams_path : "/")
		end
  end

  # PATCH/PUT /teams/1
  # PATCH/PUT /teams/1.json
  def update
		if current_user.present?
			if current_user.admin? or @team.has_coach(current_user.person.coach_id)
		    respond_to do |format|
		      if @team.update(team_params)
						format.html { redirect_to @team, action: :show }
		        format.json { render :show, status: :created, location: teams_path(@team) }
		      else
		        format.html { render :edit }
		        format.json { render json: @team.errors, status: :unprocessable_entity }
		      end
		    end
			else
				redirect_to(current_user.is_coach? ? teams_path : "/")
			end
		else
			redirect_to "/"
		end
  end

  # DELETE /teams/1
  # DELETE /teams/1.json
  def destroy
		if current_user.present? and current_user.admin?
	    @team.destroy
	    respond_to do |format|
	      format.html { redirect_to teams_path, notice: 'Equipo borrado.' }
	      format.json { head :no_content }
	    end
		else
			redirect_to "/"
		end
  end

  private
	# Use callbacks to share common setup or constraints between actions.
	def set_team
		@teams = Team.search(params[:season_id])
		@team = Team.find(params[:id]) if params[:id]
	end

	# Never trust parameters from the scary internet, only allow the white list through.
	def team_params
		params.require(:team).permit(:id, :name, :category_id, :division_id, :season_id, :homecourt_id, :coaches, :players, coaches_attributes: [:id], coach_ids: [], player_ids: [], players_attributes: [:id], targets: [], team_targets: [])
	end
end
