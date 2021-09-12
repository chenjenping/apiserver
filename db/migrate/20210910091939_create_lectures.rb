class CreateLectures < ActiveRecord::Migration[6.1]
  def change
    create_table :lectures do |t|
      t.string :title
      t.text :description
      t.text :content
      t.integer :order
      t.references :chapter, null: false, foreign_key: true

      t.timestamps
    end
  end
end
