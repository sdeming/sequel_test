Sequel.migration do
  up do
    create_table(:notes) do
      primary_key :id
      String :title, :null => false
      String :content, :null => false, :text => true
    end
  end

  down do
    drop_table(:notes)
  end
end
