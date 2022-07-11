# frozen_string_literal: true

class SubmitComponent < ApplicationComponent
  def initialize(close: true, c_label: I18n.t(:m_close), submit: nil, close_return: nil, turbo: nil)
    @close = {kind: "close", label: c_label, url: close_return} if close
    if submit == "save" # save button
      @submit = {kind: "save", label: I18n.t(:m_save)}
    elsif submit # edit button with link in "submit"
      @submit = {kind: "edit", label: I18n.t(:m_edit), url: submit, turbo: turbo}
    end
  end
end
