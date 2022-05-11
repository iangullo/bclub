class CategoriesController < ApplicationController
  before_action :set_category, only: %i[ show edit update destroy ]

  # GET /categories or /categories.json
  def index
    if current_user.present? and current_user.admin?
      @categories = Category.real
      @fields     = header_fields(I18n.t(:l_cat_index))
      @g_head     = grid_header
      @g_rows     = grid_rows
    else
			redirect_to "/"
		end
  end

  # GET /categories/1 or /categories/1.json
  def show
    redirect_to "/" unless current_user.present? and current_user.admin?
    @fields = header_fields(I18n.t(:l_cat_index), cols: 5, rows: 5)
    @fields << [{kind: "subtitle", value: @category.age_group, cols: 3}, {kind: "subtitle", value: @category.sex, cols: 2}]
    @fields << [{kind: "label", value: I18n.t(:l_min)}, {kind: "string", value: @category.min_years}, {kind: "gap"}, {kind: "label", value: I18n.t(:l_max)}, {kind: "string", value: @category.max_years}]
  end

  # GET /categories/new
  def new
    if current_user.present? and current_user.admin?
      @category = Category.new
      @fields  = form_fields(I18n.t(:l_cat_new))
    else
      redirect_to "/"
    end
  end

  # GET /categories/1/edit
  def edit
    redirect_to "/" unless current_user.present? and current_user.admin?
    @fields = form_fields(I18n.t(:l_cat_edit))
  end

  # POST /categories or /categories.json
  def create
    if current_user.present? and current_user.admin?
      @category = Category.new(category_params)

      respond_to do |format|
        if @category.save
          format.html { redirect_to categories_url, notice: t(:cat_created) + "'#{@category.name}'" }
          format.json { render :index, status: :created, location: categories_url }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @category.errors, status: :unprocessable_entity }
        end
      end
    else
      redirect_to "/"
    end
  end

  # PATCH/PUT /categories/1 or /categories/1.json
  def update
    if current_user.present? and current_user.admin?
      respond_to do |format|
        if @category.update(category_params)
          format.html { redirect_to categories_url, notice: t(:cat_updated) + "'#{@category.name}'" }
          format.json { render :index, status: :ok, location: categories_url }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @category.errors, status: :unprocessable_entity }
        end
      end
    else
      redirect_to "/"
    end
  end

  # DELETE /categories/1 or /categories/1.json
  def destroy
    if current_user.present? and current_user.admin?
      c_name = @category.name
      prune_teams
      @category.destroy
      respond_to do |format|
        format.html { redirect_to categories_url, notice: t(:cat_deleted) + "'#{c_name}'" }
        format.json { head :no_content }
      end
    else
      redirect_to "/"
    end
  end

  private

  	# return icon and top of FieldsComponent
  	def header_fields(title, rows: 2, cols: nil)
  		[[{kind: "header-icon", value: "category.svg", rows: rows}, {kind: "title", value: title, cols: cols}]]
  	end

    # return FieldsComponent @header for forms
    def form_fields(title)
      res = header_fields(title, rows: 3, cols: 5)
      res << [{kind: "text-box", value: @category.age_group, size: 10, cols: 3}, {kind: "select-box", key: :sex, options: [I18n.t(:a_fem), I18n.t(:a_male), I18n.t(:a_mixed)], value: @category.sex, cols: 2}]
      res << [{kind: "label", value: I18n.t(:l_min)}, {kind: "number-box", key: :min_years}, {kind: "gap", size: 5}, {kind: "label", value: I18n.t(:l_max)}, {kind: "number-box", key: :max_years}]
      res
    end

    # return header for @categories GridComponent
    def grid_header
      res = [
        {kind: "normal", value: I18n.t(:h_name)},
        {kind: "normal", value: I18n.t(:h_sex)},
        {kind: "normal", value: I18n.t(:a_min)},
        {kind: "normal", value: I18n.t(:a_max)}
      ]
      res <<  {kind: "add", url: new_category_path, modal: true} if current_user.admin?
      res
    end

    # return content rows for @categories GridComponent
    def grid_rows
      res = Array.new
      @categories.each { |cat|
        row = {url: edit_category_path(cat), modal: true, items: []}
        row[:items] << {kind: "normal", value: cat.age_group}
        row[:items] << {kind: "normal", value: cat.sex}
        row[:items] << {kind: "normal", value: cat.min_years, align: "right"}
        row[:items] << {kind: "normal", value: cat.max_years, align: "right"}
        row[:items] << {kind: "delete", url: category_path(cat), name: cat.name} if current_user.admin?
        res << row
      }
      res
    end

    # prune teams from a category to be deleted
    def prune_teams
      @category.teams.each { |t|
        t.category=Category.find(0)  # de-allocate teams
        t.save
      }
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_category
      @category = Category.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def category_params
      params.require(:category).permit(:age_group, :sex, :min_years, :max_years)
    end
end
