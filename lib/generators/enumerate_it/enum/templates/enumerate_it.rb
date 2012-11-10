class <%= class_name %> < EnumerateIt::Base
  <% if fields.first.is_a?(Array) %>associate_values <%= fields.map {|field, value| ":#{field} => #{value}"}.join(', ') %><% else %>associate_values <%= fields.map {|field| ":#{field}"}.join(', ') %><% end %>
end
