class CreateMicroposts < ActiveRecord::Migration[7.1]
  def change
    create_table :microposts do |t|
      t.text :message
      t.belongs_to :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
