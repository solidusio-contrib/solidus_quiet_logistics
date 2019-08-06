class CreateQlMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :ql_messages do |t|
      t.string :document_name, null: false
      t.string :document_type, null: false
      t.boolean :success, default: false
      t.binary :document_body
      t.datetime :processed_at

      t.timestamps
    end
  end
end
