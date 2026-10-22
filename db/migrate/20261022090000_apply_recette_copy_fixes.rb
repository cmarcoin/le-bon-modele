class ApplyRecetteCopyFixes < ActiveRecord::Migration[8.1]
  def up
    intro = SiteCopy.find_by(key: "about.intro_body")
    if intro&.value&.include?("passés par là.\nDes heures")
      intro.update!(value: intro.value.sub("passés par là.\nDes heures", "passés par là. Des heures"))
    end

    Pack.find_each do |pack|
      next if pack.objective.blank? || !pack.objective.include?("'")

      pack.update!(objective: pack.objective.tr("'", "’"))
    end
  end

  def down
    intro = SiteCopy.find_by(key: "about.intro_body")
    if intro&.value&.include?("passés par là. Des heures")
      intro.update!(value: intro.value.sub("passés par là. Des heures", "passés par là.\nDes heures"))
    end
  end
end
