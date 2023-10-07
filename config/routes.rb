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
# For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
	root to: "home#index"
	get 'home/index'
	get 'home/edit'
	get 'home/actions'
	get 'home/clear'
	devise_for :users, :skip => [:registrations]
	as :user do
		get 'users/edit' => 'devise/registrations#edit', :as => 'edit_user_registration'
		put 'users' => 'devise/registrations#update', :as => 'user_registration'
	end
	resources :users do
		get 'actions', on: :member
		get 'clear_actions', on: :member
	end
	resources :people do
		collection do
			post :import
		end
	end
	resources :coaches do
		collection do
			post :import
		end
	end
	resources :players do
		collection do
			post :import
  	end
	end
	resources :sports do
		get 'rules', on: :member
		resources :categories
		resources :divisions
	end
	resources :seasons do
		resources :locations
		resources :slots
		resources :events
	end
	resources :slots
	resources :locations
	resources :teams do
		get 'roster', on: :member
		get 'edit_roster', on: :member
		get 'targets', on: :member
		get 'edit_targets', on: :member
		get 'plan', on: :member
		get 'edit_plan', on: :member
		get 'slots', on: :member
		get 'attendance', on: :member
		resources :events
	end
	resources :events do
		get 'copy', on: :member
		get 'load_chart', on: :member
		get 'show_task', on: :member
		get 'add_task', on: :member
		get 'edit_task', on: :member
		get 'attendance', on: :member
		get 'player_stats', on: :member
		get 'edit_player_stats', on: :member
	end
	resources :drills do
		get 'versions', on: :member
	end
end
