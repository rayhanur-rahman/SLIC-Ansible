# Link/Unlink the proper omnibus commands based on role
omnibus_commands.each do |command|
  link command[:destination] do
    to command[:source]
    action command[:action]
  end
end
