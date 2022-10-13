class DrillsController < ApplicationController
	include Filterable
	before_action :set_drill, only: [:show, :edit, :update, :destroy]
	skip_before_action :verify_authenticity_token, :only => [:create, :new, :edit, :update, :check_reload]

	# GET /drills or /drills.json
	def index
		check_access(roles: [:admin, :coach])
		# Simple search by name/description for now
		@title  = helpers.drill_title_fields(title: I18n.t("drill.many"))
		#@title << [{kind: "subtitle", value: I18n.t("catalog")}]
		@search = helpers.drill_search_bar(search_in: drills_path)
		@drills = filter!(Drill)
		@grid   = helpers.drill_grid(drills: @drills)
	end

	# GET /drills/1 or /drills/1.json
	def show
		check_access(roles: [:admin, :coach])
		@title   = helpers.drill_show_title(title: I18n.t("drill.single"), drill: @drill)
		@intro   = helpers.drill_show_intro(drill: @drill)
		@explain = [[{kind: "string", value: @drill.explanation}]]
		@tail    = helpers.drill_show_tail(drill: @drill)
	end

	# GET /drills/new
	def new
		check_access(roles: [:admin, :coach])
		@drill = Drill.new
		prepare_form(title: I18n.t("drill.new"))
	end

	# GET /drills/1/edit
	def edit
		check_access(roles: [:admin], obj: @drill, returl: drills_url)
		prepare_form(title: I18n.t("drill.edit"))
	end

	# POST /drills or /drills.json
	def create
		check_access(roles: [:admin, :coach])
		respond_to do |format|
			@drill = Drill.new
			@drill.rebuild(drill_params)	# rebuild drill
			if @drill.save
				format.html { redirect_to drills_url, notice: helpers.flash_message("#{I18n.t("drill.created")} '#{@drill.name}'", "success"), data: {turbo_action: "replace"} }
				format.json { render :index, status: :created, location: @drill }
			else
				format.html { render :new }
				format.json { render json: @drill.errors, status: :unprocessable_entity }
			end
		end
	end

	# PATCH/PUT /drills/1 or /drills/1.json
	def update
		check_access(roles: [:admin], obj: @drill, returl: drills_url)
		respond_to do |format|
			@drill.rebuild(drill_params)	# rebuild drill
		 	if @drill.save
				format.html { redirect_to drill_path, status: :see_other, notice: helpers.flash_message("#{I18n.t("drill.updated")} '#{@drill.name}'", "success"), data: {turbo_action: "replace"} }
				format.json { render :show, status: :ok, location: @drill }
			else
				format.html { render :edit, status: :unprocessable_entity }
				format.json { render json: @drill.errors, status: :unprocessable_entity }
			end
		end
	end

	# DELETE /drills/1 or /drills/1.json
	def destroy
		check_access(roles: [:admin])
		d_name = @drill.name
		@drill.drill_targets.each { |d_t| d_t.delete }
		@drill.destroy
		respond_to do |format|
			format.html { redirect_to drills_url, notice: helpers.flash_message("#{I18n.t("drill.deleted")} '#{d_name}'"), data: {turbo_action: "replace"} }
			format.json { head :no_content }
		end
	end

	private
		# prepare a drill form calling helpers to get the right FieldComponents
		def prepare_form(title:)
			@title    = helpers.drill_form_title(title:, drill: @drill)
			@playbook = helpers.drill_form_playbook(playbook: @drill.playbook)
			@formdata = helpers.drill_form_data(drill: @drill)
			@explain  = helpers.drill_form_explain
			@author   = helpers.drill_form_author(drill: @drill)
		end

		# Use callbacks to share common setup or constraints between actions.
		def set_drill
			@drill = Drill.find(params[:id]) unless @drill.try(:id)==params[:id]
		end

		# Only allow a list of trusted parameters through.
		def drill_params
			params.require(:drill).permit(:name, :material, :description, :coach_id, :explanation, :playbook, :kind_id, :skill_id, skills: [], target_ids: [], skill_ids: [], skills_attributes: [:id, :concept, :_destroy], drill_targets_attributes: [:id, :priority, :drill_id, :target_id, :_destroy, target_attributes: [:id, :aspect, :focus, :concept]])
		end
end
