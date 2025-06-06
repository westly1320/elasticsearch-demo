# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end



100.times do
  Post.create({
                title: Faker::Book.title,
                body: Faker::Lorem.paragraph(sentence_count: 2),
                views_count: rand(1..100)
              })
end

Post.find_each do |post|
  rand(1..5).times do
    Comment.create!(
      post: post,
      body: Faker::Lorem.paragraph(sentence_count: 3)
    )
  end
end
