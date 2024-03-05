# MudClub - Simple Rails app to manage a team sports club.
# Copyright (C) 2024  Iván González Angullo
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
module ClubsHelper
	# return title for @clubs GridComponent
	def club_grid
		title = [
			{kind: "normal", value: I18n.t("club.logo")},
			{kind: "normal", value: I18n.t("person.name")},
			{kind: "normal", value: I18n.t("person.contact")}
		]
		title << button_field({kind: "add", url: new_club_path, frame: "modal"}) if u_admin?

		rows = Array.new
		@clubs.each { |club|
			row = {url: club_path(club), items: []}
			row[:items] += [
				{kind: "icon", value: club.logo, align: "center"},
				{kind: "normal", value: club.nick},
				{kind: "contact", phone: club.phone, email: club.email, device: device}
			]
			row[:items] << button_field({kind: "delete", url: row[:url], name: club.to_s, align: "left"}) if (club != u_club && u_admin?)
			rows << row
		}
		{title:, rows:}
	end

	# FieldComponent fields for club links
	def club_links
		if @clubid == u_clubid	# user's club
			res = [
				[
					button_field({kind: "jump", icon: "player.svg", url: club_players_path(@club, rdx: 0), label: I18n.t("player.many")}, align: "center"),
					button_field({kind: "jump", icon: "coach.svg", url: club_coaches_path(@club, rdx: 0), label: I18n.t("coach.many")}, align: "center"),
					button_field({kind: "jump", icon: "team.svg", url: club_teams_path(@club, rdx: 0), label: I18n.t("team.many")}, align: "center")
				],
				[
					button_field({kind: "jump", icon: "rivals.svg", url: clubs_path(rdx: 0), label: I18n.t("club.rivals")}, align: "center"),
					button_field({kind: "jump", icon: "location.svg", url: club_locations_path(@club, rdx: 0), label: I18n.t("location.many")}, align: "center"),
					button_field({kind: "jump", icon: "timetable.svg", url: club_slots_path(@club, rdx: 0), label: I18n.t("slot.many")}, align: "center")
				]
			]
		else
			res = [[
				button_field({kind: "jump", icon: "team.svg", url: club_teams_path(@club, rdx: 0), label: I18n.t("team.many")}, align: "center"),
				button_field({kind: "jump", icon: "location.svg", url: club_locations_path(@club, rdx: 0), label: I18n.t("location.many")}, align: "center")
			]]
		end
		res
	end

	# FieldComponent fields to show a club
	def club_show_title(rows: 3, cols: 2)
		res = club_title_fields(title: @club.nick, icon: @club.logo, rows:, cols:)
		res << [{kind: "text", value: @club.name, cols:}]
		res << [{kind: "contact", phone: @club.phone, email: @club.email, device: device}]
		res
	end

	# return Club FieldsComponent @fields for forms
	def club_form_fields(title:, cols: 2)
		res = club_title_fields(title:, icon: @club.logo, rows: 3, cols:, form: true)
		res << [
			{kind: "icon", value: "user.svg", class: "align-top mr-1"},
			{kind: "text-box", key: :nick, value: @club.nick, placeholder: I18n.t("person.name")}
		]
		res << [
			gap_field(size:0),
			{kind: "text-box", key: :name, value: @club.name, size: 28, placeholder: I18n.t("club.entity")}
		]
		res << [
			{kind: "icon", value: "phone.svg", class: "align-top mr-1"},
			{kind: "text-box", key: :phone, size: 12, value: @club.phone, placeholder: I18n.t("person.phone"), cols: 2}
		]
		res << [
			{kind: "icon", value: "at.svg", class: "align-top mr-1"},
			{kind: "email-box", key: :email, value: @club.email, placeholder: I18n.t("person.email"), size: 34, cols: 2}
		]
		res << [
			{kind: "icon", value: "home.svg", class: "align-top mr-1"},
			{kind: "text-area", key: :address, size: 34, cols: 2, lines: 3, value: @club.address, placeholder: I18n.t("person.address")},
		]
	end

	# return icon and top of FieldsComponent
	def club_title_fields(title:, subtitle: nil, icon: "mudclub.svg", rows: 2, cols: nil, form: nil)
		title_start(icon:, title:, subtitle:, rows:, cols:, form:)
	end
end
