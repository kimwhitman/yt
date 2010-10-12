require 'machinist/active_record'
require 'sham'
require 'faker'

Sham.define do
  email { Faker::Internet.email }
  name { Faker::Name.name }
  password { Faker::Lorem.words(4).join('') }
  password_confirmation { password }
  url { 'http://' << Faker::Internet.domain_name }
  description { Faker::Lorem.words(4).join(' ') }
end

Instructor.blueprint do
  name
end

SkillLevel.blueprint do
  name
  description
end

VideoFocus.blueprint do
  video_focus_category_id { 1 }
  name
end

VideoFocusCategory.blueprint do
  name
end

Video.blueprint do
  title { Faker::Lorem.words(4).join(' ') }
  description
  is_public { true }
  duration { 100 }
end

YogaType.blueprint do
  name
  description
end