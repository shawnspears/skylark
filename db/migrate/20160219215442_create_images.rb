class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :tileset_name
      t.string :image_url
      t.timestamps null: false
    end
  end
end
