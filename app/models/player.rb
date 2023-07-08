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
class Player < ApplicationRecord
	include PersonDataManagement
	attr_accessor :parent_changed
	before_destroy :unlink
	after_initialize :set_changes_flag
	has_one :person
	has_one_attached :avatar
	has_many :stats, dependent: :destroy
	has_and_belongs_to_many :teams
	has_and_belongs_to_many :events
	has_and_belongs_to_many :parents
	accepts_nested_attributes_for :person, update_only: true
	accepts_nested_attributes_for :parents, reject_if: :all_blank, allow_destroy: true
	accepts_nested_attributes_for :stats, reject_if: :all_blank, allow_destroy: true
	scope :real, -> { where("id>0") }
	scope :active, -> { where("active = true") }
	scope :female, -> { joins(:person).where("female = true") }
	scope :male, -> { joins(:person).where("female = false") }
	self.inheritance_column = "not_sti"
	FILTER_PARAMS = %i[search].freeze

	# Just list person's full name
	def to_s
		self.person ? self.person.to_s : I18n.t("player.single")
	end

	#short name for form viewing
	def s_name
		self.person ? self.person.s_name : I18n.t("player.single")
	end

	# String with number, name & age
	def num_name_age
		number.to_s.rjust(7," ") + "-" + self.to_s + " (" + self.person.age.to_s + ")"
	end

	def female
		self.person.female
	end

	# get attendance data for player over the period specified by "during"
	# returns attendance inthe form of:
	# matches played and session attendance [%] for week, month and season
	def attendance(team:)
		l_week   = {tot: 0, att: 0}
		l_month  = {tot: 0, att: 0}
		l_season = {tot: 0, att: 0}
		matches  = 0
		d_last7  = Date.today - 7
		d_last30 = Date.today - 30
		team.events.normal.this_season.past.each do |event|
			if event.train?
				l_season[:tot] = l_season[:tot] + 1
				l_week[:tot]   = l_week[:tot] + 1 if event.start_date > d_last7
				l_month[:tot]  = l_month[:tot] + 1 if event.start_date > d_last30
			end
			if event.players.include?(self)
				if event.match?
					matches = matches + 1
				elsif event.train?
					l_season[:att] = l_season[:att] + 1
					l_week[:att]   = l_week[:att] + 1 if event.start_date > d_last7
					l_month[:att]  = l_month[:att] + 1 if event.start_date > d_last30
				end
			end
		end
		att_week  = l_week[:tot]>0 ? (l_week[:att]*100/l_week[:tot]).to_i : nil
		att_month = l_month[:tot]>0 ? (l_month[:att]*100/l_month[:tot]).to_i : nil
		att_total = l_season[:tot]>0 ? (100*l_season[:att]/l_season[:tot]).to_i : nil
		{matches: matches, last7: att_week, last30: att_month, avg: att_total}
	end

	# Player picture
	def picture
		self.avatar.attached? ? self.avatar : self.person.avatar.attached? ? self.person.avatar : "player.svg"
	end

	# Return email/phone of player or of the associated tutors if underage players
	def p_email
		if self.person.age < 18
			email = ""
			self.parents.each { |par| email += "#{par.person.email.presence}\n" if par.person.email.present?}
			email
		else
			self.person.email.presence
		end
	end

	def p_phone
		if self.person.age < 18
			phone = ""
			self.parents.each { |par| phone += "#{par.person.phone.presence}\n" if par.person.phone.present?}
			phone
		else
			self.person.phone.presence
		end
	end

	# Apply filters to player collection
	def self.filter(filters)
		self.search(filters[:search]).order(:name)
	end

	#Search field matching
	def self.search(search)
		if search.present?
			Player.where(person_id: Person.where(["(id > 0) AND (unaccent(name) ILIKE unaccent(?) OR unaccent(nick) ILIKE unaccent(?) OR unaccent(surname) ILIKE unaccent(?))","%#{search}%","%#{search}%","%#{search}%"]).order(:birthday))
		else
			Player.none
		end
	end

	# atempt to fetch a Player using form input hash
	def self.fetch(f_data)
		self.new.fetch_obj(f_data)
	end

	# to import from excel
	def self.import(file)
		xlsx = Roo::Excelx.new(file.tempfile)
		xlsx.each_row_streaming(offset: 1, pad_cells: true) do |row|
			if row.empty?	# stop parsing if row is empty
				return
			else
				j = self.new(number: row[1].value.to_s.strip, active: row[9].value)
				j.import_person_row( # import personal data
					[
						row[0],	# dni
						row[3],	# name
						row[4],	# surname
						row[2],	# nick
						row[5],	# birthday
						row[7],	# email
						row[8], # phone
						row[6]	# female
					]
				)
				if j.person	# only if person exists
					j.active = j.read_field(to_boolean(row[9].value), j.active, false)
					j.save
				end
			end
		end
	end

	# Is this player included in an event?
	def present?(event_id)
		self.events.include?(event_id)
	end

	# rebuild Player data from raw input hash given by a form submittal
	# avoids duplicate person binding
	def rebuild(f_data)
		self.rebuild_obj_person(f_data)
		if self.person # person exists
			self.number = f_data[:number]
			self.active = f_data[:active]
			self.check_parents(f_data[:parents_attributes])
		end
	end

	def set_changes_flag
		@parent_changed = false
	end

	# extended modified to acount for changed parents
	def modified?
		super || @parent_changed
	end

	private
		# checks parents array received and manages adding/removing
		# from the drill collection - remove duplicates from list
		def check_parents(s_array)
			if s_array
				a_parents = Array.new	# array to include only non-duplicates
				s_array.each { |s| a_parents << s[1] }	# first pass - get inputs
				a_parents.each do |p_input| # second pass - manage associations
					parent = Parent.fetch(p_input)	# attempt to fetch (or create a new parent)
					if p_input[:_destroy] == "1"
						self.parents.delete(parent)
					else	# add to collection
						parent = Parent.new unless parent
						parent.rebuild(p_input)
						@parent_changed = parent.save if parent.changed? || parent.person.changed?
						parent.person.update!(person_id: parent.id) unless parent.person.parent_id == parent.id
						self.parents << parent unless self.parents.include?(parent)
					end
				end
			end
		end

		# cleanup association of dependent objects
		def unlink
			self.person.update(player_id: 0)
			self.teams.delete_all
			self.events.delete_all
			self.parents.delete_all
			self.avatar.purge if self.avatar.attached?
			self.person.destroy if self.person&.orphan?
		end
end
