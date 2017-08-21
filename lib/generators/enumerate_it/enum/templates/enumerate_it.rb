class <%= class_name %> < EnumerateIt::Base
  associate_values(
    <%= fields.map { |field, value| value ? "#{field}: #{value}" : ":#{field}"}.join(",\n    ") %>
  )
end
