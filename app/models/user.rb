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
class User < ApplicationRecord
	# Include default devise modules. Others available are:
	# :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
	devise :database_authenticatable, :registerable,
				 :recoverable, :rememberable, :validatable
	has_one :person
	has_one_attached :avatar
	scope :real, -> { where("id>0") }
	enum role: [:user, :player, :coach, :admin]
	after_initialize :set_default_role, :if => :new_record?
	accepts_nested_attributes_for :person, update_only: true
	self.inheritance_column = "not_sti"

	# Include default devise modules. Others available are:
	# :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
	devise :registerable, :database_authenticatable, :recoverable, :rememberable, :validatable

	# Just list person's full name
	def to_s
		person ? person.to_s : I18n.t("user.single")
	end

	def self.role_list
		User.roles.keys.map {|role| [I18n.t("role.#{role}"),role]}
	end

	#short name for form viewing
	def s_name
		if self.person
			if self.person.nick
				self.person.nick.length >  0 ? self.person.nick : self.person.name
			else
				self.person.name
			end
		else
			I18n.t("user.single")
		end
	end

	# checks if it exists in the collection before adding it
	# returns: reloads self if it exists in the database already
	# 	   'nil' if it needs to be created.
	def exists?
		p = User.where(email: self.email).first
		if p
			self.id = p.id
			self.reload
		else
			nil
		end
	end

	# check if associated person exists in database already
	# reloads person if it does
	def is_duplicate?
		if self.person.exists? # check if it exists in database
			if self.person.user_id > 0 # user already exists
				true
			else	# found but mapped to dummy placeholder user
				false
			end
		else	# not found
			false
		end
	end

	def picture
		self.avatar.attached? ? self.avatar : "user.svg"
	end

	#Search field matching
	def self.search(search)
		if search
			search.length>0 ? User.where(person_id: Person.where(["(id > 0) AND (name LIKE ? OR nick like ?)","%#{search}%","%#{search}%"])) : User.where(person_id: Person.real)
		else
			User.real
		end
	end

	def is_player?
		(self.person.try(:player_id).to_i > 0 and self.person.player.active) or self.player?
	end

	def is_coach?
		(self.person.try(:coach_id).to_i > 0 and self.person.coach.active) or self.coach?
	end

	def coach
		(self.person.try(:coach_id).to_i > 0) ? self.person.coach : nil
	end

	def player
		(self.person.try(:player_id).to_i > 0) ? self.person.player : nil
	end

	def set_default_role
		self.role ||= :user
	end

	# rebuild User data from raw input hash given by a form submittal
	# avoids duplicate person binding
	def rebuild(u_data)
		p_data        = u_data[:person_attributes]
		self.email    = u_data[:email] ? u_data[:email] : p_data[:email]
		self.role     = u_data[:role] ? u_data[:role] : :user
		self.password = u_data[:password] if u_data[:password]
		self.password_confirmation = u_data[:password_confirmation] if u_data[:password_confirmation]
		if self.person_id==0 # not bound to a person yet?
			self.person = p_data[:id].to_i > 0 ? Person.find(p_data[:id].to_i) : self.build_person
		else # person is linked, get it
			self.person.reload
		end
		self.person.rebuild(p_data) # rebuild from passed data
		self.person.user_id = self.id if self.id
		self.person_id = self.person.id if self.person.id
		if self.player? and self.person.player_id.to_i==0 # Bound to a player?
			self.person.player = Player.new(active: true, number: 0, person_id: self.person_id)
		end
		if self.coach? and self.person.coach_id.to_i==0 # need to create a Coach?
			self.person.coach = Coach.new(active: true, person_id: self.person_id)
		end
	end

	# get teams associated to this user
	def teams
		if self.is_coach?
			Team.joins(:coaches).where(coaches: { id: [self.person.coach_id] })
		elsif self.is_player?
			Team.joins(:players).where(players: { id: [self.person.player_id] })
		else
			nil
		end
	end
end
