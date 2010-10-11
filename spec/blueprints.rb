require 'machinist/active_record'
require 'sham'
require 'faker'

Sham.define do
  email { Faker::Internet.email }
  name { Faker::Name.name }
  password { Faker::Lorem.words(4).join('') }
  password_confirmation { password }
  url { 'http://' << Faker::Internet.domain_name }
end

Instructor.blueprint do
  name { Faker::Name.name }
end

Video.blueprint do
  title { Faker::Lorem.words(4).join(' ') }
  description { Faker::Lorem.words(4).join(' ') }
  is_public { true }
  duration { 100 }
end

YogaType.blueprint do
  name { Faker::Name.name }
  description { Faker::Lorem.paragraphs(3).to_s }
end