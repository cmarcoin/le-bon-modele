class FixSiteCopyWording < ActiveRecord::Migration[8.1]
  def up
    hero = SiteCopy.find_by(key: "home.hero_title")
    if hero&.value == "Choisissez la voiture qu’il vous faut. Pas celle qu’on cherche à vous vendre"
      hero.update!(value: "Choisissez la voiture qu’il vous faut. Pas celle qu’on cherche à vous vendre.")
    end

    independence = SiteCopy.find_by(key: "about.independence")
    if independence&.value&.include?("En tout indépendance")
      independence.update!(value: independence.value.sub("En tout indépendance", "En toute indépendance"))
    end
  end

  def down
    hero = SiteCopy.find_by(key: "home.hero_title")
    if hero&.value == "Choisissez la voiture qu’il vous faut. Pas celle qu’on cherche à vous vendre."
      hero.update!(value: "Choisissez la voiture qu’il vous faut. Pas celle qu’on cherche à vous vendre")
    end

    independence = SiteCopy.find_by(key: "about.independence")
    if independence&.value&.include?("En toute indépendance")
      independence.update!(value: independence.value.sub("En toute indépendance", "En tout indépendance"))
    end
  end
end
