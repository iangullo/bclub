module SeasonsHelper
  # return icon and top of HeaderComponent
  def season_title_fields(title:, cols: nil)
    title_start(icon: "calendar.svg", title: title, cols:)
  end

  # FieldComponents for season links
  def season_links(season:)
    [[
      {kind: "jump", icon: "location.svg", url: season_locations_path(season), label: I18n.t("location.many"), align: "center"},
      {kind: "jump", icon: "team.svg", url: teams_path + "?season_id=" + season.id.to_s, label: I18n.t("team.many"), align: "center"},
      {kind: "jump", icon: "timetable.svg", url: season.locations.empty? ? slots_path(season_id: season.id) : slots_path(season_id: season.id, location_id: season.locations.practice.first.id), label: I18n.t("slot.many"), align: "center"},
      {kind: "edit", url: edit_season_path(season), size: "30x30", frame: "modal"}
    ]]
  end

  # return HeaderComponent @fields for forms
  def season_form_fields(title:, season:, cols: nil)
    res = season_title_fields(title:, cols:)
    res << [{kind: "subtitle", value: season.name}]
    res << [{kind: "label", align: "right", value: I18n.t("calendar.start")}, {kind: "date-box", key: :start_date, s_year: 2020, value: season.start_date}]
    res << [{kind: "label", align: "right", value: I18n.t("calendar.end")}, {kind: "date-box", key: :end_date, s_year: 2020, value: season.end_date}]
    res
  end
end
