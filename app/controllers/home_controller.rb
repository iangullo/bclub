# MudClub - Simple Rails app to manage a team sports club.
# Copyright (C) 2023  Iván González Angullo
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
# contact email - iangullo@gmail.com.
#
class HomeController < ApplicationController
	def index
		if current_user.present?
			title   = helpers.home_title_fields
			title << [{kind: "gap"}]
			@fields = create_fields(title)
			teams   = helpers.team_grid(teams: current_user.teams.order(:season_id)) if current_user.teams
			@grid   = create_grid(teams) if teams
		end
	end

	def edit
		check_access(roles: [:admin])
		@club   = Person.find(0)
		@fields = create_fields(helpers.home_form_fields(club: @club))
		@f_logo = create_fields(helpers.form_file_field(label: I18n.t("person.pic"), key: :avatar, value: @club.avatar.filename))
		@submit = create_submit
	end
end
