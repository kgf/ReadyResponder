class Notification < ActiveRecord::Migration
  def change
    add_column :notifications, :individuals, :text
  end
end
