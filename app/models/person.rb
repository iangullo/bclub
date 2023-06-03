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
class Person < ApplicationRecord
	before_destroy :unlink
	belongs_to :coach
	belongs_to :player
	belongs_to :user
	has_one_attached :avatar
	accepts_nested_attributes_for :player
	accepts_nested_attributes_for :coach
	accepts_nested_attributes_for :user
	validates :name, :surname, presence: true
	scope :real, -> { where("id>0") }
	before_save { self.name = self.name ? self.name.mb_chars.titleize : ""}
	before_save { self.surname = self.surname ? self.surname.mb_chars.titleize : ""}
	self.inheritance_column = "not_sti"

	def to_s(long=true)
		if self.nick and self.nick.length > 0
			aux = self.nick.to_s
		else
			aux = self.name.to_s
		end
		aux += " " + self.surname.to_s if long
		aux
	end

	#short name for form viewing
	def s_name
		res = self.to_s(false)
		res.length > 0 ? res : I18n.t("person.single")
	end

	# checks if it exists in the collection before adding it
	# returns: reloads self if it exists in the database already
	# 	   'nil' if it needs to be created.
	def exists?
		if self.dni and self.dni!="" # not null, let's search by that unique field
			p_aux = Person.where(dni: self.dni)
		elsif self.email and self.email!=""	# another unique field is email
			p_aux = Person.where(email: self.email)
		else	# we search by name/surname since no unique fields are there
			p_aux = Person.where(name: self.name, surname: self.surname)
		end
		if p_aux.try(:size)==1
			self.id = p_aux.first.id
			self.reload
		else
			nil
		end
	end

	# rebuild Person data from raw input (as hash) given by a form submittal
	# avoids creating duplicates
	def rebuild(p_data)
		p_aux         = Person.new # check for duplicates
		p_aux.dni     = p_data[:dni] if p_data[:dni]
		p_aux.email   = p_data[:email] if p_data[:email]
		p_aux.name    = p_data[:name] if p_data[:name]
		p_aux.surname = p_data[:surname] if p_data[:surname]
		if p_aux.exists?	# re-assign if exists
			self.id=p_aux.id
			self.reload
		end
		self.dni       = p_data[:dni] if p_data[:dni]
		self.email     = p_data[:email] if p_data[:email]
		self.name      = p_data[:name] if p_data[:name]
		self.surname   = p_data[:surname] if p_data[:surname]
		self.birthday  = p_data[:birthday] if p_data[:birthday]
		self.nick      = p_data[:nick] if p_data[:nick]
		self.female    = p_data[:female]
		self.phone     = Phonelib.parse(p_data[:phone]).international.to_s  if p_data[:phone]
		self.coach_id  = 0 unless self.coach_id.to_i > 0
		self.player_id = 0 unless self.player_id.to_i > 0
	end

	# calculate age
	def age
		if self.birthday
			now = Time.now.utc.to_date
			bday=self.birthday
			now.year - bday.year - ((now.month > bday.month || (now.month == bday.month && now.day >= bday.day)) ? 0 : 1)
		else
			0
		end
	end

	# personal logo
	def picture
		self.avatar.attached? ? self.avatar : "person.svg"
	end

	# used for clublogo (Person(id: 0))
	def logo
		self.avatar.attached? ? self.avatar : "clublogo.svg"
	end

	# Checks parent is linked well - saves if changed
	def bind_parent(o_class:, o_id:)
		if o_class and o_id
			case o_class
			when "Coach"
				field = :coach_id
			when "Player"
				field = :player_id
			when "User"
				field = :user_id
			end

			self[field] = o_id if  self[field] != o_id
			self.save if self.changed?
			return true
		end
		return false
	end

	# to import from excel
	def self.import(file)
		xlsx = Roo::Excelx.new(file.tempfile)
		xlsx.each_row_streaming(offset: 1, pad_cells: true) do |row|
			if row.empty?	# stop parsing if row is empty
				return
			else
				p = self.new(name: row[2].value.to_s, surname: row[3].value.to_s)
				unless p.exists?
					p.player_id = 0
					p.coach_id = 0
				end
				p.dni      = p.read_field(row[0], p.dni, I18n.t("person.pid"))
				p.nick     = p.read_field(row[1], p.nick, "")
				p.birthday = p.read_field(row[4], p.birthday, Date.today.to_s)
				p.female   = p.read_field(row[5], p.female, false)
				p.email		 = p.read_field(row[6], p.email, "")
				p.phone		 = p.read_field(Phonelib.parse(row[7]).international, p.phone, "")
				p.save
			end
		end
	end

	#Search field matching
	def self.search(search)
		if search
			search.length>0 ? Person.where(["(id > 0) AND (unaccent(name) ILIKE unaccent(?) OR unaccent(nick) ILIKE unaccent(?) OR unaccent(surname) ILIKE unaccent(?))","%#{search}%","%#{search}%","%#{search}%"]) : Person.none
		else
			Person.none
		end
	end

	private
		# unlink/delete dependent objects
		def unlink
			gen_unlink(:coach) if @person.coach_id > 0	# delete associated coach
			gen_unlink(:player) if @person.player_id > 0	# delete associated player
			gen_unlink(:user) if @person.user_id > 0	# delete associated user
		end

		# called by unlink using either :coach, :player or :user as arguments
		def gen_unlink(kind)
			dep = self.try(kind.to_sym)
			if dep
				self.update!("#{kind_id}".to_sym 0)
				dep.destroy
			end
		end
end
