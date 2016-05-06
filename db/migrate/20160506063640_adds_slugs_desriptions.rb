class AddsSlugsDesriptions < ActiveRecord::Migration
  def change
    add_column :teams,          :slug,        :string, index:true
    add_column :teams,          :description, :string
    add_column :pull_requests,  :title,       :string
    add_column :repositories,   :description, :string
  end
end
